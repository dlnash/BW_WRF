#!/bin/bash
######################################################################
# Filename:    compile_WRF.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to compile WRF on BW using Intel environment
# Directions: Run in the WRF_WPS_Build_<version>/WRF directory
#
######################################################################

# Configure your programming environment (the prefix "cray-" on the "netcdf" module name has nothing to do with which compiler is being used)
module swap PrgEnv-cray PrgEnv-intel
module load cray-netcdf
export NETCDF=${NETCDF_DIR}
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
# also run this!
export WRF_EM_CORE=1
export J="-j 8"

# There are a few things that need to be manually changed before building WRF on Blue Waters.  
# When you run the configure script, you will be presented with several choices based on the compiler and type of parallelization desired
# - choose the first of the Intel compiler options.
echo "Choose option 16 and 1 during configuration"
./configure

# After running the configure script, a file called "configure.wrf" will be generated.  
# It may be necessary to edit this file, and manually change the names of the Fortran and C compilers
# to "ftn" and "cc" (don't use "icc"), respectively. 
# You can use these sed lines to affect the changes:
sed -i '/^SFC/s/ifort/ftn/g' configure.wrf
sed -i '/^DM_FC/s/mpif90/ftn/g' configure.wrf
sed -i '/^SCC/s/icc/cc/g' configure.wrf
sed -i '/^CCOMP/s/icc/cc/g' configure.wrf
sed -i '/^DM_CC/s/mpicc/cc/g' configure.wrf

# compile WRF
./compile em_real >& compile.log

echo "Compilation Complete - use 'tail compile.log' to check if compiled correctly.