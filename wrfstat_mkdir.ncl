load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; User modification area
  cldskl = "LO"
  YYYY   = "2017"

  projdir = "/gpfs/wolf/atm118/proj-shared/NCAR_CU/DOE/"
  homedir = "/ccsopen/home/dfdamico/NCAR_CU/DOE/subset_"+cldskl+"/"
; END USER MOD AREA

  dates = systemfunc("ls "+projdir+cldskl)
  nd    = dimsizes(dates)

  SIDall = systemfunc("ls "+projdir+cldskl+"/"+YYYY+"*")
  nall   = dimsizes(SIDall)

  SID    = new((/ nd /),string)
  SID(0) = SIDall(1)
  if (YYYY .eq. "2017" .and. cldskl .eq. "HI") then
    do i=1,nd-1,1
      if (i .lt. 6) then
        SID(i) = SIDall((i*3)+1)
      else if (i .ge. 6 .and. i .lt. 16) then
        SID(i) = SIDall((i*3)+2)
      else if (i .ge. 16 .and. i .lt. 24) then
        SID(i) = SIDall((i*3)+3)
      else
        SID(i) = SIDall((i*3)+4)
      end if
      end if
      end if
    end do
  end if
  if (YYYY .eq. "2017" .and. cldskl .eq. "MD") then
    do i=1,nd-1,1
      if (i .lt. 10) then
        SID(i) = SIDall((i*3)+1)
      else if (i .ge. 10) then
        SID(i) = SIDall((i*3)+2)
      end if
      end if
    end do
  end if
  if (YYYY .eq. "2017" .and. cldskl .eq. "LO") then
    do i=1,nd-1,1
      if (i .lt. 3) then
        SID(i) = SIDall((i*3)+1)
      else
        SID(i) = SIDall((i*3)+2)
      end if
    end do
  end if

  do i=0,nd-1,1
    system("/bin/mkdir -v "+homedir+dates(i))
    system("/bin/mkdir -v "+homedir+dates(i)+"/"+SID(i))
  end do

end

