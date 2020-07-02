#!/bin/ksh

set -x 

SDATE=2016060100
EDATE=2016060118
INC_H=6

. /etc/profile
. /home/Mariusz.Pagowski/mapp_2018/.environ_met.ksh

ident=$SDATE

year=`echo "${ident}" | cut -c1-4`
month=`echo "${ident}" | cut -c5-6`
day=`echo "${ident}" | cut -c7-8`
hr=`echo "${ident}" | cut -c9-10`

#BASE=/home/Mariusz.Pagowski/mapp_2018/scripts/met
BASE=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/testMET/met

GRID_NAME="G002"

MODELNAME="CAMS"
OBSNAME="M2"
MSKLIST="FULL TROP"

OBSVAR="DUSTTOTAL"
FCSTVAR="DUSTTOTAL"  

LINETYPELIST="SL1L2"

#INPUTBASE="/scratch1/BMC/wrf-chem/pagowski/MAPP_2018/MODEL"
INPUTBASE="/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/testMET/data"
OUTPUTBASE="/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/testMET/output"

FCSTDIR=$INPUTBASE/cams/pll
#FCSTINPUTTMP="cams_aeros_${year}${month}${day}_sdtotals.nc"
FCSTINPUTTMP="cams_aeros_{init?fmt=%Y%m%d%H}_sdtotals.nc"

OBSDIR=$INPUTBASE/m2/pll
#OBSINPUTTMP="m2_aeros_${year}${month}${day}_pll.nc"
OBSINPUTTMP="m2_aeros_{init?fmt=%Y%m%d%H}_pll.nc"

WRKD=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/testMET/wrk
#NDATE=/home/Mariusz.Pagowski/bin/ndate
NDATE="python /scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus_pkg_hboTest/bin/ndate.py"

CONFIG_DIR=$BASE/config
MAINCONF=$CONFIG_DIR/main.conf.IN
#MASKS_DIR=${INPUTBASE}/masks/nc_mask
MASKS_DIR=/scratch1/BMC/wrf-chem/pagowski/MAPP_2018/MODEL/masks/nc_mask
PY_DIR=$BASE/python
MASTER=$METPLUS_PATH/ush/master_metplus.py

if [[ ! -r $OUTPUTBASE ]]
then
    mkdir -p $OUTPUTBASE
fi

if [[ ! -r $WRKD ]]
then
    mkdir -p $WRKD
fi

cd $WRKD

cat $MAINCONF | sed s:_MET_PATH_:${MET_PATH}:g \
              | sed s:_INPUTBASE_:${INPUTBASE}:g \
              | sed s:_OUTPUTBASE_:${OUTPUTBASE}:g \
              > ./main.conf

#
echo "Step1: Grid_Stat for $MODELNAME vs. $OBSNAME from $SDATE to $EDATE"
for msk in $MSKLIST
do
  echo $msk
  if [[ $msk == "FULL" ]]; then
     continue
  else
     MSKFILE=${MASKS_DIR}/${msk}_MSK.nc
     if [ -z "${AREA_MASK}" ] ; then
        AREA_MASK="${MSKFILE}"
     else
        AREA_MASK="${AREA_MASK},${MSKFILE}"
     fi
  fi
done

INCONFIG=${CONFIG_DIR}/GridStat.conf.IN

cat $INCONFIG | sed s:_SDATE_:${SDATE}:g \
              | sed s:_EDATE_:${EDATE}:g \
              | sed s:_INC_H_:${INC_H}:g \
              | sed s:_BASE_:${BASE}:g \
              | sed s:_GRID_NAME_:${GRID_NAME}:g \
              | sed s:_MODELNAME_:${MODELNAME}:g \
              | sed s:_OBSNAME_:${OBSNAME}:g \
              | sed s:_FCSTVAR_:${FCSTVAR}:g \
              | sed s:_OBSVAR_:${OBSVAR}:g \
              | sed s:_FCSTDIR_:${FCSTDIR}:g \
              | sed s:_OBSDIR_:${OBSDIR}:g \
              | sed s:_FCSTINPUTTMP_:"${FCSTINPUTTMP}":g \
              | sed s:_OBSINPUTTMP_:"${OBSINPUTTMP}":g \
              | sed s:_AREA_MASK_:${AREA_MASK}:g \
              > ./GridStat.conf

#$MASTER -c ./main.conf -c ./GridStat.conf

#Step 2
echo "Step2: Stat_Analysis for $MODELNAME vs. $OBSNAME from $SDATE to $EDATE"

# determine valid time list for stat_analysis
tmpedate=`$NDATE $SDATE 24`
CDATE=$SDATE
while [ $CDATE -lt $tmpedate ];
do
  HH=`echo $CDATE | cut -c9-10`
  if [ -z "$VALIDHLIST" ]; then
     VALIDHLIST="$HH"
  else
     VALIDHLIST="$VALIDHLIST, $HH"
  fi
  CDATE=`$NDATE $CDATE $INC_H`
done

for msk in $MSKLIST
do
  if [ -z "$AREAMASKNAME" ]; then
     AREAMASKNAME="${msk}"
  else
     AREAMASKNAME="$AREAMASKNAME,${msk}"
  fi
done

INCONFIG=${CONFIG_DIR}/StatAnalysis.conf.IN
cat $INCONFIG | sed s:_SDATE_:${SDATE}:g \
              | sed s:_EDATE_:${EDATE}:g \
              | sed s:_GRID_NAME_:${GRID_NAME}:g \
              | sed s:_MODELNAME_:${MODELNAME}:g \
              | sed s:_OBSNAME_:${OBSNAME}:g \
              | sed s:_VALIDHLIST_:"${VALIDHLIST}":g \
              | sed s:_FCSTVAR_:${FCSTVAR}:g \
              | sed s:_OBSVAR_:${OBSVAR}:g \
              | sed s:_AREAMASKNAME_:"${AREAMASKNAME}":g \
              | sed s:_LINETYPELIST_:${LINETYPELIST}:g \
              > ./StatAnalysis.conf

#$MASTER -c ./main.conf -c ./StatAnalysis.conf

#Step3
OUTPUT_BASE=`grep OUTPUT_BASE ./main.conf | awk '{print $3}'`
echo $OUTPUT_BASE
TMPSAPATH=`grep "STAT_ANALYSIS_OUTPUT_DIR =" $CONFIG_DIR/StatAnalysis.conf.IN | awk '{print $3}' | sed -e 's/{OUTPUT_BASE}/${OUTPUT_BASE}/g'`
SAPATH=`eval echo $TMPSAPATH`
echo $SAPATH

if [ ! -s $OUTPUT_BASE/stat_images ]; then
   mkdir $OUTPUT_BASE/stat_images
fi

for LINETYPE in $LINETYPELIST
do
for AREAMSK in $MSKLIST
do

INPYSCRIPT=${PY_DIR}/plt_grid_stat_anl.py.IN
cat $INPYSCRIPT | sed s:_BASE_:${BASE}:g \
                | sed s:_SDATE_:${SDATE}:g \
                | sed s:_EDATE_:${EDATE}:g \
                | sed s:_INC_H_:${INC_H}:g \
                | sed s:_SAPATH_:${SAPATH}:g \
                | sed s:_MODELNAME_:${MODELNAME}:g \
                | sed s:_OBSNAME_:${OBSNAME}:g \
                | sed s:_AREAMSK_:${AREAMSK}:g \
                | sed s:_OBSVAR_:${OBSVAR}:g \
                | sed s:_LINETYPE_:${LINETYPE}:g \
                > ./plt_grid_stat_anl.py

if [ -s ./plt_grid_stat_anl.py ]; then
   python ./plt_grid_stat_anl.py > ./plt_grid_stat_anl.out 2>&1
   if [[ $? == 0 ]] ; then
      mv ./*.png $OUTPUT_BASE/stat_images
   fi
fi
done
done



