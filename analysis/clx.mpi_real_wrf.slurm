#!/bin/bash
#----------------------------------------------------
# Sample Slurm job script
#   for TACC Frontera CLX nodes
#
#   *** MPI Job in Normal Queue ***
# 
# Last revised: 20 May 2019
#
# Notes:
#
#   -- Launch this script by executing
#      "sbatch clx.mpi.slurm" on a Frontera login node.
#
#   -- Use ibrun to launch MPI codes on TACC systems.
#      Do NOT use mpirun or mpiexec.
#
#   -- Max recommended MPI ranks per CLX node: 56
#      (start small, increase gradually).
#
#   -- If you're running out of memory, try running
#      fewer tasks per node to give each task more memory.
#
#----------------------------------------------------

#SBATCH -J real_mptest1           # Job name
#SBATCH -o rsl.o%j                # Name of stdout output file
#SBATCH -e rsl.e%j                # Name of stderr error file
#SBATCH -p normal                 # Queue (partition) name
#SBATCH -N 50                     # Total # of nodes 
#SBATCH --ntasks-per-node 32      # MPI tasks per node
## #SBATCH -n 32                   # Total # of mpi tasks
#SBATCH -t 08:00:00               # Run time (hh:mm:ss)
#SBATCH --mail-type=all           # Send email at begin and end of job
#SBATCH -A ATM21023               # Project/Allocation name (req'd if you have more than 1)
#SBATCH --mail-user=dlnash@ucsb.edu

# Any other commands must follow all #SBATCH directives...
module load netcdf
export NETCDF=${TACC_NETCDF_DIR}
## set paths for libraries
export DIR=/work2/08540/dlnash/frontera/WRF_WPS_build_4.2/LIBRARIES
export CC=gcc
export CXX=g++
export FC=gfortran
export FCFLAGS=-m64
export F77=gfortran
export FFLAGS=-m64
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
export PATH=$DIR/mpich/bin:$PATH

# these two stack settings are essential for use with Intel-compiled code
ulimit -s unlimited
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export OMP_STACKSIZE=6G

# Launch MPI code... 
# ibrun ./myprogram         # Use ibrun instead of mpirun or mpiexec

################
### RUN REAL ###
################
echo "Running real..."
ibrun ./real.exe

## Clean up files
echo "Real complete, cleaning up files..."

# Copy real results to stash directory
DATA_DIR='/scratch1/08540/dlnash/data/wrf/20220511_case/'
cp namelist.input $DATA_DIR
INTDIR_NAME=$DATA_DIR'IntermediateData/real/'
cp wrfbdy_d01 $INTDIR_NAME
cp wrfinput_d* $INTDIR_NAME
cp wrflowinp_d* $INTDIR_NAME

### Make error directory and move error files
ERRDIR_NAME=$DATA_DIR'ErrOutput/REAL/4369630'$SLURM_JOB_ID
mkdir $ERRDIR_NAME
mv rsl* $ERRDIR_NAME


###############
### RUN WRF ###
###############
# echo "Running wrf..."
# ibrun ./wrf.exe

## Clean up files
# echo "wrf complete, cleaning up files..."
# cp namelist.input $DATA_DIR
# ERRDIR_NAME=$DATA_DIR'ErrOutput/WRF/4369630'$SLURM_JOB_ID
# mkdir $ERRDIR_NAME
# mv rsl* $ERRDIR_NAME
