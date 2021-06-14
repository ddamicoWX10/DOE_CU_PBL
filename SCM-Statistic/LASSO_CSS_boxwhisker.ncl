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

  pblh          = new((/ nss,ns,nt,1 /),float)
  pblh(0,:,:,:) = fHI[:]->atmosphere_boundary_layer_thickness
  pblh(1,:,:,:) = fMD[:]->atmosphere_boundary_layer_thickness
  pblh(2,:,:,:) = fLO[:]->atmosphere_boundary_layer_thickness

  pblh!0 = "CldSkl"

  srn = new((/ ns,nt /),float)
  do i=0,ns-1,1
    do j=0,nt-1,1
      srn(i,j) = max(pblh(:,i,j,0)) - min(pblh(:,i,j,0))
    end do
  end do

  q25 = round(nt*0.25,3) - 1
  q75 = round(nt*0.75,3) - 1

  do i=0,ns-1,1
    qsort(srn(i,:))
  end do

  css_quar = new((/ ns,5 /),float)
  do i=0,ns-1,1
    css_quar(i,:) = (/ min(srn(i,:)),srn(i,q25),dim_median(srn(i,:)), \
                       srn(i,q75),max(srn(i,:)) /)
  end do

  xax = ispan(0,ns-1,1)

; Open workstation for plotting
  wks = gsn_open_wks(gtype,pbl+"_CSSRange")

  res = True

  res@gsnMaximize          = True
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
  res@tmXBLabelAngleF       = -82.
  res@tmXBLabelFontHeightF  = 0.0127
  res@tmYRBorderOn          = True
  res@tmXTBorderOn          = True
  res@tmYLMajorLengthF      = 0.012
  res@tmYLMinorLengthF      = 0.009
  res@tmXBMajorLengthF      = 0.001
  res@trYMaxF               = 5200.

  lineres = True

  lineres@gsLineThicknessF  = 2.5

  boxOpts = True

  boxOpts@boxWidth          = 0.74

  tres = True

  tres@txFontHeightF        = 0.019

  plot = boxplot(wks,xax,css_quar,boxOpts,res,lineres)

  gsn_text_ndc(wks,"PBLH Range",0.72,0.82,tres)
  if (pbl .eq. "satmedmf") then
    gsn_text_ndc(wks,YYYY+" "+pbl,0.29,0.82,tres)
  else if (pbl .eq. "MYNN") then
    gsn_text_ndc(wks,YYYY+" "+pbl,0.27,0.82,tres)
  else
    gsn_text_ndc(wks,YYYY+" "+pbl,0.265,0.82,tres)
  end if
  end if
  gsn_text_ndc(wks,"Compares HI, MD, and LO CSS",0.50,0.10,tres)

  draw(plot)
;  drawNDCGrid(wks)
  frame(wks)

  print("Finished: "+systemfunc("date"))

end

