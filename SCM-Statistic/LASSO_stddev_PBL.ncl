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

  pbl = (/ "ACM","MYNN","satmedmf","YSU" /)
  CSS = "HI" ; Cloud skill score (relative to other sims on day)

  np = dimsizes(pbl)

; End user modification area
  print("Started: "+systemfunc("date"))

  lsACM  = systemfunc("ls "+topdir+pbl(0)+"-output_"+CSS+"cloudskill_"+ \
                      LAS+"_"+YYYY)
  lsMYNN = systemfunc("ls "+topdir+pbl(1)+"-output_"+CSS+"cloudskill_"+ \
                      LAS+"_"+YYYY)
  lsGFS  = systemfunc("ls "+topdir+"output_"+CSS+"cloudskill_"+         \
                      LAS+"_"+YYYY)
  lsYSU  = systemfunc("ls "+topdir+pbl(3)+"-output_"+CSS+"cloudskill_"+ \
                      LAS+"_"+YYYY)

  ns = dimsizes(lsACM)

  simACM  = topdir+pbl(0)+"-output_"+CSS+"cloudskill_"+ \
            LAS+"_"+YYYY+"/"+lsACM
  simMYNN = topdir+pbl(1)+"-output_"+CSS+"cloudskill_"+ \
            LAS+"_"+YYYY+"/"+lsMYNN
  simGFS  = topdir+"output_"+CSS+"cloudskill_"+ \
            LAS+"_"+YYYY+"/"+lsGFS
  simYSU  = topdir+pbl(3)+"-output_"+CSS+"cloudskill_"+ \
            LAS+"_"+YYYY+"/"+lsYSU

  fACM  = addfiles(simACM+"/output.nc","r")
  ListSetType(fACM,"join")
  fMYNN = addfiles(simMYNN+"/output.nc","r")
  ListSetType(fMYNN,"join")
  fGFS  = addfiles(simGFS+"/output.nc","r")
  ListSetType(fGFS,"join")
  fYSU  = addfiles(simYSU+"/output.nc","r")
  ListSetType(fYSU,"join")

  tscm = fACM[0]->time

  hscm       = tscm
  hscm       = tscm / 60. / 60.
  hscm@units = "hours since start of simulation"

  nt = dimsizes(tscm)

  pp = fACM[0]->pres

  nz = dimsizes(pp(0,:,0))

  T            = new((/ np,ns,nt,nz,1 /),float)
  T(0,:,:,:,:) = fACM[:]->T
  T(1,:,:,:,:) = fMYNN[:]->T
  T(2,:,:,:,:) = fGFS[:]->T
  T(3,:,:,:,:) = fYSU[:]->T

  qv            = new((/ np,ns,nt,nz,1 /),float)
  qv(0,:,:,:,:) = fACM[:]->qv
  qv(1,:,:,:,:) = fMYNN[:]->qv
  qv(2,:,:,:,:) = fGFS[:]->qv
  qv(3,:,:,:,:) = fYSU[:]->qv

  u            = new((/ np,ns,nt,nz,1 /),float)
  u(0,:,:,:,:) = fACM[:]->u
  u(1,:,:,:,:) = fMYNN[:]->u
  u(2,:,:,:,:) = fGFS[:]->u
  u(3,:,:,:,:) = fYSU[:]->u

  v            = new((/ np,ns,nt,nz,1 /),float)
  v(0,:,:,:,:) = fACM[:]->v
  v(1,:,:,:,:) = fMYNN[:]->v
  v(2,:,:,:,:) = fGFS[:]->v
  v(3,:,:,:,:) = fYSU[:]->v

  pblh          = new((/ np,ns,nt,1 /),float)
  pblh(0,:,:,:) = fACM[:]->atmosphere_boundary_layer_thickness
  pblh(1,:,:,:) = fMYNN[:]->atmosphere_boundary_layer_thickness
  pblh(2,:,:,:) = fGFS[:]->atmosphere_boundary_layer_thickness
  pblh(3,:,:,:) = fYSU[:]->atmosphere_boundary_layer_thickness

  T!0    = "phys"
  qv!0   = "phys"
  u!0    = "phys"
  v!0    = "phys"
  pblh!0 = "phys"

  T_stddev_phsim    = dim_stddev_n_Wrap(T,(/ 2,3,4 /))
  qv_stddev_phsim   = dim_stddev_n_Wrap(qv,(/ 2,3,4 /))
  u_stddev_phsim    = dim_stddev_n_Wrap(u,(/ 2,3,4 /))
  v_stddev_phsim    = dim_stddev_n_Wrap(v,(/ 2,3,4 /))
  pblh_stddev_phsim = dim_stddev_n_Wrap(pblh,(/ 2,3 /))

;; Flip the dimensions for plotting that makes more sense
;  T_stddev_FPS    = T_stddev_phsim(ncl_join|:,phys|:)
;  qv_stddev_FPS   = qv_stddev_phsim(ncl_join|:,phys|:)
;  u_stddev_FPS    = u_stddev_phsim(ncl_join|:,phys|:)
;  v_stddev_FPS    = v_stddev_phsim(ncl_join|:,phys|:)
;  pblh_stddev_FPS = pblh_stddev_phsim(ncl_join|:,phys|:)

  T_stddev_tp    = dim_stddev_n_Wrap(T,(/ 0,1 /))
  qv_stddev_tp   = dim_stddev_n_Wrap(qv,(/ 0,1 /))
  u_stddev_tp    = dim_stddev_n_Wrap(u,(/ 0,1 /))
  v_stddev_tp    = dim_stddev_n_Wrap(v,(/ 0,1 /))
  pblh_stddev_tp = dim_stddev_n_Wrap(pblh,(/ 0,1 /))

; Plotting (start with line graphs comparing the PBL schemes)
  wks = gsn_open_wks(gtype,"DOE_PBL_stddev")

; Define smaller color table with white in middle
  BlueDarkRed18_WIM = (/ (/ 1.00000,1.00000,1.00000 /), \ ; Foreground (0)
                         (/ 0.00000,0.00000,0.00000 /), \ ; Background (1)
                         (/ 0.14118,0.00000,0.84706 /), \ ; 2
                         (/ 0.09412,0.10980,0.96863 /), \ ; 3
                         (/ 0.15686,0.34118,1.00000 /), \ ; 4
                         (/ 0.23922,0.25941,1.00000 /), \ ; 5
                         (/ 0.33725,0.69020,1.00000 /), \ ; 6
                         (/ 0.45882,0.82745,1.00000 /), \ ; 7
                         (/ 0.60000,0.91765,1.00000 /), \ ; 8
                         (/ 0.73725,0.97647,1.00000 /), \ ; 9
                         (/ 1.00000,1.00000,1.00000 /), \ ; 10
                         (/ 1.00000,1.00000,1.00000 /), \ ; 11
                         (/ 1.00000,0.94510,0.73725 /), \ ; 12
                         (/ 1.00000,0.83922,0.60000 /), \ ; 13
                         (/ 1.00000,0.67451,0.45882 /), \ ; 14
                         (/ 1.00000,0.47059,0.33725 /), \ ; 15
                         (/ 1.00000,0.23922,0.23922 /), \ ; 16
                         (/ 0.96863,0.15294,0.20784 /), \ ; 17
                         (/ 0.84706,0.08235,0.18431 /), \ ; 18
                         (/ 0.64706,0.00000,0.12941 /) /) ; 19

;  gsn_define_colormap(wks,BlueDarkRed18_WIM)

  res = True

  res@gsnMaximize          = True
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@xyLineThicknessF     = 3.4
  res@xyLineColors         = (/ "black","darkorange1","purple4", \
                                "deepskyblue" /)
  res@xyDashPatterns       = (/ 0,1,3,8 /)
  res@tiYAxisString        = "T Std Dev"
  res@gsnLeftString        = YYYY+" "+CSS+" CSS"
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

  plot = gsn_csm_y(wks,T_stddev_phsim,res)

  genres                    = True
  genres@XPosPercent        = 19
  genres@YPosPercent        = 91
  lineres                   = True
  lineres@lgLineThicknesses = 3.4
  lineres@lgDashIndexes     = res@xyDashPatterns
  lineres@lgLineColors      = res@xyLineColors
  textres                   = True
  textres@lgLabels          = pbl

;  drawNDCGrid(wks)
  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  res@tiYAxisString         = "q~B~v~N~ Std Dev"
  res@gsnRightString        = "kg kg~S~-1~N~"

  genres@XPosPercent        = 22
  genres@YPosPercent        = 89

  plot = gsn_csm_y(wks,qv_stddev_phsim,res)

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  res@tiYAxisString         = "u Std Dev"
  res@gsnRightString        = "m s~S~-1~N~"

  genres@XPosPercent        = 18
  genres@YPosPercent        = 91

  plot = gsn_csm_y(wks,u_stddev_phsim,res)

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  res@tiYAxisString         = "v Std Dev"
  res@gsnRightString        = "m s~S~-1~N~"

  genres@XPosPercent        = 75
  genres@YPosPercent        = 91

  plot = gsn_csm_y(wks,v_stddev_phsim,res)

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  res@tiYAxisString         = "PBLH Std Dev"
  res@gsnRightString        = "m"

  genres@XPosPercent        = 76
  genres@YPosPercent        = 91

  plot = gsn_csm_y(wks,pblh_stddev_phsim,res)

  draw(plot)
  simple_legend_ndc(wks,genres,lineres,textres)
  frame(wks)

  print("Finished: "+systemfunc("date"))

end

