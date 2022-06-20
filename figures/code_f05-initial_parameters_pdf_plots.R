##==============================================================================
##
## Script creates plots the distributions of parameters and model response
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
# Set working directory
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)

load('./Outputs/RData/initial_parameter_set.RData')
params<-c('Discharge (CMS)','River Bed Elevation Error (m)',
          'River Width Error','Channel Roughness',
          'Floodplain Roughness','DEM Resolution (m)')

pdf('./Outputs/Figures/initial_parameters_pdfs.pdf',width =11, height =8.5)

par(cex=0.2,mai=c(0.25,0.25,0.25,0.25),mfrow=c(2,3))

for(i in 1:6) hist(para[,i],main = params[i],col='white')

dev.off()
rm(list=setdiff(ls(), c("my_files","code")))

