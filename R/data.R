#' Map of US Census Tracts in California
#' 
#' The map comes from the 2010 Cartographic Boundary Shapefiles - Census Tracts 
#' from the US Census Bureau website.
#' A column named "region" was added which is a duplicate of the column TRACTCE.
#' A column named "county.fips.numeric" was added which is the numeric version
#' of the county FIPS code of the tract.
#'  
#' @seealso ?ca.census.tract.regions
#' @docType data
#' @name ca.census.tract.map
#' @usage data(ca.census.tract.map)
#' @references Taken from https://www.census.gov/geo/maps-data/data/cbf/cbf_tracts.html.
NULL

#' Metadata about US Census Tracts map
#' 
#' The metadata is the tract id and the numeric county fips code.
#' 
#' @seealso ?ca.census.tract.regions
#'  
#' @docType data
#' @name ca.census.tract.regions
#' @usage data(ca.census.tract.regions)
NULL