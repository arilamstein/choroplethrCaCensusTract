#' Map of US Census Tracts in California
#' 
#' The map comes from the 2010 Cartographic Boundary Shapefiles - Census Tracts 
#' from the US Census Bureau website.
#' A column named "region" was added which is a duplicate of the column GEOID. 
#' The GEOID is the concatenation of the 5-character county FIPS code and the 
#' 6-character TRACTCE column.
#' A column named "county.fips.numeric" was added which is the numeric version
#' of the county FIPS code of the tract.
#'  
#' @seealso ?ca.tract.regions
#' @docType data
#' @name ca.tract.map
#' @usage data(ca.tract.map)
#' @references Taken from https://www.census.gov/geo/maps-data/data/cbf/cbf_tracts.html.
NULL

#' Metadata about the California Census Tracts map
#' 
#' In addition to the region/GEOID it contains the TRACTCE and county FIPS code
#' as both an integer and character (i.e. with and without the leading "0")
#' 
#' @seealso ?ca.tract.map
#'  
#' @docType data
#' @name ca.tract.regions
#' @usage data(ca.tract.regions)
NULL