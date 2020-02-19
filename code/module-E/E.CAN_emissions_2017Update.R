#------------------------------------------------------------------------------
# Program Name: E.CAN_emissions_2017Update.R
# Authors' Names: Erin McDuffie, adapted from original by Tyler Pitkanen, Jon Seibert, Rachel Hoesly, Steve Smith, Huong Nguyen
# Date Last Modified: August 13, 2019
# Program Purpose: To read in & reformat Canada emissions inventory data.
#                  This data only extends back to 1990, so older data is still used back
#                  to 1985 in a separate scaling operation. This newer data
#                  should be used last so that any discrepancies are resolved in
#                  favor of the newer data.
# Input Files: EN_APEI-Canada.xlsx
# Output Files: E.[em]_CAN_inventory.csv
# Notes:
# TODO: Re-write read-in so that order of years is taken from input data instead of assumed.
# ------------------------------------------------------------------------------
# 0. Read in global settings and headers
# Define PARAM_DIR as the location of the CEDS "parameters" directory, relative
# to the "input" directory.
    PARAM_DIR <- if("input" %in% dir()) "code/parameters/" else "../code/parameters/"

# Get emission species first so can name log appropriately
    args_from_makefile <- commandArgs( TRUE )
    em <- args_from_makefile[ 1 ]
    if ( is.na( em ) ) em <- "NOx"
    em.read <- em
    if( em == "SO2" ) em.read <- "SOx"
    if( em == "NMVOC" ) em.read <- "VOC"

# Call standard script header function to read in universal header files -
# provide logging, file support, and system functions - and start the script log.
    headers <- c( 'common_data.R', "data_functions.R",
                  "emissions_scaling_functions.R", "analysis_functions.R",
                  "interpolation_extension_functions.R" ) # Additional function files required.
    log_msg <- "Initial reformatting of Canada emissions (newer data)" # First message to be printed to the log
    script_name <- "E.CAN_emissions_2017Update.R"

    source( paste0( PARAM_DIR, "header.R" ) )
    initialize( script_name, log_msg, headers )

# ------------------------------------------------------------------------------
# 1. Define parameters for inventory specific script
    inventory_data_file <- 'EN_APEI-Canada'
    subfolder_name <- 'Canada/'
    inv_data_folder <- "EM_INV"
    inv_name <- 'CAN' # For naming diagnostic files
    inv_years <- c( 1990:2017 )
# Because this data comes read in as reversed.
    inv_years_reversed <- c( 2017:1990 )

# ------------------------------------------------------------------------------
# 2. Inventory in Standard Form (iso-sector-fuel-years, iso-sector-years, etc)

    if ( em %!in% c( 'SO2', 'NOx', 'NMVOC', 'CO', 'NH3' ) ) {
        # Output a blank df for unsupported species
        inv_data_clean <- data.frame( )

    } else {
    file_path <- filePath( inv_data_folder, inventory_data_file,
                           extension = ".xlsx",
                           domain_extension = subfolder_name )

# Process given emission if inventory data exists
    if ( file.exists( file_path ) ) {
        inv_data = data.frame()
    # Import each year (new sheet) and add to data frame
        for ( i in seq_along( inv_years ) ) {
        sheet_name <- toString( inv_years[ i ] )
        inv_data_sheet <- readData( inv_data_folder,
                                    domain_extension = subfolder_name,
                                    inventory_data_file , ".xlsx",
                                    sheet_selection = sheet_name, skip = 3 )
        col_names <- names(inv_data_sheet)
        inv_singleyear <- inv_data_sheet
        #select sector and specie columns
        inv_singleyear<- inv_singleyear[,c(1, grep(em.read, col_names, ignore.case = TRUE))]
        names( inv_singleyear ) <- c( 'sector', sheet_name)
        #rename columns and add to new year data to total inventory data frame
        if ( i == 1 ) {
            inv_data <- data.frame(inv_singleyear$sector)
            names( inv_data ) <- 'sector'
        }
        inv_data$year <- inv_singleyear[,c(2)]
        names( inv_data )[i+1] <- paste0( 'X', sheet_name )
        }

    # Clean rows and columns to standard format
    # Rename cols; add iso cols
        inv_data_clean <- inv_data
        inv_data_clean$iso <- 'can'
        years <- paste( "X", inv_years, sep="" )
        inv_data_clean <- inv_data_clean[ , c( 'iso', 'sector', years ) ]

    # Remove rows with all NAs
        remove.na <- which( apply( inv_data_clean[ , years ],
                                   1, function( x ) all.na( x ) ) )
        inv_data_clean <- inv_data_clean[ -remove.na, ]

    # Make numeric
        #replace empty cells
        inv_data_clean[ years ] <- apply( X = inv_data_clean[ years ], MARGIN = 2,
                                    FUN = gsub, pattern = '-' , replacement = "" )
        inv_data_clean[ , years ] <- sapply( inv_data_clean[ , years ], as.numeric )
    # Convert from tonnes to kt
        inv_data_clean[ , years ] <- as.matrix( inv_data_clean[ , years ] ) / 1000

    # Write out blank df if no inventory data exists for given emission
    } else {
        inv_data_clean <- data.frame()
    }

    }
# ------------------------------------------------------------------------------
# 3. Write standard form inventory

    writeData( inv_data_clean, domain = "MED_OUT",
               paste0( 'E.', em, '_', inv_name, '_inventory' ) )

# Every script should finish with this line
    logStop()
# END
