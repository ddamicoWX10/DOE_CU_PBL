load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

; User modification area, the forcing and directories vary between
; LASSO simulations
  gtype = "pdf"
  phys  = "GFS_v16beta"
  pbl   = "YSU" ; "satmedmf","YSU","MYNN","ACM","saYSU"
  LAS   = "LASSO"
  YYYY  = "2017"

  cloud_skill = "HI" ; "HI" for high, "MD" for medium, "LO" for low

; End user modification area
  print("Started: "+systemfunc("date"))

; Constants
  R_dry = 287.    ; ideal gas constant for dry air (J kg^-1 K^-1)
  R_vap = 461.5   ; gas constant for water vapor (J kg^-1 K^-1)
  c_p   = 1004.   ; specific heat at const pressure (J kg^-1 K^-1)
  l_v   = 2.5e6   ; latent heat of vaporization (J kg^-1)
  g     = 9.80665 ; acceleration due tp gravity (m s^-2)
  P00   = 100000. ; initial pressure (Pa)

  topdir = "/glade/work/damico/"
  obsdir = "/glade/u/home/damico/DOE2021/OBS-TOT"+YYYY+"/"

; List all files
  if (pbl .eq. "satmedmf") then
    lsalls = systemfunc("ls "+topdir+"output_"+cloud_skill+"cloudskill_"+ \
                        LAS+"_"+YYYY)
  else
    lsalls = systemfunc("ls "+topdir+pbl+"-output_"+cloud_skill+ \
                        "cloudskill_"+LAS+"_"+YYYY)
  end if

  lsallo = systemfunc("ls "+obsdir)

  lswrf  = systemfunc("ls "+topdir+"wrfstat_subset_"+cloud_skill+"/"+ \
                      YYYY+"*/sim*/")

  ns = dimsizes(lsalls)
  no = dimsizes(lsallo)

; Add files
  if (pbl .eq. "satmedmf") then
    simID = topdir+"output_"+cloud_skill+"cloudskill_"+LAS+"_"+YYYY+"/"+ \
            lsalls+"/"
  else
    simID = topdir+pbl+"-output_"+cloud_skill+"cloudskill_"+LAS+"_"+YYYY+"/"+ \
            lsalls+"/"
  end if

  fscm = addfiles(simID+"/output.nc","r")
  ListSetType(fscm,"join")
  fobs = addfiles(obsdir+lsallo,"r")
  ListSetType(fobs,"join")

  wrfdirs    = new((/ ns /),string)
  wrffils    = new((/ ns /),string)
  do i=0,ns-1,1
    if (i .eq. 0) then
      wrfdirs(i) = lswrf(i)
      wrffils(i) = lswrf(i+1)
    else
      wrfdirs(i) = lswrf(i*3)
      wrffils(i) = lswrf((i*3)+1)
    end if
  end do

  fwrf = addfiles(str_get_cols(wrfdirs,0,-2)+wrffils,"r")
  ListSetType(fwrf,"join")

; Time
  tscm = fscm[0]->time

  hscm       = tscm
  hscm       = tscm / 60. / 60.

  hobs = fobs[:]->TIME_PBLH

  tobs = hobs * 60. * 60.

  twrf = fwrf[0]->Time

  hwrf = twrf
  hwrf = twrf / 60. / 60.

  nt = dimsizes(hscm)

; SCM variables
  presscm_Pa = fscm[:]->pres
  psfcscm_Pa = fscm[:]->pres_s
  tmpscm_K   = fscm[:]->T
  tsfcscm_K  = fscm[:]->T_s
  qvscm_kgkg = fscm[:]->qv
  pblhscm_m  = fscm[:]->atmosphere_boundary_layer_thickness

; Find SCM height (not an SCM output variable, use hypsometric equation)
; Start with whole atmosphere virtual temperature
  tv = tmpscm_K
  tv = tmpscm_K * ((1 + (qvscm_kgkg / (R_dry/R_vap))) / \
                  (1 + qvscm_kgkg))

  tv@description = "virtual temperature"

; Surface virtual temperature
  tvs = tsfcscm_K
  tvs = tsfcscm_K *((1 + (qvscm_kgkg(:,:,0,:) / (R_dry/R_vap))) / \
                   (1 + qvscm_kgkg(:,:,0,:)))

  tvs@description = "surface virtual temperature"

; Height of level 0
  z0   = (((R_dry * tvs) / g) * log(psfcscm_Pa / presscm_Pa(:,:,0,:)))
  z0!0 = "ncl_join"
  z0!1 = "time_dim"
  z0!2 = "hor_dim_layer"

; Use hypsometric equation, with height at level 0, to find full model height
  hgtscm_m        = new((/ dimsizes(presscm_Pa(:,:,:,0)) /),float)
  hgtscm_m(:,:,0) = z0(:,:,0)
  do i=1,dimsizes(hgtscm_m(0,0,:))-1,1
    hgtscm_m(:,:,i) = hgtscm_m(:,:,i-1) + (((R_dry * tv(:,:,i,0)) / g) * \
                      log(presscm_Pa(:,:,i-1,0) / presscm_Pa(:,:,i,0)))
  end do
  hgtscm_m!2           = "vert_dim_layer"
  hgtscm_m@description = "model height"
  hgtscm_m@units       = "m"

; SCM temperature to potential temperature
  thtscm_K = tmpscm_K
  thtscm_K = tmpscm_K * ((P00 / presscm_Pa)^(R_dry / c_p))

  thtscm_K@description = "potential temperature"

; wrfstat variables
  thtwrf_K = fwrf[:]->CSP_TH
  hgtwrf_m = fwrf[:]->CSP_Z

; 1.5-theta-increase method to determine PBL height (Nielsen-Gammon et al.
; 2008; Hu et al. 2010). Most accurate in a convective boundary layer,
; so when things are very stable and the PBL is shallow, this method
; might not be ideal.
  minthtscm_K = new((/ ns,nt /),float)
  minthtwrf_K = new((/ ns,nt /),float)
  mindimscm   = new((/ ns,nt /),integer)
  mindimwrf   = new((/ ns,nt /),integer)
  thtscm_1_5K = new((/ ns,nt /),float)
  thtwrf_1_5K = new((/ ns,nt /),float)
  vs1_5       = new((/ ns,nt /),integer)
  vw1_5       = new((/ ns,nt /),integer)
  pblhscm_md2 = new((/ ns,nt /),float)
  pblhwrf_md2 = new((/ ns,nt /),float)
  do i=0,ns-1,1
    do j=0,nt-1,1
      minthtscm_K(i,j) = min(thtscm_K(i,j,:,0))
      minthtwrf_K(i,j) = min(thtwrf_K(i,j,:))
      mindimscm(i,j)   = minind(thtscm_K(i,j,:,0))
      mindimwrf(i,j)   = minind(thtwrf_K(i,j,:))
      thtscm_1_5K(i,j) = minthtscm_K(i,j) + 1.5
      thtwrf_1_5K(i,j) = minthtwrf_K(i,j) + 1.5
      vs1_5(i,j)       = closest_val(thtscm_1_5K(i,j),thtscm_K(i,j,:,0))
      vw1_5(i,j)       = closest_val(thtwrf_1_5K(i,j),thtwrf_K(i,j,:))
      if (vs1_5(i,j) .lt. mindimscm(i,j)) then
         vs1_5(i,j)    = closest_val(thtscm_1_5K(i,j), \
                                     thtscm_K(i,j,mindimscm(i,j):126,0))
      end if
      pblhscm_md2(i,j) = hgtscm_m(i,j,vs1_5(i,j))
      pblhwrf_md2(i,j) = hgtwrf_m(i,j,vw1_5(i,j))
    end do
  end do

; Observations cover the entire 24 hours, while the SCM goes from 0600-2100
; LST. Subset the times from the observations.
  obsrn = closest_val(6.,hobs(0,:))
  obsrx = closest_val(21.,hobs(0,:))

; ML and PBL Height from LIDAR
  mlhobs_all  = fobs[:]->HEIGHT_MLH
  pblhobs_all = fobs[:]->HEIGHT_PBLH

  pblhobs_km = pblhobs_all(:,obsrn:obsrx)
  mlhobs_km  = mlhobs_all(:,obsrn:obsrx)

  pblhobs_m = pblhobs_km
  pblhobs_m = pblhobs_km * 1000. ; Convert to m
  mlhobs_m  = mlhobs_km
  mlhobs_m  = mlhobs_km * 1000.  ; Convert to m

; Difference (model - observations)
  pblh_diff = pblhscm_md2
  pblh_diff = pblhscm_md2 - tofloat(pblhobs_m)

  pblh_diffW = pblhwrf_md2
  pblh_diffW = pblhwrf_md2 - tofloat(pblhobs_m)

  ml_diff15 = pblhscm_md2
  ml_diff15 = pblhscm_md2 - tofloat(mlhobs_m)

  ml_diffW15 = pblhwrf_md2
  ml_diffW15 = pblhwrf_md2 - tofloat(mlhobs_m)

  noonscm = closest_val(6.,hscm)
  noonobs = closest_val(12.,hobs(0,obsrn:obsrx))

; Start with MLH from obs, and after noon, use PBLH from obs
  ml_diff  = new((/ ns,nt /),float)
  ml_diffW = new((/ ns,nt /),float)
  do i=0,nt-1,1
    if (i .lt. noonscm) then
      ml_diff(:,i)  = pblhscm_md2(:,i)
      ml_diff(:,i)  = pblhscm_md2(:,i) - tofloat(mlhobs_m(:,i))
      ml_diffW(:,i) = pblhwrf_md2(:,i)
      ml_diffW(:,i) = pblhwrf_md2(:,i) - tofloat(mlhobs_m(:,i))
    else
      ml_diff(:,i)  = pblhscm_md2(:,i)
      ml_diff(:,i)  = pblhscm_md2(:,i) - tofloat(pblhobs_m(:,i))
      ml_diffW(:,i) = pblhwrf_md2(:,i)
      ml_diffW(:,i) = pblhwrf_md2(:,i) - tofloat(pblhobs_m(:,i))
    end if
  end do

; Several "-nan" present after taking the differences (obs are missing data),
; change those to _FillValue
  do i=0,ns-1,1
    do j=0,nt-1,1
      if (pblh_diff(i,j) .eq. "-nan") then
        pblh_diff(i,j)  = pblhscm_md2@_FillValue
        pblh_diffW(i,j) = pblhscm_md2@_FillValue
      end if
      if (ml_diff15(i,j) .eq. "-nan") then
        ml_diff15(i,j)  = pblhscm_md2@_FillValue
        ml_diffW15(i,j) = pblhscm_md2@_FillValue
      end if
      if (ml_diff(i,j) .eq. "-nan") then
        ml_diff(i,j)  = pblhscm_md2@_FillValue
        ml_diffW(i,j) = pblhscm_md2@_FillValue
      end if
    end do
  end do

; Start plotting
  wks = gsn_open_wks(gtype,YYYY+"_"+pbl+"-BLHgts-"+cloud_skill+"+WRF")

  gsn_define_colormap(wks,"MPL_bwr")

  res = True

  res@gsnMaximize              = True
  res@cnFillOn                 = True
  res@cnLinesOn                = False
  res@cnFillMode               = "RasterFill"
;  res@cnRasterSmoothingOn      = True
  res@sfXArray                 = hscm
  res@tiYAxisString            = "Date ("+YYYY+")"
  res@tiXAxisString            = "CST"
  res@tiMainString             = "PBLH 15 hr"
  res@lbOrientation            = "vertical"
  res@lbBoxLinesOn             = False
  if (pbl .eq. "satmedmf") then
    res@gsnLeftString          = str_upper(pbl)+"-SCM - Obs PBLH (m)"
  else
    res@gsnLeftString          = pbl+"-SCM - Obs PBLH (m)"
  end if
  res@gsnRightString           = cloud_skill+" Skill"
  res@cnLevelSelectionMode     = "ManualLevels"
  res@cnMinLevelValF           = -3000.
  res@cnMaxLevelValF           = 3000.
  res@cnLevelSpacingF          = 100.
  res@cnMissingValFillColor    = "gray24"
;  res@cnMissingValFillPattern  = 3
  res@tmXBMode                 = "Explicit"
  res@tmXBValues               = (/ 0.,3.,6.,9.,12.,15. /)
  res@tmXBMinorValues          = (/ 1.,2.,4.,5.,7.,8.,10.,11.,13.,14. /)
  res@tmXBLabels               = (/ "0600","0900","1200","1500","1800", \
                                    "2100" /)
  res@tmYLMode                 = "Explicit"
  if (YYYY .eq. "2016") then
    res@tmYLValues             = (/ 0., 1., 2., 3., 4., 5., 6., 7., 8., \
                                    9., 10.,11. /)
    res@tmYLLabels             = (/ "18-May","10-Jun","11-Jun", \
                                    "14-Jun","19-Jun","25-Jun","16-Jul", \
                                    "19-Jul","20-Jul","18-Aug","19-Aug", \
                                    "30-Aug" /)
  else if (YYYY .eq. "2017") then
    res@tmYLValues             = (/ 0.,  1., 2., 3., 4., 5., 6., 7., 8., \
                                    9., 10.,11.,12.,13.,14.,15.,16.,17., \
                                    18.,19.,20.,21.,22.,23.,24.,25.,26., \
                                    27. /)
    res@tmYLLabels             = (/ "09-May","24-May","27-May","05-Jun", \
                                    "09-Jun","14-Jun","26-Jun","27-Jun", \
                                    "29-Jun","30-Jun","04-Jul","05-Jul", \
                                    "09-Jul","12-Jul","16-Jul","17-Jul", \
                                    "19-Jul","20-Jul","21-Jul","25-Jul", \
                                    "28-Jul","02-Aug","26-Aug","28-Aug", \
                                    "30-Aug","22-Sep","23-Sep","24-Sep" /)
  else if (YYYY .eq. "2018") then
    res@tmYLValues             = (/ 0.,  1., 2., 3., 4., 5., 6., 7., 8., \
                                    9., 10.,11.,12.,13.,14.,15.,16.,17., \
                                    18.,19.,20.,21.,22.,23.,24.,25.,26., \
                                    27. /)
    res@tmYLLabels             = (/ "14-May","22-May","23-May","29-May", \
                                    "30-May","31-May","06-Jun","18-Jun", \
                                    "19-Jun","04-Jul","05-Jul","07-Jul", \
                                    "09-Jul","10-Jul","11-Jul","12-Jul", \
                                    "31-Jul","05-Aug","09-Aug","11-Aug", \
                                    "01-Sep","02-Sep","09-Sep","11-Sep", \
                                    "14-Sep","16-Sep","17-Sep","18-Sep" /)
  else if (YYYY .eq. "2019") then
    res@tmYLValues             = (/ 0.,  1., 2., 3., 4., 5., 6., 7., 8., \
                                    9., 10.,11.,12.,13.,14. /)
    res@tmYLLabels             = (/ "12-May","17-May","07-Jun","12-Jun", \
                                    "17-Jun","26-Jun","01-Jul","04-Jul", \
                                    "07-Jul","09-Jul","14-Jul","04-Aug", \
                                    "05-Aug","01-Sep","29-Sep" /)
  end if
  end if
  end if
  end if

  plot = gsn_csm_contour(wks,pblh_diff,res)

  res@gsnLeftString            = "wrfstat - Obs PBLH (m)"

  plot = gsn_csm_contour(wks,pblh_diffW,res)

  res@cnRasterSmoothingOn      = True
  res@tiMainString             = "PBLH 15 hr SMOOTHED"
  if (pbl .eq. "satmedmf") then
    res@gsnLeftString          = str_upper(pbl)+"-SCM - Obs PBLH (m)"
  else
    res@gsnLeftString          = pbl+"-SCM - Obs PBLH (m)"
  end if

  plot = gsn_csm_contour(wks,pblh_diff,res)

  res@gsnLeftString            = "wrfstat - Obs PBLH (m)"

  plot = gsn_csm_contour(wks,pblh_diffW,res)

  res@cnRasterSmoothingOn      = False
  if (pbl .eq. "satmedmf") then
    res@gsnLeftString          = str_upper(pbl)+"-SCM - Obs MLH (m)"
  else
    res@gsnLeftString          = pbl+"-SCM - Obs MLH (m)"
  end if
  res@tiMainString             = "MLH 15 hr"

  plot = gsn_csm_contour(wks,ml_diff15,res)

  res@gsnLeftString            = "wrfstat - Obs MBLH (m)"

  plot = gsn_csm_contour(wks,ml_diffW15,res)

  res@cnRasterSmoothingOn      = True
  res@tiMainString             = "MLH 15 hr SMOOTHED"
  if (pbl .eq. "satmedmf") then
    res@gsnLeftString          = str_upper(pbl)+"-SCM - Obs MLH (m)"
  else
    res@gsnLeftString          = pbl+"-SCM - Obs MLH (m)"
  end if

  plot = gsn_csm_contour(wks,ml_diff15,res)

  res@gsnLeftString            = "wrfstat - Obs MBLH (m)"
  
  plot = gsn_csm_contour(wks,ml_diffW15,res)

  res@gsnDraw                  = False
  res@gsnFrame                 = False
  res@cnRasterSmoothingOn      = False
  if (pbl .eq. "satmedmf") then
    res@gsnLeftString          = str_upper(pbl)+"-SCM - Obs ML&PBLH (m)"
  else
    res@gsnLeftString          = pbl+"-SCM - Obs ML&PBLH (m)"
  end if
  res@tiMainString             = "MLH 6 hr/PBLH 9 hr"

  plres                        = True
  plres@gsLineThicknessF       = 3.
  plres@gsLineDashPattern      = 1

  plot = gsn_csm_contour(wks,ml_diff,res)

  draw(plot)
  gsn_polyline(wks,plot,(/ 6,6 /),(/ 0,ns-1 /),plres)
  frame(wks)

  res@gsnLeftString            = "wrfstat - Obs ML&PBLH (m)"

  plot = gsn_csm_contour(wks,ml_diffW,res)

  draw(plot)
  gsn_polyline(wks,plot,(/ 6,6 /),(/ 0,ns-1 /),plres)
  frame(wks)

  res@cnRasterSmoothingOn      = True
  res@tiMainString             = "MLH 6 hr/PBLH 9 hr SMOOTHED"

  if (pbl .eq. "satmedmf") then
    res@gsnLeftString          = str_upper(pbl)+"-SCM - Obs ML&PBLH (m)"
  else
    res@gsnLeftString          = pbl+"-SCM - Obs ML&PBLH (m)"
  end if

  plot = gsn_csm_contour(wks,ml_diff,res)

  draw(plot)
  gsn_polyline(wks,plot,(/ 6,6 /),(/ 0,ns-1 /),plres)
  frame(wks)

  res@gsnLeftString            = "wrfstat - Obs ML&PBLH (m)"

  plot = gsn_csm_contour(wks,ml_diffW,res)

  draw(plot)
  gsn_polyline(wks,plot,(/ 6,6 /),(/ 0,ns-1 /),plres)
  frame(wks)

  print("Complete: "+systemfunc("date"))

end

