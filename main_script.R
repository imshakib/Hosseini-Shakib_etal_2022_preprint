##==============================================================================
##
## Script to run all other scripts
##
## Author: Iman Hosseini-Shakib (ishakib@gmail.com) 
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
## This rep is a package of multiple scripts indicated in the order they will be needed. For example, S1_....R indicates step 1.
## The entire package is controlled by main_script.R. This script contains a switch that gives you freedom to run the entire package locally on your machine or use the prepared data that was used in the paper. 
## To use the prepared data, set use_prepared_data=TRUE (this is the default option). To run the code yourself locally, set use_prepared_data=FALSE
## On a regular desktop computer, the entire program if (use_prepared_data=FALSE) should take around 10 hours.
## List of packages that you need to install before running the code is provided below. 
##
## To Run:
##      1. Set the working directory to the main folder (Hosseini-Shakib_etal_2022_Nat_Clim_Chang). 
##      2. set use_prepared_data
##      To do so:
##          1. If on RStudio, open the README.md file. Then on the menu bar, go to 
##              Session-->Set Working Directory-->To Source File Location
##          2. If on RStudio, on the lower right box, open "Hosseini-Shakib_etal_2022_Nat_Clim_Chang"
##              Then, click on More --> Set as Working Directory
##          3. On console, type the following command: 
##              setwd("~/.../../../../Hosseini-Shakib_etal_2022_Nat_Clim_Chang") 
##      3. Run (by clicking on Source in Rstudio)
## What happens next: 
##      R will go through all the scripts one by one   
##      After each script is done, there will be a message om screen reporting that script is done. 
##      The scripts will use the input data saved in the folder called "Inputs"
## Outputs:
##      1. Figures are saved in Figures directory under the main folder
##      2. Data are saved in the Outputs folder under the main directory
## Requirements before running
##      You will need R and the packages mentioned in "code_w00-packages.R" in the workflow folder

##==============================================================================
##==============================================================================
##==============================================================================

# Start the program here
rm(list=ls()) #Just in case, remove any variable that is already loaded 
graphics.off() #to make sure the user does not have an open figure

# Create the folders for storing output data and figures
tmp <- paste0(getwd(), "/Outputs/")
if(dir.exists(tmp)==F){dir.create(tmp, recursive=T)}

tmp <- paste0(getwd(), "/Outputs/Figures/")
if(dir.exists(tmp)==F){dir.create(tmp, recursive=T)}

tmp <- paste0(getwd(), "/Outputs/RData/")
if(dir.exists(tmp)==F){dir.create(tmp, recursive=T)}

# Start running the codes 
my_files<-list.files('./workflow/', pattern = "code_w")[-c(8,11,16)]
for (code  in my_files) {
  source(paste0('./workflow/',code))
  print(paste0("Finished running ",code))
}

my_files<-list.files('./figures/', pattern = "code_f")
for (code  in my_files) {
  source(paste0('./figures/',code))
  print(paste0("Finished running ",code))
}

rm(list=ls())
graphics.off()
