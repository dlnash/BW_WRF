"""
Filename:    wrf_generate_namelist.py
Author:      Deanna Nash, dlnash@ucsb.edu
Description: Create namelist.input and namelist.wps files for running WRF based on dictionary.
"""
# Import modules
import os, sys
import yaml
import itertools
from datetime import datetime, date

# Path to personal modules
sys.path.append('../modules')
# Import my modules
from wrf_funcs import calc_gridpoints_domain, calc_i_j_parent_start, calc_number_nodes_pes

# Set up paths

path_to_data = '../data/'       # project data -- read only                         
path_to_out  = '../out/'       # output files (numerical results, intermediate datafiles) -- read & write
path_to_figs = '../figs/'      # figures

## update the name of the case from the dict file
case_name='feb2010_expand'

# import configuration file for case dictionary choice
yaml_doc = '../data/wrf_casestudy.yml'
config = yaml.load(open(yaml_doc), Loader=yaml.SafeLoader)
case_dict = config[case_name]

# read variables from config file
start_date = case_dict['start_date']
end_date = case_dict['end_date']
timestep = case_dict['timestep']
domains = case_dict['domains']
resolutions = case_dict['resolutions']

## Calculate namelist vars based on config input
parent_grid_ratio = [1, int((resolutions[0]/resolutions[1]))]
e_we, e_sn, ref_lat, ref_lon = calc_gridpoints_domain(domains, resolutions, parent_grid_ratio)
i_prt, j_prt = calc_i_j_parent_start(domains, resolutions)

max_nodes = calc_number_nodes_pes(int(e_we[0]), int(e_sn[0]))
## TODO make this a bash variable
print('Max nodes is', max_nodes)

### vars for namelist.wps and namelist.input

today = date.today()
case_name = today.strftime('%Y%m%d')+'_case'

ndom = len(domains)
# date format for namelist.wps
sdate = list(itertools.repeat(start_date, ndom))
sdate = str(sdate)[1:-1]

edate = list(itertools.repeat(end_date, ndom))
edate = str(edate)[1:-1]

# for namelist.input format of date is a little different
dt_start = datetime.strptime(start_date, '%Y-%m-%d_%H:%S:00')
dt_end = datetime.strptime(end_date, '%Y-%m-%d_%H:%S:00')

start_items = []
end_items = []

date_fmt = ['%Y', '%m', '%d', '%H']
for i, dfmt in enumerate(date_fmt):
    start = dt_start.strftime(dfmt)
#     start = list(itertools.repeat(int(start), ndom))
#     start = str(start)[1:-1]
    start_items.append(start)
    
    end = dt_end.strftime(dfmt)
#     end = list(itertools.repeat(int(end), ndom))
#     end = str(end)[1:-1]
    end_items.append(end)

## id and grid info for domains
p_id = [1]
g_id = [1]
for i in range(ndom-1):
    p_id.append(i+1)
    g_id.append(i+2)
p_id = str(p_id)[1:-1]
g_id = str(g_id)[1:-1]

p_gr = str(parent_grid_ratio)[1:-1]

# i parent start (east-west)
i_parent_start = str(i_prt)[1:-1]
# j parent start (north-south)
j_parent_start = str(j_prt)[1:-1]

# e_we: number of gridpoints in east-west direction
e_we = str(e_we)[1:-1]
# e_sn: number of gridpoints in north-south direction
e_sn = str(e_sn)[1:-1]

# specify the resolution to interpolate static data
geog_data_res = list(itertools.repeat('default', ndom))
geog_data_res = str(geog_data_res)[1:-1]

# the resolution in meters (e.g. 27000 m = 27 km)
dx = str(resolutions[0]*1000)
dy = str(resolutions[0]*1000)

dx2 = str(resolutions[1]*1000)
dy2 = str(resolutions[1]*1000)

# time_step should be no more than child domain dx*6
time_step = resolutions[0]*6

# the type of map projection
map_proj = 'mercator'

# the center lat/lon of the parent domain
ref_lat   =  str(ref_lat)
ref_lon   =  str(ref_lon)

##########################
## NAMELIST.WPS FORMAT ###
##########################
text_lst = ["&share" , \
" wrf_core = 'ARW'," ,\
" max_dom  = {0},".format(ndom) ,\
" start_date = {0},".format(sdate) ,\
" end_date   = {0},".format(edate) ,\
" interval_seconds = {0},".format(timestep*3600) ,\
" io_form_geogrid = 2," ,\
"/" ,\
"" ,\
"&geogrid" ,\
" parent_id         =   {0},".format(p_id) ,\
" parent_grid_ratio =   {0},".format(p_gr) ,\
" i_parent_start    =   {0},".format(i_parent_start) ,\
" j_parent_start    =   {0},".format(j_parent_start) ,\
" e_we              = {0},".format(e_we) ,\
" e_sn              = {0},".format(e_sn) ,\
" geog_data_res     = '2m', '30s',".format(geog_data_res) ,\
" dx = {0},".format(dx) ,\
" dy = {0},".format(dy) ,\
" map_proj = {0},".format(map_proj) ,\
" ref_lat   =  {0},".format(ref_lat) ,\
" ref_lon   =  {0},".format(ref_lon) ,\
" truelat1  =  30.0," ,\

" geog_data_path = '/u/eot/dlnash/data/geog/'" ,\
"/" ,\
"" ,\
"&ungrib" ,\
" out_format = 'WPS'," ,\
" prefix = '/u/eot/dlnash/scratch/data/wrf/{0}/IntermediateData/ungrib/ERA5_sfc',".format(case_name) ,\
"/" ,\
"" ,\
"&metgrid" ,\
" fg_name = '/u/eot/dlnash/scratch/data/wrf/{0}/IntermediateData/ungrib/ERA5_prs','/u/eot/dlnash/scratch/data/wrf/{0}/IntermediateData/ungrib/ERA5_sfc',".format(case_name) ,\
" opt_output_from_metgrid_path = '/u/eot/dlnash/scratch/data/wrf/{0}/IntermediateData/metgrid/',".format(case_name) ,\
" io_form_metgrid = 2, " ,\
"/" ]

filename = "../out/namelist.wps"

#w tells python we are opening the file to write into it
outfile = open(filename, 'w')

for i, tlst in enumerate(text_lst):
    outfile.write(tlst + '\n')

outfile.close() #Close the file when we’re done!

############################
## NAMELIST.INPUT FORMAT ###
############################

text_lst = ["&time_control" ,\
" run_days                            = 0," ,\
" run_hours                           = 0," ,\
" run_minutes                         = 0," ,\
" run_seconds                         = 0," ,\
" start_year                          = {0}, {0},".format(start_items[0]) ,\
" start_month                         = {0}, {0},".format(start_items[1]) ,\
" start_day                           = {0}, {0},".format(start_items[2]) ,\
" start_hour                          = {0}, {0},".format(start_items[3]) ,\
" start_minute                        = 00,    00," ,\
" start_second                        = 00,    00," ,\
" end_year                            = {0}, {0},".format(end_items[0]) ,\
" end_month                           = {0}, {0},".format(end_items[1]) ,\
" end_day                             = {0}, {0},".format(end_items[2]) ,\
" end_hour                            = {0}, {0},".format(end_items[3]) ,\
" end_minute                          = 00,    00," ,\
" end_second                          = 00,    00," ,\
" interval_seconds                    = {0},".format(timestep*3600) ,\
" input_from_file                     = .true., .true.," ,\
" history_interval                    = 180,    60," ,\
" frames_per_outfile                  = 24, 24," ,\
" auxinput1_inname = '/u/eot/dlnash/scratch/data/wrf/{0}/IntermediateData/metgrid/met_em.d<domain>.<date>',".format(case_name) ,\
" history_outname='/u/eot/dlnash/scratch/data/wrf/{0}/AnalysisData/wrfout_d<domain>.<date>',".format(case_name) ,\
" adjust_output_times                 = .true.," ,\
" restart                             = .false.," ,\
" restart_interval                    =  180," ,\
" write_hist_at_0h_rst                = .true.," ,\
" auxinput4_inname                    = 'wrflowinp_d<domain>'" ,\
" auxinput4_interval                  = 60,  60," ,\
" io_form_auxhist23                   = 2," ,\
" io_form_auxinput4                   = 2," ,\
" all_ic_times                        = .false.," ,\
" io_form_history                     = 2," ,\
" io_form_restart                     = 2," ,\
" io_form_input                       = 2," ,\
" io_form_boundary                    = 2," ,\
" debug_level                         = 0," ,\
"/" ,\
"" ,\
"&domains",\
" time_step                           = {0},".format(time_step) ,\
" time_step_fract_num                 = 0," ,\
" time_step_fract_den                 = 1," ,\
" max_dom                             = {0},".format(ndom) ,\
" e_we                                = {0},".format(e_we) ,\
" e_sn                                = {0},".format(e_sn) ,\
" e_vert                              =  55,    55," ,\
" p_top_requested                     = 5000," ,\
" num_metgrid_levels                  = 38," ,\
" num_metgrid_soil_levels             = 4," ,\
"! interp_type                         = 2," ,\
"! extrap_type                         = 2," ,\
"! t_extrap_type                       = 2," ,\
"! lowest_lev_from_sfc                 = .false." ,\
"! use_levels_below_ground             = .true." ,\
"! use_surface                         = .true." ,\
"! lagrange_order                      = 1," ,\
"! force_sfc_in_vinterp                = 1," ,\
"! zap_close_levels                    = 500," ,\
" dx                                  = {0}, {1},".format(dx, dx2) ,\
" dy                                  = {0}, {1},".format(dy, dy2) ,\
" grid_id                             = {0}".format(g_id) ,\
" parent_id                           = {0}".format(p_id) ,\
" i_parent_start                      = {0},".format(i_parent_start) ,\
" j_parent_start                      = {0},".format(j_parent_start) ,\
" parent_grid_ratio                   = {0},".format(p_gr) ,\
" parent_time_step_ratio              = {0},".format(p_gr) ,\
" feedback                            = 0," ,\
" smooth_option                       = 0," ,\
"! nproc_x                             =  40," ,\
"! nproc_y                             =  36," ,\
"! use_adaptive_time_step              = .true.," ,\
"! step_to_output_time                 = .true.," ,\
"! target_cfl                          = 1.2, 1.2," ,\
"! max_step_increase_pct               = 5, 51," ,\
"! starting_time_step                  = -1, -1," ,\
"! max_time_step                       = -1, -1," ,\
"! min_time_step                       = -1, 1," ,\
"! adaptation_domain                   = 2," ,\
"/" ,\
"",\
"&physics" ,\
" mp_physics                          = 8,     8," ,\
" ra_lw_physics                       = 4,     4," ,\
" ra_sw_physics                       = 4,     4," ,\
" radt                                = 9,     9," ,\
" sf_sfclay_physics                   = 1,     1," ,\
" sf_surface_physics                  = 4,     4," ,\
" bl_pbl_physics                      = 1,     1," ,\
" bldt                                = 0,     0," ,\
" cu_physics                          = 1,     0," ,\
" kfeta_trigger                       = 1," ,\
" cudt                                = 5,     5," ,\
"! ishallow                            = 0," ,\
"! shcu_physics                        = 0,     0," ,\
" isfflx                              = 1," ,\
" ifsnow                              = 1," ,\
" icloud                              = 1," ,\
" cu_rad_feedback                     = .true., .true.," ,\
"! cu_diag                             = 0," ,\
"! topo_wind                           = 0,   0," ,\
"! sf_surface_mosaic                   = 0," ,\
"! mosaic_cat                          = 3," ,\
"! slope_rad                           = 0,   0," ,\
"! topo_shading                        = 0,   0," ,\
"! shadlen                             = 25000.," ,\
" surface_input_source                = 1," ,\
" num_soil_layers                     = 4," ,\
" sst_update                          = 1," ,\
"! usemonalb                           = .true.," ,\
"! tmn_update                          = 1," ,\
"! lagday                              = 150," ,\
"! sst_skin                            = 1," ,\
" sf_urban_physics                    = 0,     0," ,\
"! cam_abs_freq_s                      = 21600," ,\
"! levsiz                              = 59," ,\
"! paerlev                             = 29," ,\
"! do_radar_ref    = 1," ,\
"/" ,\
"" ,\
"&noah_mp" ,\
" dveg     = 4," ,\
" opt_crs  = 1," ,\
" opt_btr  = 1," ,\
" opt_run  = 1," ,\
" opt_sfc  = 1," ,\
" opt_frz  = 1," ,\
" opt_inf  = 1," ,\
" opt_rad  = 3," ,\
" opt_alb  = 2," ,\
" opt_snf  = 1," ,\
" opt_tbot = 2," ,\
" opt_stc  = 1," ,\
"/" ,\
"" ,\
"&fdda",\
" grid_fdda                           = 0,     0," ,\
" gfdda_inname                        = 'wrffdda_d<domain>'," ,\
" gfdda_end_h                         = 99999999, 4320," ,\
" gfdda_interval_m                    = 360,   360," ,\
" fgdt                                = 0,     0," ,\
" fgdtzero                            = 0,     0," ,\
" if_no_pbl_nudging_uv                = 0,     1," ,\
" if_no_pbl_nudging_t                 = 0,     1," ,\
" if_no_pbl_nudging_q                 = 0,     1," ,\
" if_zfac_uv                          = 0,     0," ,\
"  k_zfac_uv                          = 0,     0," ,\
" if_zfac_t                           = 0,     0," ,\
"  k_zfac_t                           = 0,     0," ,\
" if_zfac_q                           = 0,     0," ,\
"  k_zfac_q                           = 0,     0," ,\
" guv                                 = 0.0003,  0.0003," ,\
" gt                                  = 0.0003,  0.0003," ,\
" gq                                  = 0.0003,  0.0003," ,\
" if_ramping                          = 1," ,\
" dtramp_min                          = 60.0," ,\
" io_form_gfdda                       = 2," ,\
"/" ,\
"" ,\
"&dynamics",\
" w_damping                           = 1," ,\
" diff_opt                            = 1, 1," ,\
" km_opt                              = 4, 4," ,\
"! hybrid_opt                          = 0," ,\
" etac                                = 0.2," ,\
" diff_6th_opt                        = 0,         0," ,\
" diff_6th_factor                     = 0.12,   0.12," ,\
" base_temp                           = 290." ,\
" damp_opt                            = 0," ,\
" zdamp                               = 5000.,  5000.," ,\
" dampcoef                            = 0.2,    0.2," ,\
" khdif                               = 0,      0," ,\
" kvdif                               = 0,      0," ,\
" epssm                               = 0.5," ,\
" non_hydrostatic                     = .true., .true.," ,\
" moist_adv_opt                       = 1,      1," ,\
" scalar_adv_opt                      = 1,      1," ,\
"/" ,\
"" ,\
"&bdy_control" ,\
" spec_bdy_width                      = 5," ,\
" spec_zone                           = 1," ,\
" relax_zone                          = 4," ,\
" specified                           = .true., .false.," ,\
" nested                              = .false., .true.," ,\
"/" ,\
"" ,\
"&grib2" ,\
"/" ,\
"" ,\
"&namelist_quilt" ,\
" nio_tasks_per_group = 0," ,\
" nio_groups = 1," ,\
"/"]

filename = "../out/namelist.input"

#w tells python we are opening the file to write into it
outfile = open(filename, 'w')

for i, tlst in enumerate(text_lst):
    outfile.write(tlst + '\n')

outfile.close() #Close the file when we’re done!