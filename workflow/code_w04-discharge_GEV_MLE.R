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

# Download annual maximum instantaneous river flow data of the USGS gauge Susquehanna River at Sunbury
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
save(annu_max_Q,file = 'annual_maxima_cms.RData')

# fit<-fevd(annu_max_Q[,2],type = 'GEV', method = 'MLE')
# 
# # GEV location, shape, and scale parameters
# location<-fit$results$par[1]
# scale<-fit$results$par[2]
# shape<-fit$results$par[3]
# 
# # Print the results
# GEV_params=c(location,scale,shape)
# 
# # Save the parameters
# save(GEV_params,file="GEV_Parameters.RData")
# 
# #estimate PMF from 10,000 flood and the 500-yr flood
# #load('./GEV_Parameters.RData')
# PMF<-qevd(p=1-1e-4, loc = GEV_params[1], scale = GEV_params[2],
#              shape = GEV_params[3], type = c("GEV"))
# save(PMF,file="PMF.RData")
# Q500<-qevd(p=1-1/500, loc = GEV_params[1], scale = GEV_params[2],
#           shape = GEV_params[3], type = c("GEV"))
# save(Q500,file="Q500.RData")
# Q2000<-qevd(p=1-1/2000, loc = GEV_params[1], scale = GEV_params[2],
#            shape = GEV_params[3], type = c("GEV"))
# save(Q2000,file="Q2000.RData")
rm(list=ls())
