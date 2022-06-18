##==============================================================================
##
## Script creates a land use land cover grid and digital elevation models at different resolutions 
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
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)

# Read Selinsgrove's boundaries shapefile
clip_area <- readOGR("./Inputs/clip_area/clip_area.shp")

# Download and read the USGS 1/3 arcsec DEM for Selinsgrove
download.file(url='https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/TIFF/historical/n41w077/USGS_13_n41w077_20220429.tif',
              destfile = './Inputs/USGS_13_n41w077_20220429.tif',
              mode = 'wb')
dem <- raster('./Inputs/USGS_13_n41w077_20220429.tif')
crs <- crs(clip_area)
proj_clip_area<-spTransform(clip_area,crs(dem))
dem <- crop(dem, extent(proj_clip_area))

DEM10 <- projectRaster(dem, res = 10, crs = crs)
DEM10 <- round(DEM10, digits = 2)
DEM30 <- aggregate(DEM10, fact = 30 / 10, fun = mean)
DEM30 <- round(DEM30, digits = 2)
DEM50 <- aggregate(DEM10, fact = 50 / 10, fun = mean)
DEM50 <- round(DEM50, digits = 2)

# Clipped land use land cover map for Selinsgrove
LULC <- raster("./Inputs/NLCD/NLCD2016_clip")
LULC_proj <- projectRaster(LULC,
                           res = 30,
                           crs = crs,
                           method = "ngb")

writeRaster(DEM10,
            "./LISFLOOD/dem10.asc",
            format = "ascii",
            overwrite = T, prj=T)
writeRaster(DEM30,
            './LISFLOOD/dem30.asc',
            format = "ascii",
            overwrite = T, prj=T)
writeRaster(DEM50,
            './LISFLOOD/dem50.asc',
            format = "ascii",
            overwrite = T, prj=T)
writeRaster(LULC_proj,
            "./Inputs/lulc.asc",
            format = "ascii",
            overwrite = T, prj=T)

writeRaster(DEM10,
            "./Inputs/dem10.tif",
            format = "GTiff",
            overwrite = T, prj=T)
writeRaster(DEM30,
            "./Inputs/dem30.tif",
            format = "GTiff",
            overwrite = T, prj=T)
writeRaster(DEM50,
            "./Inputs/dem50.tif",
            format = "GTiff",
            overwrite = T, prj=T)
