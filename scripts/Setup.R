# Setup

# Packages used in analysis

library(sf)
library(dplyr)
library(forcats)
library(ggplot2)
library(mapview)

# User defined functions
## Define reprojection function for Zimbabawe UTM
st_utm <- function(d) st_transform(d, crs = 32736)
st_wgs84 <- function(d) st_transform(d, crs = 4326)

