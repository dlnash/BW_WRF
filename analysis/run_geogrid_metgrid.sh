#!/bin/bash
### set the number of nodes
### set the number of PEs per node
#PBS -l nodes=40:ppn=32:xe
### set the wallclock time
#PBS -l walltime=03:30:00
### set the job name
#PBS -N geogrid_metgrid.test.nash
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
module load JasPer/2.0.14-CrayGNU-2018.12
module swap PrgEnv-gnu PrgEnv-cray

module swap PrgEnv-cray PrgEnv-intel
module load cray-netcdf
export NETCDF=${NETCDF_DIR}
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes

### launch the application
### redirecting stdin and stdout if needed
### NOTE: (the "in" file must exist for input)

### run geogrid
echo "Running geogrid"
aprun -n 1280 ./geogrid.exe
echo "Geogrid complete, cleaning up geogrid files..."

### check filesizes when complete
### if filesizes are bigger than x, continue

### clean up geogrid log files
DATA_DIR='/u/eot/dlnash/scratch/data/wrf/20211006_case/'
mv geogrid.log.* $DATA_DIR'ErrOutput/WPS/'
### copy output geogrid files to stash directory
cp geo_em.d*.nc $DATA_DIR'IntermediateData/geogrid/'

### run metgrid
echo "Running metgrid"
aprun -n 1280 ./metgrid.exe
echo "Metgrid complete, cleaning up metgrid files..."

### check files

### clean up metgrid log files
mv metgrid.log.* $DATA_DIR'ErrOutput/WPS/'

echo "WPS complete."

