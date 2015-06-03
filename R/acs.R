#' @importFrom acs geo.make acs.fetch geography
get_all_ca_tracts = function()
{
  ca.counties = acs.fetch(geography    = geo.make(state = 6, county = "*"), 
                          table.number = "B01003")
  
  geo.make(state  = "CA", 
           county = as.numeric(geography(ca.counties)[[3]]), 
           tract  = "*")
}

#' Returns a list representing American Community Survey (ACS) estimates
#'
#' Given an ACS tableId, endyear and span. Prompts user for the column id if there 
#' are multiple tables. The first element of the list is a data.frame with estimates. 
#' The second element is the ACS title of the column.
#' Requires the acs package to be installed, and a Census API Key to be set with the 
#' acs's api.key.install function.  Census API keys can be obtained at http://api.census.gov/data/key_signup.html.
#'
#' @param tableId The id of an ACS table
#' @param endyear The end year of the survey to use.  See acs.fetch (?acs.fetch) and http://1.usa.gov/1geFSSj for details.
#' @param span The span of time to use.  See acs.fetch and http://1.usa.gov/1geFSSj for details.
#' on the same longitude and latitude map to scale. This variable is only checked when the "states" variable is equal to all 50 states.
#' @param column_idx The optional column id of the table to use. If not specified and the table has multiple columns,
#' you will be prompted for a column id.
#' @export
#' @seealso http://factfinder2.census.gov/faces/help/jsf/pages/metadata.xhtml?lang=en&type=survey&id=survey.en.ACS_ACS, which lists all ACS Surveys.
#' @importFrom acs acs.fetch geography estimate geo.make
get_ca_tract_acs_data = function(tableId, endyear=2012, span=5, column_idx=-1)
{
  acs.data = acs.fetch(geography    = get_all_ca_tracts(), 
                       table.number = tableId,
                       col.names    = "pretty", 
                       endyear      = endyear, 
                       span         = span)

  if (column_idx == -1) {
    column_idx = get_column_idx(acs.data, tableId) # some tables have multiple columns 
  }
  title      = acs.data@acs.colnames[column_idx] 
  df         = convert_acs_obj_to_df(acs.data, column_idx) # choroplethr requires a df
  list(df=df, title=title) # need to return 2 values here
}
  
# support multiple column tables
get_column_idx = function(acs.data, tableId)
{
  column_idx = 1
  if (length(acs.data@acs.colnames) > 1)
  {
    num_cols   = length(acs.data@acs.colnames)
    title      = paste0("Table ", tableId, " has ", num_cols, " columns.  Please choose which column to render:")
    column_idx = menu(acs.data@acs.colnames, title=title)
  }
  column_idx
}

# the acs package returns data as a custom S4 object. But we need the data as a data.frame.
# with 1 column named "region". The map requires the region to be 11 character - 
# 5 for the county FIPS code and 6 for the tract
convert_acs_obj_to_df = function(acs.data, column_idx) 
{
  df = data.frame(state  = geography(acs.data)$state,   # integer
                  county = geography(acs.data)$county,  # integer
                  tract  = geography(acs.data)$tract,   # character
                  value  = as.numeric(estimate(acs.data[,column_idx])))
  
  # county fips code must be 5 chars
  # 2 chars for the state (i.e. leading "0")
  df$state = as.character(df$state)
  df$state = paste0("0", df$state)
  # 3 chars for the county - i.e. leading "0" or leading "00"
  df$county = as.character(df$county)
  for (i in 1:nrow(df))
  {
    if (nchar(df[i, "county"]) == 1) {
      df[i, "county"] = paste0("00", df[i, "county"])
    } else if (nchar(df[i, "county"]) == 2) {
      df[i, "county"] = paste0("0", df[i, "county"])
    }
  } 

  # now concat with the tract id
  df$region = paste0(df$state, df$county, df$tract)

  df[, c("region", "value")] # only return (region, value) pairs
}

#' Create a choropleth map of California Census Tracts from ACS data
#' 
#' Creates a choropleth of California Census Tracts the US Census' American Community Survey (ACS) data.  
#' Requires the acs package to be installed, and a Census API Key to be set with 
#' the acs's api.key.install function.  Census API keys can be obtained at http://www.census.gov/developers/tos/key_request.html.
#'
#' @param tableId The id of an ACS table
#' @param endyear The end year of the survey to use.  See acs.fetch (?acs.fetch) and http://1.usa.gov/1geFSSj for details.
#' @param span The span of time to use.  See acs.fetch and http://1.usa.gov/1geFSSj for details.
#' @param num_colors The number of colors on the map. A value of 1 
#' will use a continuous scale. A value in [2, 9] will use that many colors. 
#' @param tract_zoom An optional list of states to zoom in on. Must come from the "region" column in
#' ?ca.tract.regions.
#' @param county_zoom An optional list of counties to zoom in on. Must match entries of the county.fips.numeric column of 
#' ?ca.tract.regions.
#' @return A choropleth.
#' 
#' @keywords choropleth, acs
#' 
#' @seealso \code{api.key.install} in the acs package which sets an Census API key for the acs library
#' @seealso http://factfinder2.census.gov/faces/help/jsf/pages/metadata.xhtml?lang=en&type=survey&id=survey.en.ACS_ACS 
#' which contains a list of all ACS surveys.
#' @references Uses the acs package created by Ezra Haber Glenn.
#' @export
#' @importFrom acs acs.fetch geography estimate geo.make
#' @examples
#' \dontrun{
#' # per capita income, san francisco (fips code 6075)
#' ca_tract_choropleth_acs("B19301", county_zoom=6075)
#' }
ca_tract_choropleth_acs = function(tableId, endyear=2011, span=5, num_colors=7, tract_zoom=NULL, county_zoom=NULL)
{
  acs.data = get_ca_tract_acs_data(tableId, endyear, span)
  ca_tract_choropleth(acs.data[['df']], acs.data[['title']], "", num_colors, tract_zoom, county_zoom)
}