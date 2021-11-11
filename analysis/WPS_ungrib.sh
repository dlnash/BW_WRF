#!/bin/bash
#############################################################################
# Filename:    WPS_ungrib.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script torun ungrib.exe
#
#############################################################################

##################
### RUN UNGRIB ###
##################
echo "Data downloaded, preparing to run ungrib.exe..."
## switch to WPS directory
cd /u/eot/dlnash/scratch/WRF_WPS_build_4.2/WPS-4.2/

### Run for SFC Files ###
## Step 1: Modify namelist.wps
## do not need to do this for sfc files as the file already has the right path

## Step 2: Run link_grib.csh to link the grb sfc files to the current directory
./link_grib.csh /u/eot/dlnash/scratch/data/wrf/${CASE_NAME}/InputData/ERA5_sfc/* 

## Step 3: Run ungrib
./ungrib.exe ## do we need to make this an aprun?

## Step 4: Clean up tmp files
rm GRIB*

echo "Surface files ungribbed"

### Run for PRS Files ###

## Step 1: Modify namelist.wps
## change prefix to indicate you are now processing prs files
sed 's/ERA5_sfc/ERA5_prs/1' namelist.wps

## Step 2: Run link_grib.csh to link the grb prs files to the current directory
./link_grib.csh /u/eot/dlnash/scratch/data/wrf/${CASE_NAME}/InputData/ERA5_prs/*

## Step 3: Run ungrib
./ungrib.exe ## do we need to make this an aprun?

## Step 4: Clean up tmp files
rm GRIB*

echo "Pressure files ungribbed"