##==============================================================================
##
## Script to perform precalibration on parameter sets of flood risk model using the
## image from the flood of Sep. 8, 2011 in Selinsgrove's Isle of Que accessible at:
## https://www.flickr.com/photos/42612148@N07/6137811926
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
library("dataRetrieval")
library("rgdal")
library("raster")
library("doParallel")
library("foreach")
# Global variables
wd<-getwd()
setwd(wd)

# load  Initial parameter sets
load('./Outputs/RData/initial_parameter_set.RData')

# create a folder for results
if (dir.exists(paste0(wd, "./Outputs/Initial_Outputs/Precalibration")) == F)
  dir.create(paste0(wd, "./Outputs/Initial_Outputs/Precalibration"))

# set a row number for parameter sets
para<-data.frame(row_no=1:nrow(para),para)

# download average daily discharge for the day of flooding at Sunbury
discharge<-readNWISdv(
  siteNumbers = "01554000",
  parameterCd = "00060",
  startDate = "2011-09-08",
  endDate = "2011-09-08")
discharge<-discharge[1,4]*0.3048^3 # convert to cms
error<-0.06 # based on USGS individual discharge measurement maximum error from:
# https://pubs.usgs.gov/of/1992/ofr92-144/#:~:text=The%20study%20indicates%20that%20standard,3%20percent%20to%206%20percent.

# Double check to see if all runs have discharge values within the range of error?
runs<-para[para[,'Q']>discharge*(1-error),]
runs<-runs[runs[,'Q']<discharge*(1+error),]
runs<-runs[,1]

# shapefile for the Isle of Que
Isle_of_Que<- readOGR("./Inputs/Isle_of_Que/Isle_of_Que.shp") # Isle of Que in Selinsgrove PA

# extract flood extent maps for the Isle of Que and take the average of flood depth
precalib_data<-data.frame()
for(i in 1:length(runs)){
    flood_extent<-raster(paste0(wd,'./Outputs/Initial_Outputs/Extent/run',runs[i],'.max'),format='ascii')
  flood_extent<-mask(flood_extent,Isle_of_Que)
  table<-as.data.frame(flood_extent, xy = F,na.rm=T)
  flood_depth<-mean(table[,1])
  precalib_data[i,1]<-runs[i]
  precalib_data[i,2]<-flood_depth
  print(i)
}
colnames(precalib_data)<-c("run_no.","flood_depth_(m)")
save(precalib_data,file = './Outputs/RData/precalib_data.RData')

# load('./Pregenerated_run_results/precalib_data.RData')

pdf("./Outputs/Figures/precalibration.pdf",width =8, height =8/1.618)

hist(precalib_data$`flood_depth_(m)`,breaks=50,xlim=c(0,10),
     main="",xlab="Flood depth (m)")
segments(x0=2,y0=0,x1=2,y1=500,col=2,lwd=3)
polygon(x=c(0.5,3.5,3.5,0.5),y=c(0,0,500,500),border=4,col=NULL,lwd=3)

legend(7,2000,
       c("Estimated depth\nfrom image","Realistic outputs"),
       lwd =3,
       col=c(2,4),
       pt.bg = c(NA,"white"),
       pch = c(NA,22),
       pt.cex = c(NA,2),
       lty = c(1,NA),
       bty = 'n',
       cex=1)
dev.off()

unrealistic_runs<-rbind(
  precalib_data[precalib_data$`flood_depth_(m)`<0.5,],
  precalib_data[precalib_data$`flood_depth_(m)`>3.5,])
unrealistic_runs<-unrealistic_runs[,1]

realistic_runs<-precalib_data[precalib_data$`flood_depth_(m)`>=0.5&
                                precalib_data$`flood_depth_(m)`<=3.5,]
realistic_runs<-realistic_runs[,1]

#These are the rows in the ensemble that have to be removed as a result of precalibration

del.rows<-sort(unique(unrealistic_runs))
save(del.rows,file = './Outputs/RData/deleted_rows_after_precalib.RData')

#These are the rows in the ensemble that have survived the precalibration

survived.rows<-sort(unique(realistic_runs))
save(survived.rows,file = './Outputs/RData/survived_rows_after_precalib.RData')

rm(list=setdiff(ls(), c("my_files","code")))
