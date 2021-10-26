#!/bin/bash
#############################################################################
# Filename:    preprocess_WPS.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to complete preprocessing tasks to be able to run WPS
#
#############################################################################
## load python module
module load bwpy/2.0.2

### Step 1: Create Case Name for current run
CASE_DATE="date +%Y_%b_%d"
CASE_NAME="${CASE_DATE}_case"
echo "Beginning preparations for ${CASE_NAME}..."

### Step 2: Create Directory Structure
cd ~/DATA_WRF/

mkdir -p ${CASE_NAME}/{InputData/{ERA5_sfc,ERA5_prs},IntermediateData/{geogrid,ungrib,metgrid,real},AnalysisData,ErrOutput/{WPS,WRF,REAL}}

### Step 3: Generate namelist.wps and namelist.input
python wrf_generate_namelist.py

# copy namelist.input and namelist.wps to Directory Stash
cp ../out/namelist.input ~/DATA_WRF/${CASE_NAME}/
cp ../out/namelist.wps ~/DATA_WRF/${CASE_NAME}/
# copy namelist.wps to WPS directory
cp ../out/namelist.wps ~/WPS_4.2/
# copy namelist.input to WRF directory
cp ../out/namelist.input ~/WRF_4.2/

### Step 4: Download .grb files using globus and run ungrib
# Run era5_grb_filenames.py to write list of filenames (both prs and sfc files) to txt file
python era5_grb_filenames.py
## TODO get year and month from wrf_casestudy.yml
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

echo "Filename list created, preparing to download .grb files..."
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
dest1_path=/u/eot/dlnash/scratch/data/wrf/${CASE_NAME}/InputData/ERA5_prs/

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
dest2_path=/u/eot/dlnash/scratch/data/wrf/${CASE_NAME}/InputData/ERA5_sfc/

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
