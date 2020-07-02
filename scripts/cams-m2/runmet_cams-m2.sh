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

metlist="met_grid_stat_anl_aeros 
         met_grid_stat_anl_aods
            met_series_anl"

export BASE=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/METplus_pkg/
export INPUTBASE="/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/data/"

export SDATE=2016060100
export EDATE=2016060118
export INC_H=6

export MODELNAME="CAMS"
export FCSTDIR=$INPUTBASE/CAMS/pll
export FCSTINPUTTMP="cams_aeros_{init?fmt=%Y%m%d%H}_sdtotals.nc"
export OBSNAME="MERRA2"
export OBSDIR=$INPUTBASE/MERRA2/pll
export OBSINPUTTMP="m2_aeros_{init?fmt=%Y%m%d%H}_pll.nc"
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

for ((ivar=0;ivar<${nvars};ivar++))
do
    export FCSTVAR=${FCSTVARS[ivar]}
    export OBSVAR=${OBSVARS[ivar]}
    export WRKD=$BASE/wrk-${MODELNAME}-${OBSNAME}/${FCSTVAR}-${OBSVAR}
    export DATA=$WRKD/tmp
    export OUTPUTBASE=${WRKD}

    metrun=met_grid_stat_anl

    cd $WRKD
    rm -rf $WRKD/*
    /bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${FCSTVAR}-${OBSVAR} -q batch -t 02:19:00 -r /1 $BASE/scripts/cams-m2/${metrun}.sh
    sleep 2
done
#$BASE/scripts/cams-m2/${metrun}.sh DUSTTOTAL 


export FCSTINPUTTMP="cams_aeros_{init?fmt=%Y%m%d%H}_sdtotals.nc"
export FCSTINPUTTMP="cams_aeros_{init?fmt=%Y%m%d%H}_sdtotals.nc"
export FCSTVAR=aod550
export OBSVAR=AODANA
export WRKD=$BASE/wrk-${MODELNAME}-${OBSNAME}/${FCSTVAR}-${OBSVAR}
export DATA=$WRKD/tmp
export OUTPUTBASE=${WRKD}

metrun=met_grid_stat_anl

cd $WRKD
rm -rf $WRKD/*
/bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${FCSTVAR}-${OBSVAR} -q batch -t 02:19:00 -r /1 $BASE/scripts/cams-m2/${metrun}.sh

