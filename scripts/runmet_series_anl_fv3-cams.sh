#!/bin/sh
#
# Usage: ./runmet_series_anl_fv3-cams.sh
# BASE: The path
# INPUTBASE: the path saved dataset files.

set -x 

proj_account="chem-var"
popts="1/1"

metrun=met_series_anl
outdir=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/diagOutput/

# BASE: The path to METplus package
# INPUTBASE: the path saved dataset files.
export BASE=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/METplus_pkg/
export INPUTBASE=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/data/

export SDATE=2016060100
export EDATE=2016063018
export INC_H=6

# set fcst and obs varibales
# need to further set fcst and obs model levels in met_series_anl.sh
export FCST_NAME="FV3"
export FCSTPATH=$INPUTBASE/FV3/VIIRS/pll
export FCST_HEAD_aeros="fv3_aeros_"
export FCST_SUFF_aeros="_pll.nc"
export FCST_HEAD_aods="fv3_aods_"
export FCST_SUFF_aods="_ll.nc"

export OBS_NAME="CAMS"
export OBSPATH=$INPUTBASE/CAMS/pll
export OBS_HEAD_aeros="cams_aeros_"
export OBS_SUFF_aeros="_sdtotals.nc"
export OBS_HEAD_aods="cams_aods_"
export OBS_SUFF_aods=".nc"

WRKDTOP=$outdir/wrk-${FCST_NAME}-${OBS_NAME}-${SDATE}-${EDATE}/${metrun}/

#export OBS_NAME="MERRA2"
#export OBSPATH=$INPUTBASE/MERRA2/pll
#export OBS_HEAD_aeros="m2_aeros_"
#export OBS_SUFF_aeros="_pll.nc"
#export OBS_HEAD_aods="m2_aodss_"
#export OBS_SUFF_aods="_ll.nc"

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
OBSVARS=(DUSTTOTAL SEASTOTAL aermr07  aermr08  aermr09  aermr10  aermr11)

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
    export FCST_VAR=${FCSTVARS[ivar]}
    export FCST_HEAD=${FCST_HEAD_aeros}
    export FCST_SUFF=${FCST_SUFF_aeros}
    export OBS_VAR=${OBSVARS[ivar]}
    export OBS_HEAD=${OBS_HEAD_aeros}
    export OBS_SUFF=${OBS_SUFF_aeros}
    export WRKD=${WRKDTOP}/${FCST_VAR}-${OBS_VAR}
    export DATA=$WRKD/tmp
    export OUTPUTBASE=${WRKD}

    cd $WRKD
    #rm -rf $WRKD/*
    /bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${FCST_NAME}.${FCST_VAR}-${OBS_NAME}.${OBS_VAR} -o ${WRKD}/$metrun-${FCST_NAME}.${FCST_VAR}-${OBS_NAME}.${OBS_VAR}.out -q batch -t 02:19:00 -r /1 $BASE/scripts/${metrun}.sh
    sleep 2
done

#Process aod
export FCST_VAR=aod
export FCST_HEAD=${FCST_HEAD_aods}
export FCST_SUFF=${FCST_SUFF_aods}
export OBS_VAR=aod550
export OBS_HEAD=${OBS_HEAD_aods}
export OBS_SUFF=${OBS_SUFF_aods}
export WRKD=${WRKDTOP}/${FCST_VAR}-${OBS_VAR}
export DATA=$WRKD/tmp
export OUTPUTBASE=${WRKD}

cd $WRKD
#rm -rf $WRKD/*
/bin/sh $subcmd -a $proj_account -p $popts -j $metrun-${FCST_NAME}.${FCST_VAR}-${OBS_NAME}.${OBS_VAR} -o ${WRKD}/$metrun-${FCST_NAME}.${FCST_VAR}-${OBS_NAME}.${OBS_VAR}.out -q batch -t 02:19:00 -r /1 $BASE/scripts/${metrun}.sh
