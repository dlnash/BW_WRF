#!/bin/bash
#############################################################################
# Filename:    WPS_ungrib.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script torun ungrib.exe
#
#############################################################################
## switch to WPS directory
cd /u/eot/dlnash/scratch/WRF_WPS_build_4.2/WPS-4.2/

## load modules
echo "Loading modules..."
# do this before loading any PrgEnv since it switches to PrgEnv-gnu
module load JasPer/2.0.14-CrayGNU-2018.12
module swap PrgEnv-gnu PrgEnv-cray

# configure programming environment
module swap PrgEnv-cray PrgEnv-intel
module load cray-netcdf
export NETCDF=${NETCDF_DIR}
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

# JasPer and png libraries are only provided as a dynamic library, not static ones
export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes

# trying hugepages
module load craype-hugepages8M

CASE_NAME="20211026_case"
##################
### RUN UNGRIB ###
##################
echo "Data downloaded, preparing to run ungrib.exe..."

### Run for SFC Files ###
## Step 1: Modify namelist.wps
## do not need to do this for sfc files as the file already has the right path

## Step 2: Run link_grib.csh to link the grb sfc files to the current directory
./link_grib.csh /u/eot/dlnash/scratch/data/wrf/${CASE_NAME}/InputData/ERA5_sfc/* 

## Step 3: Run ungrib
#aprun -n 1 ./ungrib.exe
./ungrib.exe

## Step 4: Clean up tmp files
rm GRIB*

echo "Surface files ungribbed"

### Run for PRS Files ###

## Step 1: Modify namelist.wps
## change prefix to indicate you are now processing prs files
#sed 's/ERA5_sfc/ERA5_prs/1' namelist.wps

## Step 2: Run link_grib.csh to link the grb prs files to the current directory
#./link_grib.csh /u/eot/dlnash/scratch/data/wrf/${CASE_NAME}/InputData/ERA5_prs/* 

## Step 3: Run ungrib
#./ungrib.exe ## do we need to make this an aprun?

## Step 4: Clean up tmp files
#rm GRIB*

#echo "Pressure files ungribbed"
