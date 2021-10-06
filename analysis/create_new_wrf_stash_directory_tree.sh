#!/bin/bash
######################################################################
# Filename:    create_new_wrf_stash_directory_tree.sh
# Author:      Deanna Nash dlnash@ucsb.edu
# Description: Script to create a new directory tree for stashing wrf run files.
#
######################################################################

CASE_NAME="20211006_case"
cd ~/DATA_WRF/

mkdir -p ${CASE_NAME}/{InputData/{ERA5_sfc,ERA5_prs},IntermediateData/{geogrid,ungrib,metgrid,real},AnalysisData,ErrOutput/{WPS,WRF,REAL}}

## Create a new repo directory structure
# REPO_NAME="BW_WRF"
# mkdir -p ${REPO_NAME}/{analysis,data,figs,modules,out}