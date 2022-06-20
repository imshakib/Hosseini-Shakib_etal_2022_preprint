##==============================================================================
##
## Script downloads USGS annual maxima of discharge for Susquehanna River at
## Sunbury and converts the units from cfs to cms
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

library(dataRetrieval)
library(extRemes)

# Set working directory
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)

# Download annual maximum instantaneous river flow data of the USGS gauge of Susquehanna River at Sunbury
annu_max_Q <- readNWISpeak(
  "01554000",
  startDate = "",
  endDate = "",
  asDateTime = TRUE,
  convertType = TRUE
)
annu_max_Q<-data.frame(annu_max_Q$peak_dt,annu_max_Q$peak_va)[-(1:3),]
colnames(annu_max_Q)<-c("dates","peak_va")
annu_max_Q$peak_va<-annu_max_Q$peak_va*0.3048^3 #cfs to cms
save(annu_max_Q,file = './Outputs/RData/annual_maxima_cms.RData')

rm(list=setdiff(ls(), c("my_files","code")))