#------------------------------------------------------------------------------
# Program Name: E.India_emissions.R
# Authors' Names: Erin McDuffie (adapted from E.China_emissions.R)
# Date Last Modified: August 27, 2019
# Program Purpose: To read in and reformat India emissions inventory data
# This data only contains data from 2013.
# Units are initially in ton, converted to kt
# Input Files: India_[em].csv
# Output Files: E.[em]_India_inventory.csv
# Notes:
# ------------------------------------------------------------------------------
# 0. Read in global settings and headers

# Define PARAM_DIR as the location of the CEDS "parameters" directory, relative
# to the "input" directory.
    PARAM_DIR <- if("input" %in% dir()) "code/parameters/" else "../code/parameters/"

# Get emission species first so can name log appropriately
    args_from_makefile <- commandArgs( TRUE )
    em <- args_from_makefile[ 1 ]
    if ( is.na( em ) ) em <- "NOx"

# Call standard script header function to read in universal header files -
# provide logging, file support, and system functions - and start the script log.
    headers <- c( 'common_data.R', "data_functions.R",
              "emissions_scaling_functions.R", "analysis_functions.R" ) # Additional function files required.
    log_msg <- "Secondary reformatting of India emissions" # First message to be printed to the log
    script_name <- "E.India_emissions.R"

    source( paste0( PARAM_DIR, "header.R" ) )
    initialize( script_name, log_msg, headers )

# ------------------------------------------------------------------------------
# 0.5 Settings/Load Files & Convert all txt files to csv
#     Logging does not support txt files, so convert to csv
    MCL <- readData( "MAPPINGS", "Master_Country_List" )
    loadPackage('tools')

# ------------------------------------------------------------------------------
# 1. Define parameters for inventory-specific script
    inventory_data_file <- paste0('India_', em)
    inv_data_folder <- "EM_INV"
    subfolder_name <- 'India/'
    inv_name <- 'India' #for naming diagnostic files
    inv_years<-c( 2013 )


# ------------------------------------------------------------------------------
# 2. Inventory in Standard Form (iso-sector-fuel-years, iso-sector-years, etc)

# Import Sheets containing selected species data.
    inv_data_sheet <- readData( inv_data_folder, inventory_data_file,
                            ".csv", domain_extension = subfolder_name)

    inv_data_sheet_clean <- inv_data_sheet
    inv_data_sheet_clean <- inv_data_sheet_clean[ , c( "Fuel", "Sector", em ) ]

# Order By ISO2 & sector
   # inv_data_sheet_clean <- dplyr::mutate( inv_data_sheet_clean, Country = as.character( Country ) )
   # inv_data_sheet_clean <- inv_data_sheet_clean[ order( inv_data_sheet_clean$Fuel, inv_data_sheet_clean$Sector ), ]

# Mapping DICE countries to CEDS iso codes
    inv_data_sheet_clean$iso <- 'ind'
    inv_data_sheet_clean <- inv_data_sheet_clean[ , c( 'iso', 'Fuel', 'Sector', em)]
    #inv_data_sheet_clean$Country <- MCL[ match( inv_data_sheet_clean$Country, MCL$Country_Name ),'iso' ]
    names( inv_data_sheet_clean ) [ 2 ] <- "fuel"
    names( inv_data_sheet_clean ) [ 3 ] <- "sector"

#Rename columns
    year = paste0( 'X', inv_years )
    names( inv_data_sheet_clean ) [ 4 ] <- year
#    inv_data_sheet_clean <- inv_data_sheet_clean[ , c( 'iso', 'fuel', 'sector', 'year' ) ]

# Make numeric
    inv_data_sheet_clean[ , year ] <- sapply( inv_data_sheet_clean[ , year ], as.numeric )
    
#convert from ton to kt
    inv_data_sheet_clean[ , year ] <- inv_data_sheet_clean[ , year ] / 1e3


# ------------------------------------------------------------------------------
# 3. Write out standard form inventory
    writeData( inv_data_sheet_clean, domain = "MED_OUT",
              paste0( 'E.', em, '_', inv_name, '_inventory' ) )

    logStop()
# END

