load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

; User modification area
  cldskl = "LO"
  YYYY   = "2017"
  MM     = "09"
  DD     = "24"

  projdir = "/gpfs/wolf/atm118/proj-shared/NCAR_CU/DOE/"
; End user modification area

  dir = projdir + cldskl + "/" + YYYY + MM + DD

  print("Started: "+systemfunc("date"))

  SID = systemfunc("ls "+dir)
  wrf = systemfunc("ls "+dir+"/sim*")

  if (dimsizes(SID) .eq. 1) then
    wrf_f = addfile(dir+"/"+SID+"/"+wrf,"r")
  else
    wrf_f = addfile(dir+"/"+SID(1)+"/"+wrf(4),"r")
  end if

; Add time variable
  wtim = wrf_user_getvar(wrf_f,"times",-1)

  yr = toint(str_get_cols(wtim,0,3))
  mo = toint(str_get_cols(wtim,5,6))
  dy = toint(str_get_cols(wtim,8,9))
  hr = toint(str_get_cols(wtim,11,12))
  mn = toint(str_get_cols(wtim,14,15))
  ss = toint(str_get_cols(wtim,17,18))

  tunit = "seconds since "+YYYY+"-"+MM+"-"+DD+" 12:00:00"

  Time = cd_inv_calendar(yr,mo,dy,hr,mn,ss,tunit,0)

; Gather all non "CSV_*" variables, no need for any other modification
  CST_CLDLOW     = wrf_f->CST_CLDLOW
  CST_CLDTOT     = wrf_f->CST_CLDTOT
  CST_LWP        = wrf_f->CST_LWP
  CST_IWP        = wrf_f->CST_IWP
  CST_PRECW      = wrf_f->CST_PRECW
  CST_TKE        = wrf_f->CST_TKE
  CST_TSAIR      = wrf_f->CST_TSAIR
  CST_PS         = wrf_f->CST_PS
  CST_PRECT      = wrf_f->CST_PRECT
  CST_SH         = wrf_f->CST_SH
  CST_LH         = wrf_f->CST_LH
  CST_FSNTC      = wrf_f->CST_FSNTC
  CST_FSNT       = wrf_f->CST_FSNT
  CST_FLNTC      = wrf_f->CST_FLNTC
  CST_FLNT       = wrf_f->CST_FLNT
  CST_FSNSC      = wrf_f->CST_FSNSC
  CST_FSNS       = wrf_f->CST_FSNS
  CST_FLNSC      = wrf_f->CST_FLNSC
  CST_FLNS       = wrf_f->CST_FLNS
  CST_SWINC      = wrf_f->CST_SWINC
  CST_TSK        = wrf_f->CST_TSK
  CST_UST        = wrf_f->CST_UST
  CSP_Z          = wrf_f->CSP_Z
  CSP_Z8W        = wrf_f->CSP_Z8W
  CSP_DZ8W       = wrf_f->CSP_DZ8W
  CSP_U          = wrf_f->CSP_U
  CSP_V          = wrf_f->CSP_V
  CSP_W          = wrf_f->CSP_W
  CSP_P          = wrf_f->CSP_P
  CSP_TH         = wrf_f->CSP_TH
  CSP_THV        = wrf_f->CSP_THV
  CSP_THL        = wrf_f->CSP_THL
  CSP_QV         = wrf_f->CSP_QV
  CSP_QC         = wrf_f->CSP_QC
  CSP_QI         = wrf_f->CSP_QI
  CSP_QL         = wrf_f->CSP_QL
  CSP_QF         = wrf_f->CSP_QF
  CSP_QT         = wrf_f->CSP_QT
  CSP_LWC        = wrf_f->CSP_LWC
  CSP_IWC        = wrf_f->CSP_IWC
  CSP_SPEQV      = wrf_f->CSP_SPEQV
  CSP_A_CL       = wrf_f->CSP_A_CL
  CSP_RHO        = wrf_f->CSP_RHO
  CSP_U2         = wrf_f->CSP_U2
  CSP_V2         = wrf_f->CSP_V2
  CSP_U2V2       = wrf_f->CSP_U2V2
  CSP_W2         = wrf_f->CSP_W2
  CSP_W3         = wrf_f->CSP_W3
  CSP_WSKEW      = wrf_f->CSP_WSKEW
  CSP_UW         = wrf_f->CSP_UW
  CSP_VW         = wrf_f->CSP_VW
  CSP_WTH        = wrf_f->CSP_WTH
  CSP_WTHV       = wrf_f->CSP_WTHV
  CSP_WTHL       = wrf_f->CSP_WTHL
  CSP_WQV        = wrf_f->CSP_WQV
  CSP_WQC        = wrf_f->CSP_WQC
  CSP_WQI        = wrf_f->CSP_WQI
  CSP_WQL        = wrf_f->CSP_WQL
  CSP_WQF        = wrf_f->CSP_WQF
  CSP_WQT        = wrf_f->CSP_WQT
  CSP_UW_SGS     = wrf_f->CSP_UW_SGS
  CSP_VW_SGS     = wrf_f->CSP_VW_SGS
  CSP_WTH_SGS    = wrf_f->CSP_WTH_SGS
  CSP_WTHV_SGS   = wrf_f->CSP_WTHV_SGS
  CSP_WTHL_SGS   = wrf_f->CSP_WTHL_SGS
  CSP_WQV_SGS    = wrf_f->CSP_WQV_SGS
  CSP_WQC_SGS    = wrf_f->CSP_WQC_SGS
  CSP_WQI_SGS    = wrf_f->CSP_WQI_SGS
  CSP_WQL_SGS    = wrf_f->CSP_WQL_SGS
  CSP_WQF_SGS    = wrf_f->CSP_WQF_SGS
  CSP_WQT_SGS    = wrf_f->CSP_WQT_SGS
  CSP_SEDFQC     = wrf_f->CSP_SEDFQC
  CSP_SEDFQR     = wrf_f->CSP_SEDFQR
  CSP_THDT_COND  = wrf_f->CSP_THDT_COND
  CSP_THDT_LW    = wrf_f->CSP_THDT_LW
  CSP_THDT_SW    = wrf_f->CSP_THDT_SW
  CSP_THDT_LS    = wrf_f->CSP_THDT_LS
  CSP_QVDT_PR    = wrf_f->CSP_QVDT_PR
  CSP_QVDT_COND  = wrf_f->CSP_QVDT_COND
  CSP_QVDT_LS    = wrf_f->CSP_QVDT_LS
  CSP_QCDT_PR    = wrf_f->CSP_QCDT_PR
  CSP_QCDT_SED   = wrf_f->CSP_QCDT_SED
  CSP_QRDT_SED   = wrf_f->CSP_QRDT_SED
  CSP_THDT_LSHOR = wrf_f->CSP_THDT_LSHOR
  CSP_QVDT_LSHOR = wrf_f->CSP_QVDT_LSHOR
  CSP_THDT_LSVER = wrf_f->CSP_THDT_LSVER
  CSP_QVDT_LSVER = wrf_f->CSP_QVDT_LSVER
  CSP_THDT_LSRLX = wrf_f->CSP_THDT_LSRLX
  CSP_QVDT_LSRLX = wrf_f->CSP_QVDT_LSRLX
  CSP_UDT_LS     = wrf_f->CSP_UDT_LS
  CSP_VDT_LS     = wrf_f->CSP_VDT_LS
  CSP_UDT_LSVER  = wrf_f->CSP_UDT_LSVER
  CSP_VDT_LSVER  = wrf_f->CSP_VDT_LSVER
  CSP_UDT_LSRLX  = wrf_f->CSP_UDT_LSRLX
  CSP_VDT_LSRLX  = wrf_f->CSP_VDT_LSRLX
  CSP_SWUPF      = wrf_f->CSP_SWUPF
  CSP_SWDNF      = wrf_f->CSP_SWDNF
  CSP_LWUPF      = wrf_f->CSP_LWUPF
  CSP_LWDNF      = wrf_f->CSP_LWDNF
  CSP_TKE_RS     = wrf_f->CSP_TKE_RS
  CSP_TKE_SH     = wrf_f->CSP_TKE_SH
  CSP_TKE_BU     = wrf_f->CSP_TKE_BU
  CSP_TKE_TR     = wrf_f->CSP_TKE_TR
  CSP_TKE_DI     = wrf_f->CSP_TKE_DI
  CSP_TKE_SGS    = wrf_f->CSP_TKE_SGS
  CSP_W_C        = wrf_f->CSP_W_C
  CSP_THL_C      = wrf_f->CSP_THL_C
  CSP_QT_C       = wrf_f->CSP_QT_C
  CSP_QV_C       = wrf_f->CSP_QV_C
  CSP_QL_C       = wrf_f->CSP_QL_C
  CSP_QF_C       = wrf_f->CSP_QF_C
  CSP_QC_C       = wrf_f->CSP_QC_C
  CSP_QI_C       = wrf_f->CSP_QI_C
  CSP_QNC_C      = wrf_f->CSP_QNC_C
  CSP_THV_C      = wrf_f->CSP_THV_C
  CSP_W2_C       = wrf_f->CSP_W2_C
  CSP_AW_C       = wrf_f->CSP_AW_C
  CSP_AWTHL_C    = wrf_f->CSP_AWTHL_C
  CSP_AWQT_C     = wrf_f->CSP_AWQT_C
  CSP_AWQV_C     = wrf_f->CSP_AWQV_C
  CSP_AWQL_C     = wrf_f->CSP_AWQL_C
  CSP_AWQF_C     = wrf_f->CSP_AWQF_C
  CSP_AWQC_C     = wrf_f->CSP_AWQC_C
  CSP_AWQI_C     = wrf_f->CSP_AWQI_C
  CSP_AWTHV_C    = wrf_f->CSP_AWTHV_C
  CSP_A_CC       = wrf_f->CSP_A_CC
  CSP_W_CC       = wrf_f->CSP_W_CC
  CSP_THL_CC     = wrf_f->CSP_THL_CC
  CSP_QT_CC      = wrf_f->CSP_QT_CC
  CSP_QV_CC      = wrf_f->CSP_QV_CC
  CSP_QL_CC      = wrf_f->CSP_QL_CC
  CSP_QF_CC      = wrf_f->CSP_QF_CC
  CSP_QC_CC      = wrf_f->CSP_QC_CC
  CSP_QI_CC      = wrf_f->CSP_QI_CC
  CSP_THV_CC     = wrf_f->CSP_THV_CC
  CSP_W2_CC      = wrf_f->CSP_W2_CC
  CSP_AW_CC      = wrf_f->CSP_AW_CC
  CSP_AWTHL_CC   = wrf_f->CSP_AWTHL_CC
  CSP_AWQT_CC    = wrf_f->CSP_AWQT_CC
  CSP_AWQV_CC    = wrf_f->CSP_AWQV_CC
  CSP_AWQL_CC    = wrf_f->CSP_AWQL_CC
  CSP_AWQF_CC    = wrf_f->CSP_AWQF_CC
  CSP_AWQC_CC    = wrf_f->CSP_AWQC_CC
  CSP_AWQI_CC    = wrf_f->CSP_AWQI_CC
  CSP_AWTHV_CC   = wrf_f->CSP_AWTHV_CC
  CSP_SIGC_THL   = wrf_f->CSP_SIGC_THL
  CSP_SIGC_QT    = wrf_f->CSP_SIGC_QT
  CSP_SIGC_QL    = wrf_f->CSP_SIGC_QL
  CSP_SIGC_QF    = wrf_f->CSP_SIGC_QF
  CSP_SIGC_QC    = wrf_f->CSP_SIGC_QC
  CSP_SIGC_QI    = wrf_f->CSP_SIGC_QI
  CSP_SIGC_THV   = wrf_f->CSP_SIGC_THV
  CSP_TH2        = wrf_f->CSP_TH2
  CSP_THV2       = wrf_f->CSP_THV2
  CSP_THL2       = wrf_f->CSP_THL2
  CSP_QV2        = wrf_f->CSP_QV2
  CSP_SMAXACTMAX = wrf_f->CSP_SMAXACTMAX
  CSP_RMINACTMIN = wrf_f->CSP_RMINACTMIN
  CSP_WMAX       = wrf_f->CSP_WMAX
  CSP_WMIN       = wrf_f->CSP_WMIN
  CSS_LWP        = wrf_f->CSS_LWP
  CSS_IWP        = wrf_f->CSS_IWP
  CSS_CLDTOT     = wrf_f->CSS_CLDTOT
  CSS_CLDLOW     = wrf_f->CSS_CLDLOW

  bottom_top      = ispan(1,226,1)
  bottom_top_stag = ispan(1,227,1)
  south_north     = ispan(1,250,1)
  west_east       = south_north

  Atts = getvaratts(wrf_f)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Writing netCDF output of all variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  setfileoption("nc","FileStructure","Advanced")
;  setfileoption("nc","Format","NetCDF4")
  setfileoption("nc","DefineMode",True)

  fout = "wrfstat_d01_subset_"+YYYY+"-"+MM+"-"+DD+"_12:00:00.nc"

  system("/bin/rm -fv "+fout)
  fo = addfile(fout,"c")

;  setfileoption(fo,"DefineMode",True)

;  print("Writing "+fout+" @ "+systemfunc("date"))

  fAtt = True

  fAtt@TITLE                                = "Subset of OUTPUT FROM WRF "+ \
                                              "V3.8.1 MODEL"
  fAtt@creation_date                        = systemfunc("date")
  fAtt@START_DATE                           = wrf_f@$Atts(1)$
  fAtt@WESTEAST_GRID_DIMENSION              = wrf_f@$Atts(2)$
  fAtt@SOUTHNORTH_GRID_DIMENSION            = wrf_f@$Atts(3)$
  fAtt@BOTTOMTOP_GRID_DIMENSION             = wrf_f@$Atts(4)$
  fAtt@DX                                   = wrf_f@$Atts(5)$
  fAtt@DY                                   = wrf_f@$Atts(6)$
  fAtt@GRIDTYPE                             = wrf_f@$Atts(7)$
  fAtt@DIFF_OPT                             = wrf_f@$Atts(8)$
  fAtt@KM_OPT                               = wrf_f@$Atts(9)$
  fAtt@DAMP_OPT                             = wrf_f@$Atts(10)$
  fAtt@DAMPCOEF                             = wrf_f@$Atts(11)$
  fAtt@KHDIF                                = wrf_f@$Atts(12)$
  fAtt@KVDIF                                = wrf_f@$Atts(13)$
  fAtt@MP_PHYSICS                           = wrf_f@$Atts(14)$
  fAtt@RA_LW_PHYSICS                        = wrf_f@$Atts(15)$
  fAtt@RA_SW_PHYSICS                        = wrf_f@$Atts(16)$
  fAtt@SF_SFCLAY_PHYSICS                    = wrf_f@$Atts(17)$
  fAtt@SF_SURFACE_PHYSICS                   = wrf_f@$Atts(18)$
  fAtt@BL_PBL_PHYSICS                       = wrf_f@$Atts(19)$
  fAtt@CU_PHYSICS                           = wrf_f@$Atts(20)$
  fAtt@SF_LAKE_PHYSICS                      = wrf_f@$Atts(21)$
  fAtt@SURFACE_INPUT_SOURCE                 = wrf_f@$Atts(22)$
  fAtt@SST_UPDATE                           = wrf_f@$Atts(23)$
  fAtt@GRID_FDDA                            = wrf_f@$Atts(24)$
  fAtt@GFDDA_INTERVAL_M                     = wrf_f@$Atts(25)$
  fAtt@GFDDA_END_H                          = wrf_f@$Atts(26)$
  fAtt@GRID_SFDDA                           = wrf_f@$Atts(27)$
  fAtt@SGFDDA_INTERVAL_M                    = wrf_f@$Atts(28)$
  fAtt@SGFDDA_END_H                         = wrf_f@$Atts(29)$
  fAtt@HYPSOMETRIC_OPT                      = wrf_f@$Atts(30)$
  fAtt@USE_THETA_M                          = wrf_f@$Atts(31)$
  fAtt@WESTEAST_PATCH_START_UNSTAG          = wrf_f@$Atts(32)$
  fAtt@WESTEAST_PATCH_END_UNSTAG            = wrf_f@$Atts(33)$
  fAtt@WESTEAST_PATCH_START_STAG            = wrf_f@$Atts(34)$
  fAtt@WESTEAST_PATCH_END_STAG              = wrf_f@$Atts(35)$
  fAtt@SOUTHNORTH_PATCH_START_UNSTAG        = wrf_f@$Atts(36)$
  fAtt@SOUTHNORTH_PATCH_END_UNSTAG          = wrf_f@$Atts(37)$
  fAtt@SOUTHNORTH_PATCH_START_STAG          = wrf_f@$Atts(38)$
  fAtt@SOUTHNORTH_PATCH_END_STAG            = wrf_f@$Atts(39)$
  fAtt@BOTTOMTOP_PATCH_START_UNSTAG         = wrf_f@$Atts(40)$
  fAtt@BOTTOMTOP_PATCH_END_UNSTAG           = wrf_f@$Atts(41)$
  fAtt@BOTTOMTOP_PATCH_START_STAG           = wrf_f@$Atts(42)$
  fAtt@BOTTOMTOP_PATCH_END_STAG             = wrf_f@$Atts(43)$
  fAtt@GRID_ID                              = wrf_f@$Atts(44)$
  fAtt@PARENT_ID                            = wrf_f@$Atts(45)$
  fAtt@I_PARENT_START                       = wrf_f@$Atts(46)$
  fAtt@J_PARENT_START                       = wrf_f@$Atts(47)$
  fAtt@PARENT_GRID_RATIO                    = wrf_f@$Atts(48)$
  fAtt@DT                                   = wrf_f@$Atts(49)$
  fAtt@CEN_LAT                              = wrf_f@$Atts(50)$
  fAtt@CEN_LON                              = wrf_f@$Atts(51)$ 
  fAtt@TRUELAT1                             = wrf_f@$Atts(52)$
  fAtt@TRUELAT2                             = wrf_f@$Atts(53)$
  fAtt@MOAD_CEN_LAT                         = wrf_f@$Atts(54)$
  fAtt@STAND_LON                            = wrf_f@$Atts(55)$
  fAtt@POLE_LAT                             = wrf_f@$Atts(56)$
  fAtt@POLE_LON                             = wrf_f@$Atts(57)$
  fAtt@GMT                                  = wrf_f@$Atts(58)$
  fAtt@JULYR                                = wrf_f@$Atts(59)$
  fAtt@JULDAY                               = wrf_f@$Atts(60)$
  fAtt@MAP_PROJ                             = wrf_f@$Atts(61)$
  fAtt@MAP_PROJ_CHAR                        = wrf_f@$Atts(62)$
  fAtt@MMINLU                               = wrf_f@$Atts(63)$
  fAtt@NUM_LAND_CAT                         = wrf_f@$Atts(64)$
  fAtt@ISWATER                              = wrf_f@$Atts(65)$
  fAtt@ISLAKE                               = wrf_f@$Atts(66)$
  fAtt@ISICE                                = wrf_f@$Atts(67)$
  fAtt@ISURBAN                              = wrf_f@$Atts(68)$
  fAtt@ISOILWATER                           = wrf_f@$Atts(69)$
  fAtt@doi                                  = wrf_f@$Atts(70)$
  fAtt@contacts                             = wrf_f@$Atts(71)$
  fAtt@process_version                      = wrf_f@$Atts(72)$
  fAtt@site_id                              = wrf_f@$Atts(73)$
  fAtt@facility_id                          = wrf_f@$Atts(74)$
  fAtt@location_description                 = wrf_f@$Atts(75)$
  fAtt@date                                 = wrf_f@$Atts(76)$
  fAtt@site                                 = wrf_f@$Atts(77)$
  fAtt@fac                                  = wrf_f@$Atts(78)$
  fAtt@simulation_id_number                 = wrf_f@$Atts(79)$
  fAtt@model_type                           = wrf_f@$Atts(80)$
  fAtt@model_version                        = wrf_f@$Atts(81)$
  fAtt@output_domain_size                   = wrf_f@$Atts(82)$
  fAtt@output_number_of_levels              = wrf_f@$Atts(83)$
  fAtt@output_horizontal_grid_spacing       = wrf_f@$Atts(84)$
  fAtt@config_large_scale_forcing           = wrf_f@$Atts(85)$
  fAtt@config_large_scale_forcing_scale     = wrf_f@$Atts(86)$
  fAtt@config_large_scale_forcing_specifics = wrf_f@$Atts(87)$
  fAtt@config_surface_treatment             = wrf_f@$Atts(88)$
  fAtt@config_surface_treatment_specifics   = wrf_f@$Atts(89)$
  fAtt@config_initial_condition             = wrf_f@$Atts(90)$
  fAtt@config_initial_condition_specifics   = wrf_f@$Atts(91)$
  fAtt@config_aerosol                       = wrf_f@$Atts(92)$
  fAtt@config_forecast_time                 = wrf_f@$Atts(93)$
  fAtt@config_boundary_method               = wrf_f@$Atts(94)$
  fAtt@config_microphysics                  = wrf_f@$Atts(95)$
  fAtt@config_nickname                      = wrf_f@$Atts(96)$
  fAtt@simulation_origin_host               = wrf_f@$Atts(97)$
  fAtt@model_github_hash                    = wrf_f@$Atts(98)$
  fAtt@subset_creator                       = "D DAmico (damico@ucar.edu)"
  fAtt@subset_script                        = "wrfstat_subset.ncl"

  fileattdef(fo,fAtt)

; Define dimensions
  dimNames = (/ "Time","bottom_top","bottom_top_stag","south_north", \
                "west_east" /)
  dimSizes = (/ dimsizes(Time),dimsizes(bottom_top), \
                dimsizes(bottom_top_stag),dimsizes(south_north), \
                dimsizes(west_east) /)
  dimUnlim = (/ True,False,False,False,False /)

  filedimdef(fo,dimNames,dimSizes,dimUnlim)

  filevardef(fo,"Time",typeof(Time),"Time")
  filevarattdef(fo,"Time",Time)
  fo->Time = (/ Time /)

  filevardef(fo,"CST_CLDLOW",typeof(CST_CLDLOW),"Time")
  filevarattdef(fo,"CST_CLDLOW",CST_CLDLOW)
  fo->CST_CLDLOW = (/ CST_CLDLOW /)

  filevardef(fo,"CST_CLDTOT",typeof(CST_CLDTOT),"Time")
  filevarattdef(fo,"CST_CLDTOT",CST_CLDTOT)
  fo->CST_CLDTOT = (/ CST_CLDTOT /)

  filevardef(fo,"CST_LWP",typeof(CST_LWP),"Time")
  filevarattdef(fo,"CST_LWP",CST_LWP)
  fo->CST_LWP = (/ CST_LWP /)

  filevardef(fo,"CST_IWP",typeof(CST_IWP),"Time")
  filevarattdef(fo,"CST_IWP",CST_IWP)
  fo->CST_IWP = (/ CST_IWP /)

  filevardef(fo,"CST_PRECW",typeof(CST_PRECW),"Time")
  filevarattdef(fo,"CST_PRECW",CST_PRECW)
  fo->CST_PRECW = (/ CST_PRECW /)

  filevardef(fo,"CST_TKE",typeof(CST_TKE),"Time")
  filevarattdef(fo,"CST_TKE",CST_TKE)
  fo->CST_TKE = (/ CST_TKE /)

  filevardef(fo,"CST_TSAIR",typeof(CST_TSAIR),"Time")
  filevarattdef(fo,"CST_TSAIR",CST_TSAIR)
  fo->CST_TSAIR = (/ CST_TSAIR /)

  filevardef(fo,"CST_PS",typeof(CST_PS),"Time")
  filevarattdef(fo,"CST_PS",CST_PS)
  fo->CST_PS = (/ CST_PS /)

  filevardef(fo,"CST_PRECT",typeof(CST_PRECT),"Time")
  filevarattdef(fo,"CST_PRECT",CST_PRECT)
  fo->CST_PRECT = (/ CST_PRECT /)

  filevardef(fo,"CST_SH",typeof(CST_SH),"Time")
  filevarattdef(fo,"CST_SH",CST_SH)
  fo->CST_SH = (/ CST_SH /)

  filevardef(fo,"CST_LH",typeof(CST_LH),"Time")
  filevarattdef(fo,"CST_LH",CST_LH)
  fo->CST_LH = (/ CST_LH /)

  filevardef(fo,"CST_FSNTC",typeof(CST_FSNTC),"Time")
  filevarattdef(fo,"CST_FSNTC",CST_FSNTC)
  fo->CST_FSNTC = (/ CST_FSNTC /)

  filevardef(fo,"CST_FSNT",typeof(CST_FSNT),"Time")
  filevarattdef(fo,"CST_FSNT",CST_FSNT)
  fo->CST_FSNT = (/ CST_FSNT /)

  filevardef(fo,"CST_FLNTC",typeof(CST_FLNTC),"Time")
  filevarattdef(fo,"CST_FLNTC",CST_FLNTC)
  fo->CST_FLNTC = (/ CST_FLNTC /)

  filevardef(fo,"CST_FLNT",typeof(CST_FLNT),"Time")
  filevarattdef(fo,"CST_FLNT",CST_FLNT)
  fo->CST_FLNT = (/ CST_FLNT /)

  filevardef(fo,"CST_FSNSC",typeof(CST_FSNSC),"Time")
  filevarattdef(fo,"CST_FSNSC",CST_FSNSC)
  fo->CST_FSNSC = (/ CST_FSNSC /)

  filevardef(fo,"CST_FSNS",typeof(CST_FSNS),"Time")
  filevarattdef(fo,"CST_FSNS",CST_FSNS)
  fo->CST_FSNS = (/ CST_FSNS /)

  filevardef(fo,"CST_FLNSC",typeof(CST_FLNSC),"Time")
  filevarattdef(fo,"CST_FLNSC",CST_FLNSC)
  fo->CST_FLNSC = (/ CST_FLNSC /)

  filevardef(fo,"CST_FLNS",typeof(CST_FLNS),"Time")
  filevarattdef(fo,"CST_FLNS",CST_FLNS)
  fo->CST_FLNS = (/ CST_FLNS /)

  filevardef(fo,"CST_SWINC",typeof(CST_SWINC),"Time")
  filevarattdef(fo,"CST_SWINC",CST_SWINC)
  fo->CST_SWINC = (/ CST_SWINC /)

  filevardef(fo,"CST_TSK",typeof(CST_TSK),"Time")
  filevarattdef(fo,"CST_TSK",CST_TSK)
  fo->CST_TSK = (/ CST_TSK /)

  filevardef(fo,"CST_UST",typeof(CST_UST),"Time")
  filevarattdef(fo,"CST_UST",CST_UST)
  fo->CST_UST = (/ CST_UST /)

  filevardef(fo,"CSP_Z",typeof(CSP_Z),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_Z",CSP_Z)
  fo->CSP_Z = (/ CSP_Z /)

  filevardef(fo,"CSP_Z8W",typeof(CSP_Z8W),(/ "Time","bottom_top_stag" /))
  filevarattdef(fo,"CSP_Z8W",CSP_Z8W)
  fo->CSP_Z8W = (/ CSP_Z8W /)

  filevardef(fo,"CSP_DZ8W",typeof(CSP_DZ8W),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_DZ8W",CSP_DZ8W)
  fo->CSP_DZ8W = (/ CSP_DZ8W /)

  filevardef(fo,"CSP_U",typeof(CSP_U),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_U",CSP_U)
  fo->CSP_U = (/ CSP_U /)

  filevardef(fo,"CSP_V",typeof(CSP_V),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_V",CSP_V)
  fo->CSP_V = (/ CSP_V /)

  filevardef(fo,"CSP_W",typeof(CSP_W),(/ "Time","bottom_top_stag" /))
  filevarattdef(fo,"CSP_W",CSP_W)
  fo->CSP_W = (/ CSP_W /)

  filevardef(fo,"CSP_P",typeof(CSP_P),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_P",CSP_P)
  fo->CSP_P = (/ CSP_P /)

  filevardef(fo,"CSP_TH",typeof(CSP_TH),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_TH",CSP_TH)
  fo->CSP_TH = (/ CSP_TH /)

  filevardef(fo,"CSP_THV",typeof(CSP_THV),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THV",CSP_THV)
  fo->CSP_THV = (/ CSP_THV /)

  filevardef(fo,"CSP_THL",typeof(CSP_THL),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THL",CSP_THL)
  fo->CSP_THL = (/ CSP_THL /)

  filevardef(fo,"CSP_QV",typeof(CSP_QV),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QV",CSP_QV)
  fo->CSP_QV = (/ CSP_QV /)

  filevardef(fo,"CSP_QC",typeof(CSP_QC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QC",CSP_QC)
  fo->CSP_QC = (/ CSP_QC /)

  filevardef(fo,"CSP_QI",typeof(CSP_QI),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QI",CSP_QI)
  fo->CSP_QI = (/ CSP_QI /)

  filevardef(fo,"CSP_QL",typeof(CSP_QL),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QL",CSP_QL)
  fo->CSP_QL = (/ CSP_QL /)

  filevardef(fo,"CSP_QF",typeof(CSP_QF),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QF",CSP_QF)
  fo->CSP_QF = (/ CSP_QF /)

  filevardef(fo,"CSP_QT",typeof(CSP_QT),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QT",CSP_QT)
  fo->CSP_QT = (/ CSP_QT /)

  filevardef(fo,"CSP_LWC",typeof(CSP_LWC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_LWC",CSP_LWC)
  fo->CSP_LWC = (/ CSP_LWC /)

  filevardef(fo,"CSP_IWC",typeof(CSP_IWC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_IWC",CSP_IWC)
  fo->CSP_IWC = (/ CSP_IWC /)

  filevardef(fo,"CSP_SPEQV",typeof(CSP_SPEQV),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SPEQV",CSP_SPEQV)
  fo->CSP_SPEQV = (/ CSP_SPEQV /)

  filevardef(fo,"CSP_A_CL",typeof(CSP_A_CL),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_A_CL",CSP_A_CL)
  fo->CSP_A_CL = (/ CSP_A_CL /)

  filevardef(fo,"CSP_RHO",typeof(CSP_RHO),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_RHO",CSP_RHO)
  fo->CSP_RHO = (/ CSP_RHO /)

  filevardef(fo,"CSP_U2",typeof(CSP_U2),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_U2",CSP_U2)
  fo->CSP_U2 = (/ CSP_U2 /)

  filevardef(fo,"CSP_V2",typeof(CSP_V2),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_V2",CSP_V2)
  fo->CSP_V2 = (/ CSP_V2 /)

  filevardef(fo,"CSP_U2V2",typeof(CSP_U2V2),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_U2V2",CSP_U2V2)
  fo->CSP_U2V2 = (/ CSP_U2V2 /)

  filevardef(fo,"CSP_W2",typeof(CSP_W2),(/ "Time","bottom_top_stag" /))
  filevarattdef(fo,"CSP_W2",CSP_W2)
  fo->CSP_W2 = (/ CSP_W2 /)

  filevardef(fo,"CSP_W3",typeof(CSP_W3),(/ "Time","bottom_top_stag" /))
  filevarattdef(fo,"CSP_W3",CSP_W3)
  fo->CSP_W3 = (/ CSP_W3 /)

  filevardef(fo,"CSP_WSKEW",typeof(CSP_WSKEW),(/ "Time","bottom_top_stag" /))
  filevarattdef(fo,"CSP_WSKEW",CSP_WSKEW)
  fo->CSP_WSKEW = (/ CSP_WSKEW /)

  filevardef(fo,"CSP_UW",typeof(CSP_UW),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_UW",CSP_UW)
  fo->CSP_UW = (/ CSP_UW /)

  filevardef(fo,"CSP_VW",typeof(CSP_VW),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_VW",CSP_VW)
  fo->CSP_VW = (/ CSP_VW /)

  filevardef(fo,"CSP_WTH",typeof(CSP_WTH),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WTH",CSP_WTH)
  fo->CSP_WTH = (/ CSP_WTH /)

  filevardef(fo,"CSP_WTHV",typeof(CSP_WTHV),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WTHV",CSP_WTHV)
  fo->CSP_WTHV = (/ CSP_WTHV /)

  filevardef(fo,"CSP_WTHL",typeof(CSP_WTHL),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WTHL",CSP_WTHL)
  fo->CSP_WTHL = (/ CSP_WTHL /)

  filevardef(fo,"CSP_WQV",typeof(CSP_WQV),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQV",CSP_WQV)
  fo->CSP_WQV = (/ CSP_WQV /)

  filevardef(fo,"CSP_WQC",typeof(CSP_WQC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQC",CSP_WQC)
  fo->CSP_WQC = (/ CSP_WQC /)

  filevardef(fo,"CSP_WQI",typeof(CSP_WQI),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQI",CSP_WQI)
  fo->CSP_WQI = (/ CSP_WQI /)

  filevardef(fo,"CSP_WQL",typeof(CSP_WQL),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQL",CSP_WQL)
  fo->CSP_WQL = (/ CSP_WQL /)

  filevardef(fo,"CSP_WQF",typeof(CSP_WQF),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQF",CSP_WQF)
  fo->CSP_WQF = (/ CSP_WQF /)

  filevardef(fo,"CSP_WQT",typeof(CSP_WQT),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQT",CSP_WQT)
  fo->CSP_WQT = (/ CSP_WQT /)

  filevardef(fo,"CSP_UW_SGS",typeof(CSP_UW_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_UW_SGS",CSP_UW_SGS)
  fo->CSP_UW_SGS = (/ CSP_UW_SGS /)

  filevardef(fo,"CSP_VW_SGS",typeof(CSP_VW_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_VW_SGS",CSP_VW_SGS)
  fo->CSP_VW_SGS = (/ CSP_VW_SGS /)

  filevardef(fo,"CSP_WTH_SGS",typeof(CSP_WTH_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WTH_SGS",CSP_WTH_SGS)
  fo->CSP_WTH_SGS = (/ CSP_WTH_SGS /)

  filevardef(fo,"CSP_WTHV_SGS",typeof(CSP_WTHV_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WTHV_SGS",CSP_WTHV_SGS)
  fo->CSP_WTHV_SGS = (/ CSP_WTHV_SGS /)

  filevardef(fo,"CSP_WTHL_SGS",typeof(CSP_WTHL_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WTHL_SGS",CSP_WTHL_SGS)
  fo->CSP_WTHL_SGS = (/ CSP_WTHL_SGS /)

  filevardef(fo,"CSP_WQV_SGS",typeof(CSP_WQV_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQV_SGS",CSP_WQV_SGS)
  fo->CSP_WQV_SGS = (/ CSP_WQV_SGS /)

  filevardef(fo,"CSP_WQC_SGS",typeof(CSP_WQC_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQC_SGS",CSP_WQC_SGS)
  fo->CSP_WQC_SGS = (/ CSP_WQC_SGS /)

  filevardef(fo,"CSP_WQI_SGS",typeof(CSP_WQI_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQI_SGS",CSP_WQI_SGS)
  fo->CSP_WQI_SGS = (/ CSP_WQI_SGS /)

  filevardef(fo,"CSP_WQL_SGS",typeof(CSP_WQL_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQL_SGS",CSP_WQL_SGS)
  fo->CSP_WQL_SGS = (/ CSP_WQL_SGS /)

  filevardef(fo,"CSP_WQF_SGS",typeof(CSP_WQF_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQF_SGS",CSP_WQF_SGS)
  fo->CSP_WQF_SGS = (/ CSP_WQF_SGS /)

  filevardef(fo,"CSP_WQT_SGS",typeof(CSP_WQT_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WQT_SGS",CSP_WQT_SGS)
  fo->CSP_WQT_SGS = (/ CSP_WQT_SGS /)

  filevardef(fo,"CSP_SEDFQC",typeof(CSP_SEDFQC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SEDFQC",CSP_SEDFQC)
  fo->CSP_SEDFQC = (/ CSP_SEDFQC /)

  filevardef(fo,"CSP_SEDFQR",typeof(CSP_SEDFQR),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SEDFQR",CSP_SEDFQR)
  fo->CSP_SEDFQR = (/ CSP_SEDFQR /)

  filevardef(fo,"CSP_THDT_COND",typeof(CSP_THDT_COND),(/ "Time", \
                                                         "bottom_top" /))
  filevarattdef(fo,"CSP_THDT_COND",CSP_THDT_COND)
  fo->CSP_THDT_COND = (/ CSP_THDT_COND /)

  filevardef(fo,"CSP_THDT_LW",typeof(CSP_THDT_LW),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THDT_LW",CSP_THDT_LW)
  fo->CSP_THDT_LW = (/ CSP_THDT_LW /)

  filevardef(fo,"CSP_THDT_SW",typeof(CSP_THDT_SW),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THDT_SW",CSP_THDT_SW)
  fo->CSP_THDT_SW = (/ CSP_THDT_SW /)

  filevardef(fo,"CSP_THDT_LS",typeof(CSP_THDT_LS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THDT_LS",CSP_THDT_LS)
  fo->CSP_THDT_LS = (/ CSP_THDT_LS /)

  filevardef(fo,"CSP_QVDT_PR",typeof(CSP_QVDT_PR),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QVDT_PR",CSP_QVDT_PR)
  fo->CSP_QVDT_PR = (/ CSP_QVDT_PR /)

  filevardef(fo,"CSP_QVDT_COND",typeof(CSP_QVDT_COND),(/ "Time", \
                                                         "bottom_top" /))
  filevarattdef(fo,"CSP_QVDT_COND",CSP_QVDT_COND)
  fo->CSP_QVDT_COND = (/ CSP_QVDT_COND /)

  filevardef(fo,"CSP_QVDT_LS",typeof(CSP_QVDT_LS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QVDT_LS",CSP_QVDT_LS)
  fo->CSP_QVDT_LS = (/ CSP_QVDT_LS /)

  filevardef(fo,"CSP_QCDT_PR",typeof(CSP_QCDT_PR),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QCDT_PR",CSP_QCDT_PR)
  fo->CSP_QCDT_PR = (/ CSP_QCDT_PR /)

  filevardef(fo,"CSP_QCDT_SED",typeof(CSP_QCDT_SED),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QCDT_SED",CSP_QCDT_SED)
  fo->CSP_QCDT_SED = (/ CSP_QCDT_SED /)

  filevardef(fo,"CSP_QRDT_SED",typeof(CSP_QRDT_SED),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QRDT_SED",CSP_QRDT_SED)
  fo->CSP_QRDT_SED = (/ CSP_QRDT_SED /)

  filevardef(fo,"CSP_THDT_LSHOR",typeof(CSP_THDT_LSHOR),(/ "Time", \
                                                           "bottom_top" /))
  filevarattdef(fo,"CSP_THDT_LSHOR",CSP_THDT_LSHOR)
  fo->CSP_THDT_LSHOR = (/ CSP_THDT_LSHOR /)

  filevardef(fo,"CSP_QVDT_LSHOR",typeof(CSP_QVDT_LSHOR),(/ "Time", \
                                                           "bottom_top" /))
  filevarattdef(fo,"CSP_QVDT_LSHOR",CSP_QVDT_LSHOR)
  fo->CSP_QVDT_LSHOR = (/ CSP_QVDT_LSHOR /)

  filevardef(fo,"CSP_THDT_LSVER",typeof(CSP_THDT_LSVER),(/ "Time", \
                                                           "bottom_top" /))
  filevarattdef(fo,"CSP_THDT_LSVER",CSP_THDT_LSVER)
  fo->CSP_THDT_LSVER = (/ CSP_THDT_LSVER /)

  filevardef(fo,"CSP_QVDT_LSVER",typeof(CSP_QVDT_LSVER),(/ "Time", \
                                                           "bottom_top" /))
  filevarattdef(fo,"CSP_QVDT_LSVER",CSP_QVDT_LSVER)
  fo->CSP_QVDT_LSVER = (/ CSP_QVDT_LSVER /)

  filevardef(fo,"CSP_THDT_LSRLX",typeof(CSP_THDT_LSRLX),(/ "Time", \
                                                           "bottom_top" /))
  filevarattdef(fo,"CSP_THDT_LSRLX",CSP_THDT_LSRLX)
  fo->CSP_THDT_LSRLX = (/ CSP_THDT_LSRLX /)

  filevardef(fo,"CSP_QVDT_LSRLX",typeof(CSP_QVDT_LSRLX),(/ "Time", \
                                                           "bottom_top" /))
  filevarattdef(fo,"CSP_QVDT_LSRLX",CSP_QVDT_LSRLX)
  fo->CSP_QVDT_LSRLX = (/ CSP_QVDT_LSRLX /)

  filevardef(fo,"CSP_UDT_LS",typeof(CSP_UDT_LS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_UDT_LS",CSP_UDT_LS)
  fo->CSP_UDT_LS = (/ CSP_UDT_LS /)

  filevardef(fo,"CSP_VDT_LS",typeof(CSP_VDT_LS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_VDT_LS",CSP_VDT_LS)
  fo->CSP_VDT_LS = (/ CSP_VDT_LS /)

  filevardef(fo,"CSP_UDT_LSVER",typeof(CSP_UDT_LSVER),(/ "Time", \
                                                         "bottom_top" /))
  filevarattdef(fo,"CSP_UDT_LSVER",CSP_UDT_LSVER)
  fo->CSP_UDT_LSVER = (/ CSP_UDT_LSVER /)

  filevardef(fo,"CSP_VDT_LSVER",typeof(CSP_VDT_LSVER),(/ "Time", \
                                                         "bottom_top" /))
  filevarattdef(fo,"CSP_VDT_LSVER",CSP_VDT_LSVER)
  fo->CSP_VDT_LSVER = (/ CSP_VDT_LSVER /)

  filevardef(fo,"CSP_UDT_LSRLX",typeof(CSP_UDT_LSRLX),(/ "Time", \
                                                         "bottom_top" /))
  filevarattdef(fo,"CSP_UDT_LSRLX",CSP_UDT_LSRLX)
  fo->CSP_UDT_LSRLX = (/ CSP_UDT_LSRLX /)

  filevardef(fo,"CSP_VDT_LSRLX",typeof(CSP_VDT_LSRLX),(/ "Time", \
                                                         "bottom_top" /))
  filevarattdef(fo,"CSP_VDT_LSRLX",CSP_VDT_LSRLX)
  fo->CSP_VDT_LSRLX = (/ CSP_VDT_LSRLX /)

  filevardef(fo,"CSP_SWUPF",typeof(CSP_SWUPF),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SWUPF",CSP_SWUPF)
  fo->CSP_SWUPF = (/ CSP_SWUPF /)

  filevardef(fo,"CSP_SWDNF",typeof(CSP_SWDNF),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SWDNF",CSP_SWDNF)
  fo->CSP_SWDNF = (/ CSP_SWDNF /)

  filevardef(fo,"CSP_LWUPF",typeof(CSP_LWUPF),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_LWUPF",CSP_LWUPF)
  fo->CSP_LWUPF = (/ CSP_LWUPF /)

  filevardef(fo,"CSP_LWDNF",typeof(CSP_LWDNF),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_LWDNF",CSP_LWDNF)
  fo->CSP_LWDNF = (/ CSP_LWDNF /)

  filevardef(fo,"CSP_TKE_RS",typeof(CSP_TKE_RS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_TKE_RS",CSP_TKE_RS)
  fo->CSP_TKE_RS = (/ CSP_TKE_RS /)

  filevardef(fo,"CSP_TKE_SH",typeof(CSP_TKE_SH),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_TKE_SH",CSP_TKE_SH)
  fo->CSP_TKE_SH = (/ CSP_TKE_SH /)

  filevardef(fo,"CSP_TKE_BU",typeof(CSP_TKE_BU),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_TKE_BU",CSP_TKE_BU)
  fo->CSP_TKE_BU = (/ CSP_TKE_BU /)

  filevardef(fo,"CSP_TKE_TR",typeof(CSP_TKE_TR),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_TKE_TR",CSP_TKE_TR)
  fo->CSP_TKE_TR = (/ CSP_TKE_TR /)

  filevardef(fo,"CSP_TKE_DI",typeof(CSP_TKE_DI),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_TKE_DI",CSP_TKE_DI)
  fo->CSP_TKE_DI = (/ CSP_TKE_DI /)

  filevardef(fo,"CSP_TKE_SGS",typeof(CSP_TKE_SGS),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_TKE_SGS",CSP_TKE_SGS)
  fo->CSP_TKE_SGS = (/ CSP_TKE_SGS /)

  filevardef(fo,"CSP_W_C",typeof(CSP_W_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_W_C",CSP_W_C)
  fo->CSP_W_C = (/ CSP_W_C /)

  filevardef(fo,"CSP_THL_C",typeof(CSP_THL_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THL_C",CSP_THL_C)
  fo->CSP_THL_C = (/  CSP_THL_C /)

  filevardef(fo,"CSP_QT_C",typeof(CSP_QT_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QT_C",CSP_QT_C)
  fo->CSP_QT_C = (/ CSP_QT_C /)

  filevardef(fo,"CSP_QV_C",typeof(CSP_QV_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QV_C",CSP_QV_C)
  fo->CSP_QV_C = (/ CSP_QV_C /)

  filevardef(fo,"CSP_QL_C",typeof(CSP_QL_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QL_C",CSP_QL_C)
  fo->CSP_QL_C = (/ CSP_QL_C /)

  filevardef(fo,"CSP_QF_C",typeof(CSP_QF_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QF_C",CSP_QF_C)
  fo->CSP_QF_C = (/ CSP_QF_C /)

  filevardef(fo,"CSP_QC_C",typeof(CSP_QC_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QC_C",CSP_QC_C)
  fo->CSP_QC_C = (/ CSP_QC_C /)

  filevardef(fo,"CSP_QI_C",typeof(CSP_QI_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QI_C",CSP_QI_C)
  fo->CSP_QI_C = (/ CSP_QI_C /)

  filevardef(fo,"CSP_THV_C",typeof(CSP_THV_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THV_C",CSP_THV_C)
  fo->CSP_THV_C = (/ CSP_THV_C /)

  filevardef(fo,"CSP_W2_C",typeof(CSP_W2_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_W2_C",CSP_W2_C)
  fo->CSP_W2_C = (/ CSP_W2_C /)

  filevardef(fo,"CSP_AW_C",typeof(CSP_AW_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AW_C",CSP_AW_C)
  fo->CSP_AW_C = (/ CSP_AW_C /)

  filevardef(fo,"CSP_AWTHL_C",typeof(CSP_AWTHL_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWTHL_C",CSP_AWTHL_C)
  fo->CSP_AWTHL_C = (/ CSP_AWTHL_C /)

  filevardef(fo,"CSP_AWQT_C",typeof(CSP_AWQT_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQT_C",CSP_AWQT_C)
  fo->CSP_AWQT_C = (/ CSP_AWQT_C /)

  filevardef(fo,"CSP_AWQV_C",typeof(CSP_AWQV_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQV_C",CSP_AWQV_C)
  fo->CSP_AWQV_C = (/ CSP_AWQV_C /)

  filevardef(fo,"CSP_AWQL_C",typeof(CSP_AWQL_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQL_C",CSP_AWQL_C)
  fo->CSP_AWQL_C = (/ CSP_AWQL_C /)

  filevardef(fo,"CSP_AWQF_C",typeof(CSP_AWQF_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQF_C",CSP_AWQF_C)
  fo->CSP_AWQF_C = (/ CSP_AWQF_C /)

  filevardef(fo,"CSP_AWQC_C",typeof(CSP_AWQC_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQC_C",CSP_AWQC_C)
  fo->CSP_AWQC_C = (/ CSP_AWQC_C /)

  filevardef(fo,"CSP_AWQI_C",typeof(CSP_AWQI_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQI_C",CSP_AWQI_C)
  fo->CSP_AWQI_C = (/ CSP_AWQI_C /)

  filevardef(fo,"CSP_AWTHV_C",typeof(CSP_AWTHV_C),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWTHV_C",CSP_AWTHV_C)
  fo->CSP_AWTHV_C = (/ CSP_AWTHV_C /)

  filevardef(fo,"CSP_A_CC",typeof(CSP_A_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_A_CC",CSP_A_CC)
  fo->CSP_A_CC = (/ CSP_A_CC /)

  filevardef(fo,"CSP_W_CC",typeof(CSP_W_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_W_CC",CSP_W_CC)
  fo->CSP_W_CC = (/ CSP_W_CC /)

  filevardef(fo,"CSP_THL_CC",typeof(CSP_THL_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THL_CC",CSP_THL_CC)
  fo->CSP_THL_CC = (/ CSP_THL_CC /)

  filevardef(fo,"CSP_QT_CC",typeof(CSP_QT_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QT_CC",CSP_QT_CC)
  fo->CSP_QT_CC = (/ CSP_QT_CC /)

  filevardef(fo,"CSP_QV_CC",typeof(CSP_QV_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QV_CC",CSP_QV_CC)
  fo->CSP_QV_CC = (/ CSP_QV_CC /)

  filevardef(fo,"CSP_QL_CC",typeof(CSP_QL_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QL_CC",CSP_QL_CC)
  fo->CSP_QL_CC = (/ CSP_QL_CC /)

  filevardef(fo,"CSP_QF_CC",typeof(CSP_QF_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QF_CC",CSP_QF_CC)
  fo->CSP_QF_CC = (/ CSP_QF_CC /)

  filevardef(fo,"CSP_QC_CC",typeof(CSP_QC_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QC_CC",CSP_QC_CC)
  fo->CSP_QC_CC = (/ CSP_QC_CC /)

  filevardef(fo,"CSP_QI_CC",typeof(CSP_QI_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QI_CC",CSP_QI_CC)
  fo->CSP_QI_CC = (/ CSP_QI_CC /)

  filevardef(fo,"CSP_THV_CC",typeof(CSP_THV_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THV_CC",CSP_THV_CC)
  fo->CSP_THV_CC = (/ CSP_THV_CC /)

  filevardef(fo,"CSP_W2_CC",typeof(CSP_W2_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_W2_CC",CSP_W2_CC)
  fo->CSP_W2_CC = (/ CSP_W2_CC /)

  filevardef(fo,"CSP_AW_CC",typeof(CSP_AW_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AW_CC",CSP_AW_CC)
  fo->CSP_AW_CC = (/ CSP_AW_CC /)

  filevardef(fo,"CSP_AWTHL_CC",typeof(CSP_AWTHL_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWTHL_CC",CSP_AWTHL_CC)
  fo->CSP_AWTHL_CC = (/ CSP_AWTHL_CC /)

  filevardef(fo,"CSP_AWQT_CC",typeof(CSP_AWQT_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQT_CC",CSP_AWQT_CC)
  fo->CSP_AWQT_CC = (/ CSP_AWQT_CC /)

  filevardef(fo,"CSP_AWQV_CC",typeof(CSP_AWQV_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQV_CC",CSP_AWQV_CC)
  fo->CSP_AWQV_CC = (/ CSP_AWQV_CC /)

  filevardef(fo,"CSP_AWQL_CC",typeof(CSP_AWQL_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQL_CC",CSP_AWQL_CC)
  fo->CSP_AWQL_CC = (/ CSP_AWQL_CC /)

  filevardef(fo,"CSP_AWQF_CC",typeof(CSP_AWQF_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQF_CC",CSP_AWQF_CC)
  fo->CSP_AWQF_CC = (/ CSP_AWQF_CC /)

  filevardef(fo,"CSP_AWQC_CC",typeof(CSP_AWQC_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQC_CC",CSP_AWQC_CC)
  fo->CSP_AWQC_CC = (/ CSP_AWQC_CC /)

  filevardef(fo,"CSP_AWQI_CC",typeof(CSP_AWQI_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWQI_CC",CSP_AWQI_CC)
  fo->CSP_AWQI_CC = (/ CSP_AWQI_CC /)

  filevardef(fo,"CSP_AWTHV_CC",typeof(CSP_AWTHV_CC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_AWTHV_CC",CSP_AWTHV_CC)
  fo->CSP_AWTHV_CC = (/ CSP_AWTHV_CC /)

  filevardef(fo,"CSP_SIGC_THL",typeof(CSP_SIGC_THL),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SIGC_THL",CSP_SIGC_THL)
  fo->CSP_SIGC_THL = (/ CSP_SIGC_THL /)

  filevardef(fo,"CSP_SIGC_QT",typeof(CSP_SIGC_QT),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SIGC_QT",CSP_SIGC_QT)
  fo->CSP_SIGC_QT = (/ CSP_SIGC_QT /)

  filevardef(fo,"CSP_SIGC_QL",typeof(CSP_SIGC_QL),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SIGC_QL",CSP_SIGC_QL)
  fo->CSP_SIGC_QL = (/ CSP_SIGC_QL /)

  filevardef(fo,"CSP_SIGC_QF",typeof(CSP_SIGC_QF),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SIGC_QF",CSP_SIGC_QF)
  fo->CSP_SIGC_QF = (/ CSP_SIGC_QF /)

  filevardef(fo,"CSP_SIGC_QC",typeof(CSP_SIGC_QC),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SIGC_QC",CSP_SIGC_QC)
  fo->CSP_SIGC_QC = (/ CSP_SIGC_QC /)

  filevardef(fo,"CSP_SIGC_QI",typeof(CSP_SIGC_QI),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SIGC_QI",CSP_SIGC_QI)
  fo->CSP_SIGC_QI = (/ CSP_SIGC_QI /)

  filevardef(fo,"CSP_SIGC_THV",typeof(CSP_SIGC_THV),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_SIGC_THV",CSP_SIGC_THV)
  fo->CSP_SIGC_THV = (/ CSP_SIGC_THV /)

  filevardef(fo,"CSP_TH2",typeof(CSP_TH2),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_TH2",CSP_TH2)
  fo->CSP_TH2 = (/ CSP_TH2 /)

  filevardef(fo,"CSP_THV2",typeof(CSP_THV2),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THV2",CSP_THV2)
  fo->CSP_THV2 = (/ CSP_THV2 /)

  filevardef(fo,"CSP_THL2",typeof(CSP_THL2),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_THL2",CSP_THL2)
  fo->CSP_THL2 = (/ CSP_THL2 /)

  filevardef(fo,"CSP_QV2",typeof(CSP_QV2),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_QV2",CSP_QV2)
  fo->CSP_QV2 = (/ CSP_QV2 /)

  filevardef(fo,"CSP_SMAXACTMAX",typeof(CSP_SMAXACTMAX),(/ "Time", \
                                                           "bottom_top" /))
  filevarattdef(fo,"CSP_SMAXACTMAX",CSP_SMAXACTMAX)
  fo->CSP_SMAXACTMAX = (/ CSP_SMAXACTMAX /)

  filevardef(fo,"CSP_RMINACTMIN",typeof(CSP_RMINACTMIN),(/ "Time", \
                                                           "bottom_top" /))
  filevarattdef(fo,"CSP_RMINACTMIN",CSP_RMINACTMIN)
  fo->CSP_RMINACTMIN = (/ CSP_RMINACTMIN /)

  filevardef(fo,"CSP_WMAX",typeof(CSP_WMAX),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WMAX",CSP_WMAX)
  fo->CSP_WMAX = (/ CSP_WMAX /)

  filevardef(fo,"CSP_WMIN",typeof(CSP_WMIN),(/ "Time","bottom_top" /))
  filevarattdef(fo,"CSP_WMIN",CSP_WMIN)
  fo->CSP_WMIN = (/ CSP_WMIN /)

  filevardef(fo,"CSS_LWP",typeof(CSS_LWP),(/ "Time","south_north", \
                                             "west_east" /))
  filevarattdef(fo,"CSS_LWP",CSS_LWP)
  fo->CSS_LWP = (/ CSS_LWP /)

  filevardef(fo,"CSS_IWP",typeof(CSS_IWP),(/ "Time","south_north", \ 
                                             "west_east" /))
  filevarattdef(fo,"CSS_IWP",CSS_IWP)
  fo->CSS_IWP = (/ CSS_IWP /)

  filevardef(fo,"CSS_CLDTOT",typeof(CSS_CLDTOT),(/ "Time","south_north", \
                                                   "west_east" /))
  filevarattdef(fo,"CSS_CLDTOT",CSS_CLDTOT)
  fo->CSS_CLDTOT = (/ CSS_CLDTOT /)

  filevardef(fo,"CSS_CLDLOW",typeof(CSS_CLDLOW),(/ "Time","south_north", \
                                                   "west_east" /))
  filevarattdef(fo,"CSS_CLDLOW",CSS_CLDLOW)
  fo->CSS_CLDLOW = (/ CSS_CLDLOW /)

  print("Created and wrote subset file: "+fout)
  print("Finished: "+systemfunc("date"))

end
