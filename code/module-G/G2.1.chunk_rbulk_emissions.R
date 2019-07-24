# ------------------------------------------------------------------------------
# Program Name: G2.1.chunk_rbulk_emissions.R
# Authors: Erin McDuffie, adapted from Leyang Feng, Caleb Braun
# Date Last Updated: July 4, 2019
# Program Purpose: Generate multi-year emissions chunks for bulk emissions.
# Input Files: CEDS_[em]_anthro_[year]_0.5.nc
# Output Files: FIN_OUT: [em]-em-anthro_input4MIPs_emissions_CMIP_CEDS-[CEDS_grid_version]_supplement-data_gn_[time_range].nc
# ------------------------------------------------------------------------------


# Define PARAM_DIR as the location of the CEDS "parameters" directory, relative
# to the "input" directory.
PARAM_DIR <- if("input" %in% dir()) "code/parameters/" else "../code/parameters/"

# Read in universal header files, support scripts, and start logging
headers <- c( 'gridding_functions.R', 'nc_generation_functions.R' )
log_msg <- "Generates chunk NetCDF files for remaining bulk emissions"
source( paste0( PARAM_DIR, "header.R" ) )
initialize( "G2.1.chunk_rbulk_emissions.R", log_msg, headers )

# Define emissions species variable
args_from_makefile <- commandArgs( TRUE )
em <- args_from_makefile[ 1 ]
if ( is.na( em ) ) em <- "BC"

# Chunk bulk emissions
chunk_emissions( singleVarChunking_rbulkemissions, em )

logStop()

