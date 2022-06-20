##==============================================================================
##
## Script creates hypothetical houses in Selinsgroves urban regions
##
## Authors: Iman Hosseini-Shakib (ishakib@gmail.com)
##          Klaus Keller (kzk10@psu.edu)
##
##==============================================================================
## Copyright 2022 Iman Hosseini-Shakib
## This file is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This file is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file.  If not, see <http://www.gnu.org/licenses/>.
##==============================================================================
## Instructions to run:
## 1. If you have not already done so, change the working directory to the main 
##    folder 
##    To do so:
##      1. If on RStudio, open the README.md file. Then on the menu bar, go to 
##         Session-->Set Working Directory-->To Source File Location
##      2. If on RStudio, on the lower right box, open the main folder
##         Then, click on More --> Set as Working Directory
##      3. On console, type the following command: 
##         setwd("~/../MAIN_FOLDER") 
## 2. To Run:
##      1. Click on Source button or, on console, type: Source("../../....R")
##==============================================================================
library(rgdal)
library(raster)

# Set working directory
wd <- getwd()
setwd(wd)

# Read land use grid and extract urban regions
LULC <- raster("./Inputs/lulc.asc")
roads <- readOGR("./Inputs/Roads/roads.shp") # Selinsgrove roads
rivers <- readOGR("./Inputs/Rivers/rivers.shp")
LULC_no_roads <- mask(LULC, roads, inverse = T)
LULC_no_roads_no_rivers <- mask(LULC_no_roads, rivers, inverse = T)
urban <- function(x) {
  ifelse (x == 22 | x == 23 | x == 24, 1, NA)
}
urban_region <- calc(LULC_no_roads_no_rivers, fun = urban)
selinsgrove <-
  readOGR("./Inputs/selinsgrove_shapefile/Selinsgrove.shp")
urban_extract = mask(urban_region, selinsgrove)

# Extract urban regions of DEM
dem <- raster("./LISFLOOD/dem10.asc")
shp <- rasterToPolygons(urban_region)
dem_urban <- mask(dem, shp)
dem_urban_selinsgrove <- mask(dem_urban, selinsgrove)
# Select 2000 hypothetical houses (grid cells) in the urban region
set.seed(1)
houses <- sampleRandom(dem_urban_selinsgrove, size = 2000, asRaster = TRUE)

writeRaster(houses,
            "./Inputs/houses.asc",
            format = "ascii",
            overwrite = TRUE)
writeRaster(
  dem_urban_selinsgrove,
  "./Inputs/dem_urban.asc",
  format = "ascii",
  overwrite = TRUE
)
rm(list=setdiff(ls(), c("my_files","code")))