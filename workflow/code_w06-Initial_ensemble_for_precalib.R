##==============================================================================
##
## Script creates the ensemble and the parameter sets required for precalibration
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
#install.packages("TruncatedDistributions", repos="http://R-Forge.R-project.org")

library("TruncatedDistributions")

# Set working directory
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)

params <- c("Q", "Z", "W", "n_ch", "n_fp", "DEM") # name of parameters
N<-1e4 # number of samples
k <- length(params) # number of parameters


# loading samples of discharge data from MCMC posterior
load('Q_for_precalib.RData')
Q<-Q_for_precalib

# function map between [0,1] and a bounded parameter range
map_range <- function(x, bdin, bdout) {
  bdout[1] + (bdout[2] - bdout[1]) * ((x - bdin[1]) / (bdin[2] - bdin[1]))
}

para<-matrix(NA,N,k)
colnames(para)<-params
# ensemble
set.seed(1)
para[, "Q"]<-sample(Q_for_precalib,N,replace = T)

set.seed(2)
para[, "Z"] <- rtbeta(N, alpha=5, beta=5, a=0, b=1)
para[,'Z']<-map_range(para[,'Z'],c(0,1),c(-5,+5))

set.seed(3)
para[, "W"] <- rtbeta(N, alpha = 5, beta = 5, a=0, b=1)
para[,'W']<-map_range(para[,'W'],c(0,1),c(-0.1,+0.1))

set.seed(4)
para[, "n_ch"] <- rtnorm(N, mean=(0.03-0.02)/(0.1-0.02), sd=0.5,a=0, b=1)
para[,'n_ch']<-map_range(para[,'n_ch'],c(0,1),c(0.02,0.1))

set.seed(5)
para[, "n_fp"] <- rtnorm(N, mean=(0.12-0.02)/(0.2-0.02), sd=0.5,a=0, b=1)
para[,'n_fp']<-map_range(para[,'n_fp'],c(0,1),c(0.02,0.2))

set.seed(6)
para[, "DEM"] <- runif(N, min=0, max=1)
10->para[, "DEM"][para[, "DEM"]<1/3]
30->para[, "DEM"][para[, "DEM"]<2/3]
50->para[, "DEM"][para[, "DEM"]<3/3]

#check for unique parameter sets
nrow(unique(para))==N
# [1] TRUE

save(para,file = './initial_parameter_set.RData')
rm(list = ls())
