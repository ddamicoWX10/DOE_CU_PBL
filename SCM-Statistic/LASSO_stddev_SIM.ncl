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
  LAS   = "LASSO"
  YYYY  = "2017"

  topdir = "/glade/work/damico/"

  pbl = "satmedmf" ;"ACM","MYNN","satmedmf","YSU"
  CSS = (/ "HI","MD","LO" /) ; Cloud skill score

  nss = dimsizes(CSS)

; End user modification area
  print("Started: "+systemfunc("date"))

  if (pbl .eq. "satmedmf") then
    lsHI = systemfunc("ls "+topdir+"output_"+CSS(0)+"cloudskill_"+ \
                      LAS+"_"+YYYY)
    lsMD = systemfunc("ls "+topdir+"output_"+CSS(1)+"cloudskill_"+ \
                      LAS+"_"+YYYY)
    lsLO = systemfunc("ls "+topdir+"output_"+CSS(2)+"cloudskill_"+ \
                      LAS+"_"+YYYY)
  else
    lsHI = systemfunc("ls "+topdir+pbl+"-output_"+CSS(0)+"cloudskill_"+ \
                      LAS+"_"+YYYY)
    lsMD = systemfunc("ls "+topdir+pbl+"-output_"+CSS(1)+"cloudskill_"+ \
                      LAS+"_"+YYYY)
    lsLO = systemfunc("ls "+topdir+pbl+"-output_"+CSS(2)+"cloudskill_"+ \
                      LAS+"_"+YYYY)
  end if

  ns = dimsizes(lsHI)

  if (pbl .eq. "satmedmf") then
    simHI  = topdir+"output_"+CSS(0)+"cloudskill_"+ \
             LAS+"_"+YYYY+"/"+lsHI
    simMD  = topdir+"output_"+CSS(1)+"cloudskill_"+ \
             LAS+"_"+YYYY+"/"+lsMD
    simLO  = topdir+"output_"+CSS(2)+"cloudskill_"+ \
             LAS+"_"+YYYY+"/"+lsLO
  else
    simHI  = topdir+pbl+"-output_"+CSS(0)+"cloudskill_"+ \
             LAS+"_"+YYYY+"/"+lsHI
    simMD  = topdir+pbl+"-output_"+CSS(1)+"cloudskill_"+ \
             LAS+"_"+YYYY+"/"+lsMD
    simLO  = topdir+pbl+"-output_"+CSS(2)+"cloudskill_"+ \
             LAS+"_"+YYYY+"/"+lsLO
  end if

  fHI = addfiles(simHI+"/output.nc","r")
  ListSetType(fHI,"join")
  fMD = addfiles(simMD+"/output.nc","r")
  ListSetType(fMD,"join")
  fLO = addfiles(simLO+"/output.nc","r")
  ListSetType(fLO,"join")

  tscm = fHI[0]->time

  hscm       = tscm
  hscm       = tscm / 60. / 60.
  hscm@units = "hours since start of simulation"

  nt = dimsizes(tscm)

  pp = fHI[0]->pres

  nz = dimsizes(pp(0,:,0))

  T            = new((/ nss,ns,nt,nz,1 /),float)
  T(0,:,:,:,:) = fHI[:]->T
  T(1,:,:,:,:) = fMD[:]->T
  T(2,:,:,:,:) = fLO[:]->T

  qv            = new((/ nss,ns,nt,nz,1 /),float)
  qv(0,:,:,:,:) = fHI[:]->qv
  qv(1,:,:,:,:) = fMD[:]->qv
  qv(2,:,:,:,:) = fLO[:]->qv

  u            = new((/ nss,ns,nt,nz,1 /),float)
  u(0,:,:,:,:) = fHI[:]->u
  u(1,:,:,:,:) = fMD[:]->u
  u(2,:,:,:,:) = fLO[:]->u

  v            = new((/ nss,ns,nt,nz,1 /),float)
  v(0,:,:,:,:) = fHI[:]->v
  v(1,:,:,:,:) = fMD[:]->v
  v(2,:,:,:,:) = fLO[:]->v

  pblh          = new((/ nss,ns,nt,1 /),float)
  pblh(0,:,:,:) = fHI[:]->atmosphere_boundary_layer_thickness
  pblh(1,:,:,:) = fMD[:]->atmosphere_boundary_layer_thickness
  pblh(2,:,:,:) = fLO[:]->atmosphere_boundary_layer_thickness

  T!0    = "CldSkl"
  qv!0   = "CldSkl"
  u!0    = "CldSkl"
  v!0    = "CldSkl"
  pblh!0 = "CldSkl"

  T_stddev_ss    = dim_stddev_n_Wrap(T,(/ 2,3,4 /))
  qv_stddev_ss   = dim_stddev_n_Wrap(qv,(/ 2,3,4 /))
  u_stddev_ss    = dim_stddev_n_Wrap(u,(/ 2,3,4 /))
  v_stddev_ss    = dim_stddev_n_Wrap(v,(/ 2,3,4 /))
  pblh_stddev_ss = dim_stddev_n_Wrap(pblh,(/ 2,3 /))

; Plotting (start with line graphs comparing the different LSF sims)
  wks = gsn_open_wks(gtype,"DOE_SIM-"+pbl+"_stddev")

  res = True

  res@gsnMaximize          = True
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@xyLineThicknessF     = 3.4
  res@xyLineColors         = (/ "black","darkorange1","purple4" /)
  res@xyDashPatterns       = (/ 0,1,3 /)
  res@tiYAxisString        = "T Std Dev"
  res@gsnLeftString        = YYYY+"-"+pbl
  res@gsnRightString       = "K"
  res@tmXBMode             = "Explicit"
  if (YYYY .eq. "2016") then
    res@tmXBValues         = (/ 0., 1., 2., 3., 4., 5., 6., 7., 8., \
                                9., 10.,11.,12. /)
    res@tmXBLabels         = (/ "18-May","30-May","10-Jun","11-Jun", \
                                "14-Jun","19-Jun","25-Jun","16-Jul", \
                                "19-Jul","20-Jul","18-Aug","19-Aug", \
                                "30-Aug" /)
  else if (YYYY .eq. "2017") then
    res@tmXBValues         = (/ 0.,  1., 2., 3., 4., 5., 6., 7., 8., \
                                9., 10.,11.,12.,13.,14.,15.,16.,17., \
                                18.,19.,20.,21.,22.,23.,24.,25.,26., \
                                27. /)
    res@tmXBLabels         = (/ "09-May","24-May","27-May","05-Jun", \
                                "09-Jun","14-Jun","26-Jun","27-Jun", \
                                "29-Jun","30-Jun","04-Jul","05-Jul", \
                                "09-Jul","12-Jul","16-Jul","17-Jul", \
                                "19-Jul","20-Jul","21-Jul","25-Jul", \
                                "28-Jul","02-Aug","26-Aug","28-Aug", \
                                "30-Aug","22-Sep","23-Sep","24-Sep" /)

  else if (YYYY .eq. "2018") then
    res@tmXBValues         = (/ 0.,  1., 2., 3., 4., 5., 6., 7., 8., \
                                9., 10.,11.,12.,13.,14.,15.,16.,17., \
                                18.,19.,20.,21.,22.,23.,24.,25.,26., \
                                27. /)
    res@tmXBLabels         = (/ "14-May","22-May","23-May","29-May", \
                                "30-May","31-May","06-Jun","18-Jun", \
                                "19-Jun","04-Jul","05-Jul","07-Jul", \
                                "09-Jul","10-Jul","11-Jul","12-Jul", \
                                "31-Jul","05-Aug","09-Aug","11-Aug", \
                                "01-Sep","02-Sep","09-Sep","11-Sep", \
                                "14-Sep","16-Sep","17-Sep","18-Sep" /)
  else if (YYYY .eq. "2019") then
    res@tmXBValues         = (/ 0.,  1., 2., 3., 4., 5., 6., 7., 8., \
                                9., 10.,11.,12.,13.,14. /)
    res@tmXBLabels         = (/ "12-May","17-May","07-Jun","12-Jun", \
                                "17-Jun","26-Jun","01-Jul","04-Jul", \
                                "07-Jul","09-Jul","14-Jul","04-Aug", \
                                "05-Aug","01-Sep","29-Sep" /)
  end if
  end if
  end if
  end if
  res@tmXBLabelAngleF       = -75.
  res@tmXBLabelFontHeightF  = 0.0125

  plot = gsn_csm_y(wks,T_stddev_ss,res)

  genres                    = True
  genres@XPosPercent        = 19
  genres@YPosPercent        = 91
  lineres                   = True
  lineres@lgLineThicknesses = 3.4
  lineres@lgDashIndexes     = res@xyDashPatterns
  lineres@lgLineColors      = res@xyLineColors
  textres                   = True
  textres@lgLabels          = CSS

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  res@tiYAxisString         = "q~B~v~N~ Std Dev"
  res@gsnRightString        = "kg kg~S~-1~N~"

  genres@XPosPercent        = 22
  genres@YPosPercent        = 89

  plot = gsn_csm_y(wks,qv_stddev_ss,res)

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  res@tiYAxisString         = "u Std Dev"
  res@gsnRightString        = "m s~S~-1~N~"

  genres@XPosPercent        = 18
  genres@YPosPercent        = 91

  plot = gsn_csm_y(wks,u_stddev_ss,res)

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  res@tiYAxisString         = "v Std Dev"
  res@gsnRightString        = "m s~S~-1~N~"

  genres@XPosPercent        = 81
  genres@YPosPercent        = 91

  plot = gsn_csm_y(wks,v_stddev_ss,res)

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  res@tiYAxisString         = "PBLH Std Dev"
  res@gsnRightString        = "m"

  genres@XPosPercent        = 82
  genres@YPosPercent        = 91

  plot = gsn_csm_y(wks,pblh_stddev_ss,res)

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  print("Finished: "+systemfunc("date"))

end

