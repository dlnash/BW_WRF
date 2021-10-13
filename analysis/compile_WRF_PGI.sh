#!/bin/bash
######################################################################
# Filename:    compile_WRF.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to compile WRF on BW using Intel environment
# Directions: Run in the WRF_WPS_Build_<version>/WRF directory
#
######################################################################
# move to the WPS directory
WRF_DIR="/u/eot/dlnash/scratch/WRF_WPS_build_4.3/WRF/"
cd $WRF_DIR

# make sure the directory is clean
./clean

# Configure your programming environment (the prefix "cray-" on the "netcdf" module name has nothing to do with which compiler is being used)
module swap PrgEnv-cray PrgEnv-pgi
module load cray-netcdf
export NETCDF=${NETCDF_DIR}
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
# also run this!
export WRF_EM_CORE=1
export J="-j 8"
# need to load a newer version of gcc
module load gcc/6.3.0
# trying hugepages
module load craype-hugepages8M

# There are a few things that need to be manually changed before building WRF on Blue Waters.  
# When you run the configure script, you will be presented with several choices based on the compiler and type of parallelization desired
# - choose the first of the PGI compiler options.
echo "Choose option 43 and 1 during configuration"
./configure

# After running the configure script, a file called "configure.wrf" will be generated.  
# It may be necessary to edit this file, and manually change the names of the Fortran and C compilers
# to "ftn" and "cc" (don't use "pgcc"), respectively. 
# You can use these sed lines to affect the changes:
sed -i '/^SFC/s/pgf90/ftn/g' configure.wrf
sed -i '/^DM_FC/s/mpif90/ftn/g' configure.wrf
sed -i '/^SCC/s/pgcc/cc/g' configure.wrf
sed -i '/^CCOMP/s/pgcc/cc/g' configure.wrf
sed -i '/^DM_CC/s/mpicc/cc/g' configure.wrf

# compile WRF
./compile em_real >& compile.log

echo "Compilation Complete - use 'tail compile.log' to check if compiled correctly.