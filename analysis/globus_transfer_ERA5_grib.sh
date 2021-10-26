#!/bin/bash
######################################################################
# Filename:    globus_ungrib.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to download ERA5 grib files for WRF real simulations
#
######################################################################
## load python module that has globus installed
module load bwpy/2.0.2

# Run era5_grb_filenames.py to write list of filenames (both prs and sfc files) to txt file
python era5_grb_filenames.py
## Can we get year and day from python script??
YR="2010"
MON="02"
for i in `cat era5_prs_filenames.txt `
  do
      echo "$i $i"
  done > era5_prs_filenames_src_dest.txt
for i in `cat era5_sfc_filenames.txt `
  do
      echo "$i $i"
  done > era5_sfc_filenames_src_dest.txt

## login to globus
globus login 

## you may need to login via chrome and paste in activation code?
## activate the blue waters endpoint - do I need to do this every time?
# globus endpoint activate --web d59900ef-6d04-11e5-ba46-22000b92c6ec

## click on URL
## activate endpoint (only activates for 10 days at a time)
## can also activate by going on globus app and clicking endpoints-ncsa-activate



## NCAR/UCAR Research Data Archive endpoint
ep1=1e128d3c-852d-11e8-9546-0a6d4e044368
## NCSA endpoint
ep2=d59900ef-6d04-11e5-ba46-22000b92c6ec

##########################
## PRESSURE LEVEL FILES ##
##########################
run1_path=/ds633.0/e5.oper.an.pl/$YR$MON/
dest1_path=/u/eot/dlnash/scratch/data/wrf/20210903_case/InputData/ERA5_prs/

SRC=$ep1:$run1_path
echo $SRC
DEST=$ep2:$dest1_path
echo $DEST

# globus transfer --batch $ep1:$run1_path $ep2:$dest1_path < era5_prs_filenames_prs_dest.txt

task_id="$(globus transfer $ep1:$run1_path $ep2:$dest1_path     --jmespath 'task_id' --format=UNIX     --batch era5_prs_filenames_prs_dest.txt)"

echo "Waiting on 'globus transfer' task '$task_id'"
globus task wait "$task_id" --timeout 90
if [ $? -eq 0 ]; then
    echo "$task_id completed successfully";
else
    echo "$task_id failed!";
fi

#########################
## SURFACE LEVEL FILES ##
#########################
run2_path=/ds633.0/e5.oper.an.sfc/$YR$MON/
dest2_path=/u/eot/dlnash/scratch/data/wrf/20210903_case/InputData/ERA5_sfc/

SRC=$ep1:$run2_path
echo $SRC
DEST=$ep2:$dest2_path
echo $DEST

# globus transfer --batch $ep1:$run2_path $ep2:$dest2_path < era5_sfc_filenames_src_dest.txt

task_id="$(globus transfer $ep1:$run2_path $ep2:$dest2_path     --jmespath 'task_id' --format=UNIX     --batch era5_sfc_filenames_src_dest.txt)"

echo "Waiting on 'globus transfer' task '$task_id'"
globus task wait "$task_id" --timeout 90
if [ $? -eq 0 ]; then
    echo "$task_id completed successfully";
else
    echo "$task_id failed!";
fi

##################
### RUN UNGRIB ###
##################
## switch to WPS directory
cd /u/eot/dlnash/scratch/WRF_WPS_build_4.2/WPS-4.2/

### Run for SFC Files ###
## Step 1: Modify namelist.wps
## do not need to do this for sfc files as the file already has the right path

## Step 2: Run link_grib.csh to link the grb sfc files to the current directory
./link_grib.csh /u/eot/dlnash/scratch/data/wrf/20210903_case/InputData/ERA5_sfc/* 

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
./link_grib.csh /u/eot/dlnash/scratch/data/wrf/20210903_case/InputData/ERA5_prs/* 

## Step 3: Run ungrib
./ungrib.exe ## do we need to make this an aprun?

## Step 4: Clean up tmp files
rm GRIB*

echo "Pressure files ungribbed"


