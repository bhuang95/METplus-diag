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

metrun=met_series_anl  #met_grid_stat_anl
export BASE=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/METplus_pkg/
export INPUTBASE="/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/data/"

export SDATE=2016060100
export EDATE=2016060118
export INC_H=6


export FCST_NAME="FV3"
export FCSTPATH=$INPUTBASE/FV3/VIIRS/pll
export FCST_SUFF="_pll.nc"
#export FCSTFILETMP="fv3_aeros_*_pll.nc"
#export FCST_VARLEV='"(0,6,*,*)"' #'"(0,0,*,*)","(0,1,*,*)","(0,2,*,*)","(0,3,*,*)","(0,4,*,*)","(0,5,*,*)","(0,6,*,*)","(0,7,*,*)","(0,8,*,*)"'
#export FPLEVLIST=(100 250 400 500 600 700 850 925 1000)
#export FNCLVIDXLIS=(0 1 2 3 4 5 6 7 8)

export OBS_NAME="CAMS"
export OBSPATH=$INPUTBASE/CAMS/pll
export OBS_HEAD="cams_aeros_"
export OBS_SUFF="_sdtotals.nc"
#export OBSFILETMP="cams_aeros_*_sdtotals.nc"
#export OBS_VARLEV='"(0,6,*,*)"' #'"(0,0,*,*)","(0,1,*,*)","(0,2,*,*)","(0,3,*,*)","(0,4,*,*)","(0,5,*,*)","(0,6,*,*)","(0,7,*,*)","(0,8,*,*)"'
#export OPLEVLIST=(100 250 400 500 600 700 850 925 1000)
#export ONCLVIDXLIS=(0 1 2 3 4 5 6 7 8)

#nvars=7
#FCSTVARS=(DUSTTOTAL SEASTOTAL OCPHILIC OCPHOBIC BCPHILIC BCPHOBIC SO4)
#OBSVARS=(DUSTTOTAL SEASTOTAL aermr07  aermr08  aermr09  aermr10  aermr11)

nvars=1
FCSTVARS=(DUSTCOARSE)
OBSVARS=(aermr06)


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
    export FCST_VAR=${FCSTVARS[ivar]}
    export OBS_VAR=${OBSVARS[ivar]}
    export WRKD=$BASE/wrk-${FCST_NAME}-${OBS_NAME}/${FCST_VAR}-${OBS_VAR}
    export DATA=$WRKD/tmp
    export OUTPUTBASE=${WRKD}

    cd $WRKD
    rm -rf $WRKD/*
    /bin/sh $subcmd -a $proj_accounts -j $metrun-${FCST_NAME}.${FCST_VAR}-${OBS_NAME}.${OBS_VAR} -o ${WRKD}/$metrun-${FCST_NAME}.${FCST_VAR}-${OBS_NAME}.${OBS_VAR}.out -q debug -t 00:19:00 -r /1 $BASE/scripts/${metrun}.sh
    sleep 2
done
#$BASE/scripts/cams-m2/${metrun}.sh DUSTTOTAL 


#export FCSTVAR=aod550
#export FCSTINPUTTMP="cams_aods_{init?fmt=%Y%m%d%H}.nc"
#export FCSTLEV='"(0,*,*)"'
#export FCSTLEV2='"0,*,*"'
#export OBSVAR=aod
#export OBSINPUTTMP="fv3_aods_{init?fmt=%Y%m%d%H}_ll.nc"
#export OBSLEV='"(0,0,*,*)"'
#export OBSLEV2='"0,0,*,*"'
#export WRKD=$BASE/wrk-${MODELNAME}-${OBSNAME}/${FCSTVAR}-${OBSVAR}
#export DATA=$WRKD/tmp
#export OUTPUTBASE=${WRKD}

#cd $WRKD
#rm -rf $WRKD/*
#/bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${MODELNAME}.${FCSTVAR}-${OBSNAME}.${OBSVAR} -q batch -t 02:59:00 -r /1 $BASE/scripts/${metrun}.sh
#fi
