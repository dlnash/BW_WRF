#!/bin/bash
######################################################################
# Filename:    compile_WRF.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to compile WRF on Frontera  using Intel environment
# Directions: bash compile_WRF.sh
#
######################################################################
# move to the WRF directory
WRF_DIR="/work2/08540/dlnash/frontera/WRF_WPS_build_4.2/WRF-4.2.2/"
cd $WRF_DIR

# make sure the directory is clean
./clean -a

# Configure your programming environment

module load netcdf
export NETCDF=${TACC_NETCDF_DIR}

# also run this!
export WRF_EM_CORE=1
export J="-j 8"

 
# When you run the configure script, you will be presented with several choices based on the compiler and type of parallelization desired
# - choose the first of the Intel compiler options.
echo "Choose option 15 and 1 during configuration"
./configure

# compile WRF
./compile em_real >& compile.log

echo "Compilation Complete - use 'tail compile.log' to check if compiled correctly."
