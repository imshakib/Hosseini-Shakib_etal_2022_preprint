##==============================================================================
##
## Script runs the flood hazard model for the precalibration of parameter sets
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
library("foreach")
library("doParallel")

# Set working directory
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)

# model setup and run

#parameter sets and functions
load('initial_parameter_set.RData')
source('./flood_extent_function.R')

# Read LISFLOOD-FP river and parameter files
sample_river <-
  as.matrix(read.delim2("./LISFLOOD/Sample_Selinsgrove.river", header = F)) # sample Susquehanna River file
sample_par <-
  as.matrix(read.delim2("./LISFLOOD/Sample_Selinsgrove.par", header = F)) # sample parameter file
# Output folders
if (dir.exists(paste0(wd, "/Initial_Outputs")) == F)
  dir.create(paste0(wd, "/Initial_Outputs"))
if (dir.exists(paste0(wd, "/Initial_Outputs/Extent")) == F)
  dir.create(paste0(wd, "/Initial_Outputs/Extent"))


run_start = 1 #starting row number of the parameters table to read
run_end = nrow(para) #ending row number of the parameters table to read


#setwd(paste0(wd,'/LISFLOOD'))
#system("./chmod a+x lisflood.exe") # activate the .exe file for the first time lisflood.exe is being executed

#setup parallel backend to use many processors
cores=detectCores()
cl <- makeCluster(cores[1]-1) # -1 not to overload system
registerDoParallel(cl)

start<-proc.time()

# the loop to parallel run the flood risk model for the parameter sets
# depending on the HPC capabilities, this loop might take several days or weeks to run
# it is recommended to run the loop in smaller groups and then merge the results as
# each run (row in the parameter sets matrix) is independent of other runs
foreach (i = run_start:run_end) %dopar% {
 print(i)
 flood_extent(i)
}

# for (i in run_start:run_end) haz_risk_run(i) # non-parallel runs
end<-proc.time()

print(end-start)
stopCluster(cl)

# model run end

rm(list = ls())
