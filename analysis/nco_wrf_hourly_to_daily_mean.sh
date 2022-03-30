#!/bin/bash
######################################################################
# Filename:    nco_wrf_hourly_to_daily_mean.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to get daily mean from hourly wrf output
#
# - Convert hourly wrf data to daily
# - To run: change input parameters, then go to NCO_NRCAT directory
# - "conda activate nco-env", then run "bash nco_wrf_hourly_to_daily_mean.sh"
######################################################################

# Input parameters
case_name='20211113_case'
datadir="~/DATA_WRF/${case_name}/AnalysisData/"
outdir="~/DATA_WRF/${case_name}/AnalysisData/"

outer=1      # set outer loop counter

# Loop to concatenate all files within month-year into 1 netcdf file
# Begin outer loop (e.g. each year)
cd $datadir
for year in $(seq $start_yr $end_yr)
do
    echo "Pass $outer in outer loop."
    inner=1    # reset inner loop counter
    infile="wrfout_${domain}.2010-02-03_00:00:00"
    echo "$infile"
    outfile="${outdir}out.era5_${region}_${resol}dg_daily_${vars}_${year}.nc"
    echo "$outfile"
    # calculate daily mean from 6hourly
    cdo daymean ${infile} ${outfile}

    let "outer+=1" # Increment outer loop counter
    echo "$year daymean complete"
    echo           # Space between output blocks in pass of outer loop

done
# End of outer loop

exit 0