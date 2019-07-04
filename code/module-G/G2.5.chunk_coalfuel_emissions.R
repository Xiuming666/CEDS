# ------------------------------------------------------------------------------
# Program Name: G2.5.chunk_coalfuel_emissions.R
# Authors: Erin McDuffie, based on code from Leyang Feng, Caleb Braun
# Date Last Updated: June 26, 2019
# Program Purpose: Generate multi-year emissions chunks for total coal emissions.
# Input Files: CEDS_[em]_coalfuel_anthro_[year]_0.5_[CEDS_version].nc
# Output Files: FIN_OUT: [em]-em-TOTAL_COALFUEL-anthro_input4MIPs_emissions_CMIP_CEDS-[CEDS_grid_version]_supplement-data_gn_[time_range].nc
# ------------------------------------------------------------------------------


# Define PARAM_DIR as the location of the CEDS "parameters" directory, relative
# to the "input" directory.
PARAM_DIR <- if("input" %in% dir()) "code/parameters/" else "../code/parameters/"

# Read in universal header files, support scripts, and start logging
headers <- c( 'gridding_functions.R', 'nc_generation_functions.R' )
log_msg <- "Generates chunk NetCDF files for total coal fuel emissions"
source( paste0( PARAM_DIR, "header.R" ) )
initialize( "G2.5.chunk_coalfuel_emissions.R", log_msg, headers )

# Define emissions species variable
args_from_makefile <- commandArgs( TRUE )
em <- args_from_makefile[ 1 ]
if ( is.na( em ) ) em <- "BC"

# Chunk bulk emissions
chunk_emissions( singleVarChunking_coalfuelemissions, em )

logStop()
