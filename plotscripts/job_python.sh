#!/bin/bash --login
##!/bin/sh --login

#SBATCH --account=chem-var
#SBATCH --qos=debug
#SBATCH --nodes=1 --ntasks-per-node=1 --cpus-per-task=1
#SBATCH --time=00:29:00
#SBATCH --job-name=pythonJob
#SBATCH --output=pythonJob.out


export OMP_NUM_THREADS=1

set -x 

module use -a /contrib/anaconda/modulefiles
module load anaconda/latest

EXPDIR="/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/METplus_pkg/"
MODELNAME="CAMS"
OBSNAME="FV3"
OBSNAME1="MERRA2"

nvars=7
FCSTVARS=(DUSTTOTAL SEASTOTAL aermr07  aermr08  aermr09  aermr10  aermr11)
OBSVARS=(DUSTTOTAL SEASTOTAL OCPHILIC OCPHOBIC BCPHILIC BCPHOBIC SO4)
MSKLIST="FULL TROP CONUS EASIA NAFRME RUSC2S SAFRTROP SOCEAN"
#MSKLIST="FULL"

#for ((ivar=0;ivar<${nvars};ivar++))
#do
#    FCSTVAR=${FCSTVARS[ivar]}
#    OBSVAR=${OBSVARS[ivar]}
#    for MASK in ${MSKLIST}
#    do
#	python ./plt_grid_stat_anl.py ${EXPDIR} ${MODELNAME} ${OBSNAME} ${OBSNAME1} ${FCSTVAR} ${OBSVAR} ${MASK}
#    done
#    PLOTDIR=${MODELNAME}-${OBSNAME}-${OBSNAME1}/${FCSTVAR}-${OBSVAR}
#    mkdir -p ${PLOTDIR}
#    #mv *.eps ${PLOTDIR}
#    mv *.png ${PLOTDIR}
#
#done

FCSTVAR="aod550"
OBSVAR="aod"
OBSVAR1="AODANA"
for MASK in ${MSKLIST}
do
    python ./plt_grid_stat_anl_aod.py ${EXPDIR} ${MODELNAME} ${OBSNAME} ${OBSNAME1} ${FCSTVAR} ${OBSVAR} ${OBSVAR1} ${MASK}
done
PLOTDIR=${MODELNAME}-${OBSNAME}-${OBSNAME1}/${FCSTVAR}-${OBSVAR}
mkdir -p ${PLOTDIR}
#mv *.eps ${PLOTDIR}
mv *.png ${PLOTDIR}

exit $?
