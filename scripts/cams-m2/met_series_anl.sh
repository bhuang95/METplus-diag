set -x
# Comparison between 2 models at pressure level as a time series.
# Requirements
# 1. If both models are in NetCDF, ensure they have the same vertical layers for comparison
#    and in same top-down or down-top order.
# 2. List all the pres layers in NetCDF files
# 3. List the name of variables that are desired to compare in the corresponding order.
#  
# main.conf: define input and output base.
# 
# Setup SDATE, EDATE, INCH, GRID_NAME, FCST_NAME, OBS_NAME, FCST_VAR, FCST_VARLEV, OBS_VAR, OBS_VARLEV, 
#       FCSTFILETMP, OBSFILETMP, OUTPUTFILE_NAME
# SDATE: start date of evaluation
# EDATE: end date of evaluation
# INC_H: increment of hours
# GRID_NAME: GXXX from https://www.nco.ncep.noaa.gov/pmb/docs/on388/tableb.html
#            G002 2.5 deg by 2.5 deg
#            G004 0.5 deg by 0.5 deg
# PLEV: All the pressure levels in NetCDF files
# FCST/OBSPATH: The path saved forecast and obs data files.
# FCST/OBSFILETMP: The name that can be searched under FCST/OBSPATH
# 
#
if [ -d /glade/scratch ]; then
   export machine=Cheyenne
elif [ -d /scratch1/NCEPDEV/da ]; then
   export machine=Hera
fi
source $BASE/ush/met_load.sh
rc=$?
if [ $rc -ne 0 ]; then
   exit $rc
fi
#
# User defined variables
#
SDATE=2018040100
EDATE=2018040200
INC_H=6

GRID_NAME="G002"

PLEV="100 250 400 500 600 700 850 925 1000"

FCSTPATH=$INPUTBASE/EAC4/pl
FCST_Head="eac4_pl."
FCSTSUFF=".nc"
FCSTFILETMP="${FCST_Head}*${FCSTSUFF}"
FCST_NAME="CAMSiRA"
FCSTVARS="aermr01 aermr02 aermr03 aermr04 aermr05 aermr06 aermr07 aermr08 aermr09 aermr10 aermr11"

OBSPATH=$INPUTBASE/MERRA2_plv
OBS_Head="MERRA2_prs_lv."
OBSSUFF=".nc"
OBSFILETMP="${OBS_Head}*${OBSSUFF}"
OBS_NAME="MERRA-2_plv"
OBSVARS="SEASFINE SEASMEDIUM SEASCOARSE DUSTFINE DUSTMEDIUM DUSTCOARSE OCPHILIC OCPHOBIC BCPHILIC BCPHOBIC SO4"
#
# Default variables
#
WRKD=${WRKD:-$BASE/wrk}
NDATE="python $BASE/bin/ndate.py"
CONFIG_DIR=$BASE/conf
INCONFIG=${CONFIG_DIR}/SeriesAnalysis.conf.IN
MAINCONF=$CONFIG_DIR/main.conf.IN
MASTER=$METPLUS_PATH/ush/master_metplus.py

typeset -a FCSTVARLIST
vidx=0
for FVAR in $FCSTVARS
do 
   FCSTVARLIST[$vidx]=$FVAR
   let vidx=vidx+1
done
typeset -a OBSVARLIST
vidx=0
for OVAR in $OBSVARS
do
   OBSVARLIST[$vidx]=$OVAR
   let vidx=vidx+1
done
nvar=${#FCSTVARLIST[*]}
echo $nvar
# plev 100, 250, 400, 500, 600, 700, 850, 925, 1000
#typeset -a PLEVLIST=(100 250 400 500 600 700 800 850 900 925 950 1000)

nl=0
typeset -a PLEVLIST
typeset -a NCLVIDXLIS
for PRES in $PLEV
do
  PLEVLIST[$nl]=${PRES}
  NCLVIDXLIST[$nl]=$nl
  let nl=nl+1
done
nplv=${#PLEVLIST[*]}

cd $WRKD
mkdir $WRKD/fcst $WRKD/obs

FCSTDIR=$WRKD/fcst
OBSDIR=$WRKD/obs

CDATE=$SDATE
while [ $CDATE -le $EDATE ];
do
  ln -sf $FCSTPATH/${FCST_Head}${CDATE}${FCSTSUFF} ./fcst
  ln -sf $OBSPATH/${OBS_Head}${CDATE}${OBSSUFF} ./obs
  CDATE=`$NDATE $CDATE $INC_H`
done

nv=5
while [[ $nv == 5 ]]; #-lt $nvar ]];
do
np=6
while [[ $np == 6 ]]; #-lt $nplv ]];
do

PLEV="${PLEVLIST[$np]}"
FCST_VAR="${FCSTVARLIST[$nv]}"
case $FCSTSUFF in 
.nc)
   FCST_VARLEV="\"(0,${NCLVIDXLIST[$np]},*,*)\""
;;
*)
FCST_VARLEV="P${PLEVLIST[$np]}"
;;
esac

OBS_VAR="${OBSVARLIST[$nv]}"
OBS_VARLEV="\"(0,${NCLVIDXLIST[$np]},*,*)\""

OUTPUTTMP="${OBS_VAR}_${PLEV}hPa.nc"

echo $FCST_VAR $FCST_VARLEV
echo $OBS_VAR $OBS_VARLEV
echo $OUTPUTTMP

cat $MAINCONF | sed s:_MET_PATH_:${MET_PATH}:g \
              | sed s:_INPUTBASE_:${INPUTBASE}:g \
              | sed s:_OUTPUTBASE_:${OUTPUTBASE}:g \
              > ./main.conf 

cat $INCONFIG | sed s:_SDATE_:${SDATE}:g \
              | sed s:_EDATE_:${EDATE}:g \
              | sed s:_INC_H_:${INC_H}:g \
              | sed s:_BASE_:${BASE}:g \
              | sed s:_GRID_NAME_:${GRID_NAME}:g \
              | sed s:_FCST_NAME_:${FCST_NAME}:g \
              | sed s:_OBS_NAME_:${OBS_NAME}:g \
              | sed s:_FCST_VAR_:${FCST_VAR}:g \
              | sed s:_FCST_VARLEV_:${FCST_VARLEV}:g \
              | sed s:_OBS_VAR_:${OBS_VAR}:g \
              | sed s:_OBS_VARLEV_:${OBS_VARLEV}:g \
              | sed s:_FCSTDIR_:${FCSTDIR}:g \
              | sed s:_OBSDIR_:${OBSDIR}:g \
              | sed s:_FCSTFILETMP_:"${FCSTFILETMP}":g \
              | sed s:_OBSFILETMP_:"${OBSFILETMP}":g \
              | sed s:_OUTPUTTMP_:${OUTPUTTMP}:g \
              > ./SeriesAnalysis.${OBS_VAR}_${PLEV}hPa.conf

time $MASTER -c ./main.conf -c ./SeriesAnalysis.${OBS_VAR}_${PLEV}hPa.conf

let np=np+1
done
let nv=nv+1
done
