#' An R6 object for creating choropleths of California Census Tracts.
#' @export
#' @importFrom dplyr left_join
#' @importFrom R6 R6Class
#' @importFrom choroplethr Choropleth
CaTractChoropleth = R6Class("CaTractChoropleth",
  inherit = choroplethr::Choropleth,
  public = list(
    
    # initialize with a map of California Census Tracts
    initialize = function(user.df)
    {
      data(ca.tract.map, package="choroplethrCaCensusTract", envir=environment())
      super$initialize(ca.tract.map, user.df)
      
      if (private$has_invalid_regions)
      {
        warning("Please see ?ca.tract.regions for a list of mappable regions")
      }
    },
    
    # All zooms, at the end of the day, are zip zooms. But often times it is more natural
    # for users to specify the zoom in other geographical units
    # This function name is a bit of a hack - it seems like I cannot override the parent set_zoom directly
    # because this function has a different number of parameters than that function, and the extra parameters
    # seeming just disappear
    set_zoom_tract = function(county_zoom, tract_zoom)
    {
      # user can zoom by at most one of these options
      num_zooms_selected = sum(!is.null(c(county_zoom, tract_zoom)))
      if (num_zooms_selected > 1) {
        stop("You can only zoom in by one of county_zoom or tract_zoom")
      }
      
      data(ca.tract.regions, package="choroplethrCaCensusTract", envir=environment())
      
      # if the zip_zoom field is selected, just do default behavior
      if (!is.null(tract_zoom)) {
        super$set_zoom(tract_zoom)
      # if county_zoom field is selected, extract zips from counties  
      } else if (!is.null(county_zoom)) {
        stopifnot(all(county_zoom %in% unique(ca.tract.regions$county.fips.numeric)))
        tracts = ca.tract.regions[ca.tract.regions$county.fips.numeric %in% county_zoom, "region"]
        super$set_zoom(tracts)        
      }
    }
    
  )
)

#' Create a choropleth of US Census Tracts in California
#' 
#' @param df A data.frame with a column named "region" and a column named "value".  Elements in 
#' the "region" column must exactly match how census tracts are labelled in in the "region" column in ?ca.tract.regions
#' @param title An optional title for the map.  
#' @param legend An optional name for the legend.  
#' @param num_colors The number of colors on the map. A value of 1 
#' will use a continuous scale. A value in [2, 9] will use that many colors. 
#' @param tract_zoom An optional vector of tracts to zoom in on. Elements of this vector must exactly 
#' match the names of tracts as they appear in the "region" column of ?ca.tract.regions.
#' @param county_zoom An optional vector of county FIPS codes to zoom in on. Elements of this 
#' vector must exactly match the names of counties as they appear in the "county.fips.numeric" column 
#' of ?ca.tract.regions.
#'
#' @seealso \url{https://www.census.gov/geo/reference/gtc/gtc_ct.html} for more information on Census Tracts
#' @export
#' @importFrom Hmisc cut2
#' @importFrom stringr str_extract_all
#' @importFrom ggplot2 ggplot aes geom_polygon scale_fill_brewer ggtitle theme theme_grey element_blank geom_text
#' @importFrom ggplot2 scale_fill_continuous scale_colour_brewer  
#' @importFrom scales comma
ca_tract_choropleth = function(df, title="", legend="", num_colors=7, tract_zoom=NULL, county_zoom=NULL)
{
  c = CaTractChoropleth$new(df)
  c$title  = title
  c$legend = legend
  c$set_zoom_tract(tract_zoom=tract_zoom, county_zoom=county_zoom)
  c$set_num_colors(num_colors)
  c$render()
}