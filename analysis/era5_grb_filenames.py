"""
Filename:    era5_grb_filenames.py
Author:      Deanna Nash, dlnash@ucsb.edu
Description: Create .txt file with list of filenames for prs and sfc files to download from Globus for WRF case study.
"""
## Note that this only works if your case study dates are only in the same month
## TODO add check for dates within same month

import pandas as pd
import calendar

start_date = input("Enter start date (format='YYYY-MM-DD HH:SS'):")
print("Start date is: " + start_date)

end_date = input("Enter end date (format='YYYY-MM-DD HH:SS'):")
print("End date is: " + end_date)

# start_date = '2010-02-05 00:00'
# end_date = '2010-02-09 00:00'

dates = pd.date_range(start=start_date, end=end_date)

## PRS Files

## get the dictionary of filename conventions
fname = 'ds633.0.e5.oper.an.pl.grib1.table.txt'          
df = pd.read_csv(fname, skiprows=range(0, 7), delimiter=r"\s{2,}", engine='python', dtype={'Parameter': object})
prs_dict = df.to_dict(orient='index')

## open new text file to write filenames to
filename = "era5_prs_filenames.txt"
#w tells python we are opening the file to write into it
outfile = open(filename, 'w')

for key in prs_dict:
    name = prs_dict[key]['Name']
    vid = prs_dict[key]['Parameter']
    suffix = prs_dict[key]['Suffix']
    table = prs_dict[key]['Table']
    for i, d in enumerate(dates):
        year = d.strftime('%Y')
        mon = d.strftime('%m')
        day = d.strftime('%d')
        fname = 'e5.oper.an.pl.{6}_{0}_{1}.ll025{5}.{2}{3}{4}00_{2}{3}{4}23.grb'.format(vid, name, year, mon, day, suffix, table)
        outfile.write(fname + '\n')
        
## SFC Files

## get the dictionary of filename conventions
fname = 'ds633.0.e5.oper.an.sfc.grib1.table.txt'          
df = pd.read_csv(fname, skiprows=range(0, 8), delimiter=r"\s{2,}", engine='python', dtype={'Parameter': object})
sfc_dict = df.to_dict(orient='index')

## open new text file to write filenames to
filename = "era5_sfc_filenames.txt"
#w tells python we are opening the file to write into it
outfile = open(filename, 'w')

for key in sfc_dict:
    name = sfc_dict[key]['Name']
    vid = sfc_dict[key]['Parameter']
    table = sfc_dict[key]['Table']
    year = dates[0].strftime('%Y')
    mon = dates[0].strftime('%m')
    # get the last day of the month
    cal_day = calendar.monthrange(dates[0].year, dates[0].month)[-1]
    # function to tell last day of month
    fname = 'e5.oper.an.sfc.{5}_{0}_{1}.ll025sc.{2}{3}0100_{2}{3}{4}23.grb'.format(vid, name, year, mon, cal_day, table)
    outfile.write(fname + '\n')
        
outfile.close() #Close the file when we’re done!