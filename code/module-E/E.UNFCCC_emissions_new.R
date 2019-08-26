# ------------------------------------------------------------------------------
# Program Name: E.UNFCCC_emissions_new.R
# Author(s): Erin McDuffie, based on code from Patrick O'Rourke, Rachel Hoesly, Jon Seibert, Presley Muwan
# Date Last Updated: August 12, 2019
# Program Purpose: To read in and reformat UNFCCC emissions data.
# Input Files: All UNFCCC Emissions Data
# Output Files: E.[EM]_UNFCCC_inventory.csv
#               E.[EM]__UNFCCC_inventory.cvs
#               E.[EM]_UNFCCC_filename_Sector_mapping.cvs
# Notes: UNFCCC  Emissions are provided from 1990-2017.
# TODO:
# ------------------------------------------------------------------------------
# 0. Read in global settings and headers
# Define PARAM_DIR as the location of the CEDS "parameters" directory, relative
# to the "input" directory.
PARAM_DIR <- if("input" %in% dir()) "code/parameters/" else "../code/parameters/"

# Call standard script header function to read in universal header files -
# provides logging, file support, and system functions - and start the script log.
headers <- c( "data_functions.R", "analysis_functions.R" ) # Any additional function files required
log_msg <- "Initial reformatting of the UNFCCC emissions inventories" # First message to be printed to the log
script_name <- "E.UNFCCC_emissions_new.R"

source( paste0( PARAM_DIR, "header.R" ) )
initialize( script_name, log_msg, headers )

args_from_makefile <- commandArgs( TRUE )
em <- args_from_makefile[ 1 ]
if ( is.na( em ) ) em <- "NOx"

# -----------------------------------------------------------------------------------------------------------
# 0.5 Settings

loadPackage( 'tools' )
MCL <- readData( "MAPPINGS", "Master_Country_List" )

#UNFCCC Inventory years
UNFCCC_years= 1990:2017

# Create a List of UNFCCC Files
domain <- "EM_INV"
domain_ext <- "UNFCCC/"
file_name <- paste0( 'UNFCCC_' , em )
extension <- ".csv"

file_path <- filePath( domain, file_name, extension, domain_ext )

inv_file_name <- paste0( 'UNFCCC_', em, ".csv" )
#file_path <- filePath( 'EM_INV', inv_file_name, "", "UNFCCC/" )

# -----------------------------------------------------------------------------------------------------------
# 1. Read in files

  if ( file.exists( file_path ) ) {
  
    # Function used to read in list of txt files
    UNFCCC <- readData( domain, file_name, extension, 
                      domain_extension = domain_ext,
                      extract_all = TRUE, header = FALSE )
  
    inv <- read.table( paste0( './emissions-inventories/UNFCCC/',
                             inv_file_name ),
                     skip = 3, header = TRUE, sep = ",",
                     na.strings = c( "", " ", "NA" ) ) # Converts all blank spaces to 'NA'
  }


# -----------------------------------------------------------------------------------------------------------
# 2. Formatting Data

  if ( length( UNFCCC ) > 0 ) { 
    # If there is data to process for this emissions species...
  
    UNFCCC_clean <- UNFCCC
  
    # Iterate through each dataframe (sheet) in the list
    # for ( i in seq_along( UNFCCC_clean ) ) {
    df <- UNFCCC_clean
    
    # Removes First three rows and third column
    df <- df[ -c(1:3), ]
    df <- df[ , -3 ]
    
    # Reformat Col Names
    names <- as.character( unlist ( df[ 1, ] ) )
    names[ length( names ) ] <- paste0( '', UNFCCC_years[length(UNFCCC_years)]) #make sure last year is formatted correctly
    years<-paste( "X", names[ 3:( length( names ) ) ], sep = "" )
    names[ 3:( length( names ) ) ] <- years
    names[ 1 ] <- 'country'
    names[ 2 ] <- 'sector'
    names( df ) <- names
    
    # Remove First 2 rows
    df <- df[ -c(1:2), ]
    
    # Creates Column for Units (Gg for SO2)
    df$units <- "kt"
    # Reorder Columns of Interest
    df <- df[ , c( 'country', 'sector', 'units', years ) ]
    
    # Remove All Information from Sectors Before "_" From File Name
    df <- dplyr::mutate( df, sector = as.character( sector ) )
    #df <- dplyr::mutate( df, sector = sapply( strsplit( df$sector, split = '_',
    #                                                    fixed = TRUE ),
    #                                          function( x ) ( x [ 2 ] ) ) )
    
    UNFCCC_clean <- df
  
    UNFCCCdf <- UNFCCC_clean
    # Convert Values to Numeric: Remove Commas in Formatting, then Convert to Numeric
    # NOTE: missing/unreported data codes all set to NA
    UNFCCCdf[ years ] <- apply( X = UNFCCCdf[ years ], MARGIN = 2,
                              FUN = gsub, pattern = ',' , replacement = "" )
    UNFCCCdf[ years ] <- apply( X = UNFCCCdf[ years ], MARGIN = 2,
                                FUN = gsub, pattern = 'NO|NE|IE|NA|C' , replacement = "" )
    UNFCCCdf[ years ] <- as.numeric( as.matrix( UNFCCCdf [ years ] ) )
  
    # Mapping Country Names to ISO Codes
    UNFCCCdf$iso <- MCL[ match( UNFCCCdf$country, MCL$UNFCCC ), 'iso' ]
  
    # Remove Unmapped Lines and Reorder
    UNFCCCdf <- UNFCCCdf[ complete.cases( UNFCCCdf$iso ), ]
  
    UNFCCCdf <- UNFCCCdf[ , c( 'iso', 'sector', 'units', years ) ]
    UNFCCCdf <- UNFCCCdf[ order( UNFCCCdf$iso, UNFCCCdf$sector ), ]
    
# ------------------------------------------------------------------------------
# 3. Removed "Bad" Data
    
    # Remove Canada, Russian Fed, Luxembourg, and Poland
    
    if (em == 'CH4'){
      
      # TODO: The df maniupulation after this block fails if only 'rus' is
      #       in the list below since rus is not in the current data. (this may be outdated)
      #       add 'ussr' since it was mapped incorrectly due to master_country_list
      # TODO: Fix to be more robust
      
      remove_iso <- c('rus', 'lux', 'ussr')
      
    } else {
      
      # Remove Canada, Russian Fed, Luxembourg, and Poland for other emission
      # species
      
      remove_iso <- c( 'can', 'rus', 'pol', 'lux', 'ussr' )
    }
    
    UNFCCC <- UNFCCCdf[ -which( UNFCCCdf$iso %in% remove_iso ), ]
    
    # Drop Lines With Only NA Values
    drop <- which( apply( X = is.na( UNFCCC[ years ] ), MARGIN = 1, FUN = all ) == TRUE )
    UNFCCC <- UNFCCC[ -drop, ]
    
# ------------------------------------------------------------------------------
# 4. Dummy files
    
  } else {
    # If length( UNFCCC) == 0 (if no data to process for this emissions species), create dummy file.
    UNFCCC <- data.frame()
  }

# ------------------------------------------------------------------------------
# 5. Meta Data

meta_names <- c( "Data.Type", "Emission", "Region", "Sector", 
                 "Start.Year", "End.Year", "Source.Comment" )

meta_note <- c( "Default Emissions", "NA", 
                "Russian Federation, Monaco, Liechtenstein, Luxembourg, Poland, and Canada ", "All", "1990",
                "2017", paste0( "The Russian Federation's emissions are too",
                                "low to be accurate, and have thus been",
                                "removed. Additionally Liechtenstein and",
                                "Monaco emissions have been removed",
                                "temporarily. Luxembourg, Poland, and Canada were",
                                "deemed 'bad' but need to be re-evaluated for new",
                                "(2017) UNFCCC data set" ) )

addMetaData( meta_note, meta_names )

# ------------------------------------------------------------------------------
# 6. Output

writeData( UNFCCC, domain = "MED_OUT", 
           fn = paste0( "E.", em, "_UNFCCC_inventory" ), meta = TRUE )

# Every script should finish with this line
logStop()

# END
