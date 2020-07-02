#!/bin/sh
#
# Usage: ./runmet.sh metrun
# Available metruns are defined in $metlist
# BASE: The path
# INPUTBASE: the path saved dataset files.
# OUTPUTBASE: the path for the metplus/met output
#
set -x 

proj_account="chem-var"
popts="1/1"

metrun=$1  #met_grid_stat_anl
export BASE=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/METplus_pkg/
export INPUTBASE="/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/data/"

export SDATE=2016060100
export EDATE=2016063018
export INC_H=6

export MODELNAME="CAMS"
export FCSTDIR=$INPUTBASE/CAMS/pll
export FCSTINPUTTMP="cams_aeros_{init?fmt=%Y%m%d%H}_sdtotals.nc"
export FCSTLEV='"(0,0,*,*)","(0,1,*,*)","(0,2,*,*)","(0,3,*,*)","(0,4,*,*)","(0,5,*,*)","(0,6,*,*)","(0,7,*,*)","(0,8,*,*)"'
export FCSTLEV2='"0,0,*,*","0,1,*,*","0,2,*,*","0,3,*,*","0,4,*,*","0,5,*,*","0,6,*,*","0,7,*,*","0,8,*,*"'

export OBSNAME="FV3"
export OBSDIR=$INPUTBASE/FV3/VIIRS/pll
export OBSINPUTTMP="fv3_aeros_{init?fmt=%Y%m%d%H}_pll.nc"
export OBSLEV='"(0,0,*,*)","(0,1,*,*)","(0,2,*,*)","(0,3,*,*)","(0,4,*,*)","(0,5,*,*)","(0,6,*,*)","(0,7,*,*)","(0,8,*,*)"'
export OBSLEV2='"0,0,*,*","0,1,*,*","0,2,*,*","0,3,*,*","0,4,*,*","0,5,*,*","0,6,*,*","0,7,*,*","0,8,*,*"'


export MSKLIST="FULL TROP CONUS EASIA NAFRME RUSC2S SAFRTROP SOCEAN"

nvars=7
FCSTVARS=(DUSTTOTAL SEASTOTAL aermr07  aermr08  aermr09  aermr10  aermr11)
OBSVARS=( DUSTTOTAL SEASTOTAL OCPHILIC OCPHOBIC BCPHILIC BCPHOBIC SO4)


if [ -d /glade/scratch ]; then
   export machine=Cheyenne
   export subcmd=$BASE/ush/sub_ncar
elif [ -d /scratch1/NCEPDEV/da ]; then
   export machine=Hera
   export subcmd=$BASE/ush/sub_hera
fi

#source $BASE/ush/met_load.sh
#rc=$?
#if [ $rc -ne 0 ]; then
#   exit $rc
#fi

if [ $metrun == "met_grid_stat_anl" ]; then
for ((ivar=0;ivar<${nvars};ivar++))
do
    export FCSTVAR=${FCSTVARS[ivar]}
    export OBSVAR=${OBSVARS[ivar]}
    export WRKD=$BASE/wrk-${MODELNAME}-${OBSNAME}/${FCSTVAR}-${OBSVAR}
    export DATA=$WRKD/tmp
    export OUTPUTBASE=${WRKD}

    cd $WRKD
    rm -rf $WRKD/*
    /bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${MODELNAME}.${FCSTVAR}-${OBSNAME}.${OBSVAR} -q batch -t 02:59:00 -r /1 $BASE/scripts/${metrun}.sh
    sleep 2
done
#$BASE/scripts/cams-m2/${metrun}.sh DUSTTOTAL 


export FCSTVAR=aod550
export FCSTINPUTTMP="cams_aods_{init?fmt=%Y%m%d%H}.nc"
export FCSTLEV='"(0,*,*)"'
export FCSTLEV2='"0,*,*"'
export OBSVAR=aod
export OBSINPUTTMP="fv3_aods_{init?fmt=%Y%m%d%H}_ll.nc"
export OBSLEV='"(0,0,*,*)"'
export OBSLEV2='"0,0,*,*"'
export WRKD=$BASE/wrk-${MODELNAME}-${OBSNAME}/${FCSTVAR}-${OBSVAR}
export DATA=$WRKD/tmp
export OUTPUTBASE=${WRKD}

cd $WRKD
rm -rf $WRKD/*
/bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${MODELNAME}.${FCSTVAR}-${OBSNAME}.${OBSVAR} -q batch -t 02:59:00 -r /1 $BASE/scripts/${metrun}.sh
fi

if [ $metrun == "met_series_anl" ]; then

fi

