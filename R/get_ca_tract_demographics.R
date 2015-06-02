#' @export
get_ca_tract_demographics = function(endyear=2013, span=5)
{  
  all.ca.tracts = get_all_ca_tracts()
  race.data = acs::acs.fetch(geography    = all.ca.tracts, 
                             table.number = "B03002", 
                             col.names    = "pretty", 
                             endyear      = endyear, 
                             span         = span)
  
  # dummy to get proper regions
  dummy.df = convert_acs_obj_to_df(race.data, 1)
  
  # convert to a data.frame 
  df_race = data.frame(region                   = dummy.df$region,  
                       total_population         = as.numeric(acs::estimate(race.data[,1])),
                       white_alone_not_hispanic = as.numeric(acs::estimate(race.data[,3])),
                       black_alone_not_hispanic = as.numeric(acs::estimate(race.data[,4])),
                       asian_alone_not_hispanic = as.numeric(acs::estimate(race.data[,6])),
                       hispanic_all_races       = as.numeric(acs::estimate(race.data[,12])))
  
  df_race$region = as.character(df_race$region) # no idea why, but it's a factor before this line
  
  df_race$percent_white    = round(df_race$white_alone_not_hispanic / df_race$total_population * 100)
  df_race$percent_black    = round(df_race$black_alone_not_hispanic / df_race$total_population * 100)
  df_race$percent_asian    = round(df_race$asian_alone_not_hispanic / df_race$total_population * 100)
  df_race$percent_hispanic = round(df_race$hispanic_all_races       / df_race$total_population * 100)
  
  df_race = df_race[, c("region", "total_population", "percent_white", "percent_black", "percent_asian", "percent_hispanic")]
  
  # per capita income 
  df_income = get_ca_tract_acs_data("B19301", endyear=endyear, span=span)[[1]]   
  colnames(df_income)[[2]] = "per_capita_income"
  
  # median rent
  df_rent = get_ca_tract_acs_data("B25058", endyear=endyear, span=span)[[1]]  
  colnames(df_rent)[[2]] = "median_rent"
  
  # median age
  df_age = get_ca_tract_acs_data("B01002", endyear=endyear, span=span, column_idx=1)[[1]]  
  colnames(df_age)[[2]] = "median_age"
  
  df_demographics = merge(df_race        , df_income, all.x=TRUE)
  df_demographics = merge(df_demographics, df_rent  , all.x=TRUE)  
  df_demographics = merge(df_demographics, df_age   , all.x=TRUE)
    
  df_demographics
}