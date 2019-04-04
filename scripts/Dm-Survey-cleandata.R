## Load the survey data

# Read in survey, river, and road data 
# convert to utm
survey <- read_sf('data/raw/survey.geojson') %>% st_utm()
rivers <- read_sf('data/raw/rivers.geojson') %>% st_utm()
roads <- read_sf('data/raw/roads.geojson') %>% st_utm()

survey

# Create factors for character variables
# convert character sting to factors
survey$estpop_f <- factor(survey$estpop)
survey$sev_f <- factor(survey$severity)
survey$alt_f <- cut(survey$altitude, breaks = c(0, 500,1000, 2500),
                    labels = c("<500", "501 to 1000", "1000+"))


# Change the levels to correct order
survey$estpop_f <- fct_relevel(survey$estpop_f, "None", 
                               "Less than 100",
                               "Between 101 and 1,000",
                               "Between 1,001 and 5,000",
                               "More than 5,000") 
survey$sev_f <- fct_relevel(survey$sev_f, "No / Minor", 
                            "Of concern",
                            "Serious",
                            "Severe",
                            "Critical")

# Store a numeric variable for ordered categoricals
survey$estpop_n <- as.numeric(survey$estpop_f)
survey$sev_n <- as.numeric(survey$sev_f)

## Add coordinates
survey$x_utm <- st_coordinates(survey)[,1] 
survey$y_utm <- st_coordinates(survey)[,2]

# Calculate if within 2km of river or roads

within_2km_road <- st_is_within_distance(survey, roads,  dist = 2000)
within_2km_river <- st_is_within_distance(survey, rivers,  dist = 2000)

survey$within_2km_road <-  ifelse(apply(within_2km_road, 1, sum)>0, 1,0)
survey$within_2km_river <-  ifelse(apply(within_2km_river, 1, sum)>0, 1,0)
survey$within_2km_river_road <-  survey$within_2km_river+survey$within_2km_road
survey$within_2km_river_road_bin <-  (survey$within_2km_river_road >0)

saveRDS(survey, "data/survey.Rds")



