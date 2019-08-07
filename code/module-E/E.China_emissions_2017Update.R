#------------------------------------------------------------------------------
# Program Name: E.China_emissions_2017Update.R
# Authors' Names: Erin McDuffie (adapted from E.China_emissions.R)
# Date Last Modified: August 6, 2019
# Program Purpose: To read in and reformat China emissions inventory data
# This data only contains data from 2010-2017.
# Units are initially in Tg, converted to kt
# Input Files: Fig3_MEIC_detail_Zheng_etal_2018.xlsx
# Output Files: E.[em]_CHN_2_inventory.csv
# Notes: 
# ------------------------------------------------------------------------------
# 0. Read in global settings and headers

# Define PARAM_DIR as the location of the CEDS "parameters" directory, relative
# to the "input" directory.
PARAM_DIR <- if("input" %in% dir()) "code/parameters/" else "../code/parameters/"

# Get emission species first so can name log appropriately
args_from_makefile <- commandArgs( TRUE )
em <- args_from_makefile[ 1 ]
if ( is.na( em ) ) em <- "SO2"

# Call standard script header function to read in universal header files - 
# provide logging, file support, and system functions - and start the script log.
headers <- c( 'common_data.R', "data_functions.R", 
              "emissions_scaling_functions.R", "analysis_functions.R" ) # Additional function files required.
log_msg <- "Secondary reformatting of China emissions" # First message to be printed to the log
script_name <- "E.China_emissions_2017Update.R"

source( paste0( PARAM_DIR, "header.R" ) )
initialize( script_name, log_msg, headers )

# ------------------------------------------------------------------------------
# 1. Define parameters for inventory-specific script
inventory_data_file <- 'Fig3_MEIC_detail_Zheng_etal_2018'
inv_data_folder <- "EM_INV"
subfolder_name <- 'China/'
inv_name <- 'CHN_2' #for naming diagnostic files
inv_years<-c( 2010:2017 )


# ------------------------------------------------------------------------------
# 2. Inventory in Standard Form (iso-sector-fuel-years, iso-sector-years, etc)

# Import Sheets containing selected species data.
sheet_name <- em
inv_data_sheet <- readData( inv_data_folder, inventory_data_file,
                                  ".xlsx", sheet_selection = sheet_name,
                            domain_extension = subfolder_name, skip=2)

# Reformat data into sector X year data frame
sectors <- t( inv_data_sheet[1, 2:ncol(inv_data_sheet)] )
years <- paste0("X", inv_data_sheet[ 2:nrow(inv_data_sheet) , 1 ] )
inv_data_species <- data.frame( sectors )
names(inv_data_species) <-"sector"

for (i in 1:length(inv_years) ) {
  irow <- which(inv_data_sheet == inv_years[ i ])  #find the row of the given inventory year
  inv_data_species$newcol <- t( inv_data_sheet[irow, 2:ncol(inv_data_sheet)] ) #make new column with yearly data
  colnames(inv_data_species)[i+1] <- paste0("X", inv_data_sheet[ irow, 1 ] )   #rename column with year
}

# Clean rows and columns to standard format
inv_data_species$iso <- 'chn'
inv_data_species <- inv_data_species[ , c( 'iso', 'sector', 
                                           paste0( 'X', inv_years ) ) ]

# Make numeric
inv_data_species[ , paste0( 'X', inv_years ) ] <- 
  sapply( inv_data_species[ , paste0( 'X', inv_years ) ],
          as.numeric )

# Convert from Tg to kt
inv_data_species[ , paste0( 'X', inv_years ) ] <- 
  as.matrix( inv_data_species[ , paste0( 'X', inv_years ) ] ) * 1000

# ------------------------------------------------------------------------------
# 3. Write out standard form inventory
writeData( inv_data_species, domain = "MED_OUT", 
           paste0( 'E.', em, '_', inv_name, '_inventory' ) )

logStop()
# END

