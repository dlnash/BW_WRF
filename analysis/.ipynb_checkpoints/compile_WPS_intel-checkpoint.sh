#!/bin/bash
######################################################################
# Filename:    compile_WPS.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to compile WPS on BW using Intel environment
# Directions: Run in the WRF_WPS_Build_<version>/WPS directory
#
######################################################################

# move to the WPS directory
WPS_DIR="/work2/08540/dlnash/frontera/WRF_WPS_build_4.2/WPS-4.2/"
cd $WPS_DIR

# make sure the directory is clean
echo "cleaning WPS directory"
./clean -a

echo "Loading modules..."
module load netcdf
export NETCDF=${TACC_NETCDF_DIR}
export JASPERLIB=$DIR/grib2/lib
export JASPERLIB=$DIR/grib2/include

# set WRF_DIR
WRF_DIR="/work2/08540/dlnash/frontera/WRF_WPS_build_4.2/WRF-4.2.2"
export WRF_DIR=${WRF_DIR}

echo "Configuring WPS. Choose option 19."
# run configure
./configure

echo "Compiling WPS..."
# to compile WPS
./compile >& log.compile

echo "Compilation Complete - use 'tail log.compile' to check if compiled correctly."

### Link Tables
echo "Linking appropriate tables..."
# in WPS directory
ln -sf ungrib/Variable_Tables/Vtable.ERA-interim.pl Vtable

# in WPS/geogrid/ directory
cd geogrid/
ln -sf GEOGRID.TBL.ARW GEOGRID.TBL

# in WPS/metgrid directory
cd ../metgrid/
ln -sf METGRID.TBL.ARW METGRID.TBL
