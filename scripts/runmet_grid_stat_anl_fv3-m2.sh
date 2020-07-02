#!/bin/sh
#
# Usage: ./runmet_grid_stat_anl_fv3-cams.sh

set -x 

proj_account="chem-var"
popts="1/1"

metrun=met_grid_stat_anl
outdir=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/diagOutput/

# BASE: The path to METplus package
# INPUTBASE: the path saved dataset files.
export BASE=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/METplus_pkg/
export INPUTBASE=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/data/

export SDATE=2016060100
export EDATE=2016063018
export INC_H=6

# set fcst and obs varibales
export MODELNAME="FV3"
export FCSTDIR=$INPUTBASE/FV3/VIIRS/pll
export FCSTINPUTTMP_aeros="fv3_aeros_{init?fmt=%Y%m%d%H}_pll.nc"
export FCSTLEV_aeros='"(0,0,*,*)","(0,1,*,*)","(0,2,*,*)","(0,3,*,*)","(0,4,*,*)","(0,5,*,*)","(0,6,*,*)","(0,7,*,*)","(0,8,*,*)"'
export FCSTLEV2_aeros='"0,0,*,*","0,1,*,*","0,2,*,*","0,3,*,*","0,4,*,*","0,5,*,*","0,6,*,*","0,7,*,*","0,8,*,*"'
export FCSTINPUTTMP_aods="fv3_aods_{init?fmt=%Y%m%d%H}_ll.nc"
export FCSTLEV_aods='"(0,0,*,*)"'
export FCSTLEV2_aods='"0,0,*,*"'

#export OBSNAME="CAMS"
#export OBSDIR=$INPUTBASE/CAMS//pll
#export OBSINPUTTMP_aeros="cams_aeros_{init?fmt=%Y%m%d%H}_sdtotals.nc"
#export OBSLEV_aeros='"(0,0,*,*)","(0,1,*,*)","(0,2,*,*)","(0,3,*,*)","(0,4,*,*)","(0,5,*,*)","(0,6,*,*)","(0,7,*,*)","(0,8,*,*)"'
#export OBSLEV2_aeros='"0,0,*,*","0,1,*,*","0,2,*,*","0,3,*,*","0,4,*,*","0,5,*,*","0,6,*,*","0,7,*,*","0,8,*,*"'
#export OBSINPUTTMP_aods="cams_aods_{init?fmt=%Y%m%d%H}.nc"
#export OBSLEV_aods='"(0,*,*)"'
#export OBSLEV2_aods='"0,*,*"'

export OBSNAME="MERRA2"
export OBSDIR=$INPUTBASE/MERRA2//pll
export OBSINPUTTMP_aeros="m2_aeros_{init?fmt=%Y%m%d%H}_pll.nc"
export OBSLEV_aeros='"(0,0,*,*)","(0,1,*,*)","(0,2,*,*)","(0,3,*,*)","(0,4,*,*)","(0,5,*,*)","(0,6,*,*)","(0,7,*,*)","(0,8,*,*)"'
export OBSLEV2_aeros='"0,0,*,*","0,1,*,*","0,2,*,*","0,3,*,*","0,4,*,*","0,5,*,*","0,6,*,*","0,7,*,*","0,8,*,*"'
export OBSINPUTTMP_aods="m2_aods_{init?fmt=%Y%m%d%H}_ll.nc"
export OBSLEV_aods='"(0,*,*)"'
export OBSLEV2_aods='"0,*,*"'

WRKDTOP=$outdir/wrk-${MODELNAME}-${OBSNAME}-${SDATE}-${EDATE}/${metrun}/

# set aerosol varibales to be evaluated
#CAMSiRA (EAC4)		MERRA2/GSDChem
#DUSTTOTAL		DUSTTOTAL
#SEASTOTAL		SEASTOTAL
#aermr01		SEASFINE
#aermr02		SEASMEDIUM
#aermr03		SEASCOARSE
#aermr04		DUSTFINE
#aermr05		DUSTMEDIUM
#aermr06		DUSTCOARSE
#aermr07		OCPHILIC
#aermr08		OCPHOBIC
#aermr09		BCPHILIC
#aermr10		BCPHOBIC
#aermr11		SO4
#aod550			AODANA/aod

nvars=7
FCSTVARS=(DUSTTOTAL SEASTOTAL OCPHILIC OCPHOBIC BCPHILIC BCPHOBIC SO4)
OBSVARS=(DUSTTOTAL SEASTOTAL OCPHILIC OCPHOBIC BCPHILIC BCPHOBIC SO4)
#OBSVARS=(DUSTTOTAL SEASTOTAL aermr07  aermr08  aermr09  aermr10  aermr11)

export MSKLIST="FULL TROP CONUS EASIA NAFRME RUSC2S SAFRTROP SOCEAN"

if [ -d /glade/scratch ]; then
   export machine=Cheyenne
   export subcmd=$BASE/ush/sub_ncar
elif [ -d /scratch1/NCEPDEV/da ]; then
   export machine=Hera
   export subcmd=$BASE/ush/sub_hera
fi


#Process aerosol species
for ((ivar=0;ivar<${nvars};ivar++))
do
    export FCSTVAR=${FCSTVARS[ivar]}
    export FCSTINPUTTMP=${FCSTINPUTTMP_aeros}
    export FCSTLEV=${FCSTLEV_aeros}
    export FCSTLEV2=${FCSTLEV2_aeros}
    export OBSVAR=${OBSVARS[ivar]}
    export OBSINPUTTMP=${OBSINPUTTMP_aeros}
    export OBSLEV=${OBSLEV_aeros}
    export OBSLEV2=${OBSLEV2_aeros}
    export WRKD=${WRKDTOP}/${FCSTVAR}-${OBSVAR}
    export DATA=$WRKD/tmp
    export OUTPUTBASE=${WRKD}

    cd $WRKD
    #rm -rf $WRKD/*
    /bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${MODELNAME}.${FCSTVAR}-${OBSNAME}.${OBSVAR} -o ${WRKD}/$metrun-${MODELNAME}.${FCSTVAR}-${OBSNAME}.${OBSVAR}.out -q batch -t 02:19:00 -r /1 $BASE/scripts/${metrun}.sh
    sleep 2
done

export FCSTVAR=aod
export FCSTINPUTTMP=${FCSTINPUTTMP_aods}
export FCSTLEV=${FCSTLEV_aods}
export FCSTLEV2=${FCSTLEV2_aods}
export OBSVAR=AODANA
export OBSINPUTTMP=${OBSINPUTTMP_aods}
export OBSLEV=${OBSLEV_aods}
export OBSLEV2=${OBSLEV2_aods}
export WRKD=${WRKDTOP}/${FCSTVAR}-${OBSVAR}
export DATA=$WRKD/tmp
export OUTPUTBASE=${WRKD}

cd $WRKD
#rm -rf $WRKD/*
/bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${MODELNAME}.${FCSTVAR}-${OBSNAME}.${OBSVAR} -o ${WRKD}/$metrun-${MODELNAME}.${FCSTVAR}-${OBSNAME}.${OBSVAR}.out -q batch -t 02:19:00 -r /1 $BASE/scripts/${metrun}.sh
