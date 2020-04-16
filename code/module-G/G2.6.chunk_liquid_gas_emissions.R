# ------------------------------------------------------------------------------
# Program Name: G2.6.chunk_liquid_gas_emissions.R
# Authors: Erin McDuffie, adapted from Leyang Feng, Caleb Braun
# Date Last Updated: Mar, 24 2020
# Program Purpose: Generate multi-year emissions chunks for bulk emissions.
# Input Files: CEDS_[em]_liguid_gas_[year]_0.5.nc
# Output Files: FIN_OUT: [em]-em-liquid_gas_input4MIPs_emissions_CMIP_CEDS-[CEDS_grid_version]_supplement-data_gn_[time_range].nc
# ------------------------------------------------------------------------------


# Define PARAM_DIR as the location of the CEDS "parameters" directory, relative
# to the "input" directory.
PARAM_DIR <- if("input" %in% dir()) "code/parameters/" else "../code/parameters/"

# Read in universal header files, support scripts, and start logging
headers <- c( 'gridding_functions.R', 'nc_generation_functions.R' )
log_msg <- "Generates chunk NetCDF files for liquid fuel and natural gas emissions"
source( paste0( PARAM_DIR, "header.R" ) )
initialize( "G2.6.chunk_liquid_gas_emissions.R", log_msg, headers )

# Define emissions species variable
args_from_makefile <- commandArgs( TRUE )
em <- args_from_makefile[ 1 ]
if ( is.na( em ) ) em <- "CO"

# Chunk bulk emissions
chunk_emissions( singleVarChunking_liquid_gasemissions, em )

logStop()

