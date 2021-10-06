#!/bin/bash
### set the number of nodes
### set the number of PEs per node
#PBS -l nodes=40:ppn=32:xe
### set the wallclock time
#PBS -l walltime=15:00:00
### set the job name
#PBS -N real_wrf.test.nash
### set the job stdout and stderr
#PBS -e $PBS_JOBID.err
#PBS -o $PBS_JOBID.out
### set email notification
#PBS -m bea
#PBS -M dlnash@ucsb.edu
### In case of multiple allocations, select which one to charge
#PBS -A bbgc

# NOTE: lines that begin with "#PBS" are not interpreted by the shell but ARE
# used by the batch system, wheras lines that begin with multiple # signs,
# like "##PBS" are considered "commented out" by the batch system
# and have no effect.

# If you launched the job in a directory prepared for the job to run within,
# you'll want to cd to that directory
# [uncomment the following line to enable this]
cd $PBS_O_WORKDIR

# Alternatively, the job script can create its own job-ID-unique directory
# to run within.  In that case you'll need to create and populate that
# directory with executables and perhaps inputs
# [uncomment and customize the following lines to enable this behavior]
# mkdir -p /scratch/sciteam/$USER/$PBS_JOBID
# cd /scratch/sciteam/$USER/$PBS_JOBID
# cp /scratch/job/setup/directory/* .

# To add certain modules that you do not have added via ~/.modules
#. /opt/modules/default/init/bash
#module load craype-hugepages2M  perftools
module swap PrgEnv-cray PrgEnv-intel
module load cray-netcdf
export NETCDF=${NETCDF_DIR}
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
MPICH_GNI_MALLOC_FALLBACK=enabled

### launch the application
### redirecting stdin and stdout if needed
### NOTE: (the "in" file must exist for input)
################
### RUN REAL ###
################
echo "Running real..."
aprun -n 1280 ./real.exe

## Clean up files
echo "Real complete, cleaning up files..."

# Copy real results to stash directory
DATA_DIR='/u/eot/dlnash/scratch/data/wrf/20211006_case/'
INTDIR_NAME=$DATA_DIR'IntermediateData/real/'
cp wrfbdy_d01 $INTDIR_NAME
cp wrfinput_d* $INTDIR_NAME
cp wrflowinp_d* $INTDIR_NAME

### Make error directory and move error files
ERRDIR_NAME=$DATA_DIR'ErrOutput/REAL/'$PBS_JOBID
mkdir $ERRDIR_NAME
mv rsl* $ERRDIR_NAME


###############
### RUN WRF ###
###############
echo "Running wrf..."
aprun -n 1280 ./wrf.exe

## Clean up files
echo "wrf complete, cleaning up files..."
ERRDIR_NAME=$DATADIR'ErrOutput/WRF/'$PBS_JOBID
mkdir $ERRDIR_NAME
mv rsl* $ERRDIR_NAME
