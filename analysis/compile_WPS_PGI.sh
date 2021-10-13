#!/bin/bash
######################################################################
# Filename:    compile_WPS.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to compile WPS on BW using Intel environment
# Directions: Run in the WRF_WPS_Build_<version>/WPS directory
#
######################################################################

# move to the WPS directory
WPS_DIR="/u/eot/dlnash/scratch/WRF_WPS_build_4.3/WPS/"
cd $WPS_DIR

# make sure the directory is clean
./clean

# do this before loading any PrgEnv since it switches to PrgEnv-gnu
module load JasPer/2.0.14-CrayGNU-2018.12
module swap PrgEnv-gnu PrgEnv-cray

# configure programming environment
module swap PrgEnv-cray PrgEnv-pgi
module load cray-netcdf
export NETCDF=${NETCDF_DIR}
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
# need to load a newer version of gcc
module load gcc/6.3.0
# trying hugepages
module load craype-hugepages8M

# JasPer and png libraries are only provided as a dynamic library, not static ones
export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes

# run configure
./configure

# Choose option 39

# have to hack configure.wps to use Cray Wrappers
# here intel compilers are used but similar changes are required for 
# GNU, and PGI compilers
echo "Editing configure.wps to use Cray wrappers"
sed -i '/^SFC/s/pgf90/ftn/g' configure.wps
sed -i '/^DM_FC/s/mpif90 .*/ftn/g' configure.wps
sed -i '/^SCC/s/pgcc/cc/g' configure.wps
sed -i '/^DM_CC/s/mpicc .*/cc/g' configure.wps

# add -fopenmp for OpenMP support (link failures otherwise)
# here intel compilers are used but similar changes are required for
# GNU, and PGI compilers
sed -i '/^FFLAGS/s/$/ -fopenmp/g' configure.wps
sed -i '/^F77FLAGS/s/$/ -fopenmp/g' configure.wps
sed -i '/^LDFLAGS/s/$/ -fopenmp/g' configure.wps
sed -i '/^CFLAGS/s/$/ -fopenmp/g' configure.wps
sed -i '/^CPPFLAGS/s/$/ -fopenmp/g' configure.wps

# (optional) ensure that libjasper is found at runtime
sed -i "/^COMPRESSION_LIBS/s#-ljasper#-Wl,--rpath,$EBROOTJASPER/lib64 -ljasper#" configure.wps

# to compile WPS
./compile >& log.compile

echo "Compilation Complete - use 'tail log.compile' to check if compiled correctly."
