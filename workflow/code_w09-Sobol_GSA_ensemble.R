##==============================================================================
##
## Script creates the ensemble and the parameter sets required for GSA
## with the pre-calibrated hazard parameters, discharge, vulnerability
## and exposure scalib factors
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
library("TruncatedDistributions")


# Set working directory
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)

load('./Outputs/RData/initial_parameter_set.RData')
load('./Outputs/RData/survived_rows_after_precalib.RData')
load('./Outputs/RData/Q_sample_A.RData')
load('./Outputs/RData/Q_sample_B.RData')

N=2000 # number of prior samples

#functions for ABi and ABij matrices
ABi<-function(i){
  matrix<-A
  matrix[,i]<-B[,i]
  return(matrix)
}

ABij<-function(i,j){
  matrix<-A
  matrix[,c(i,j)]<-B[,c(i,j)]
  return(matrix)
}
# function map between [0,1] and a bounded parameter range
map_range <- function(x, bdin, bdout) {
  bdout[1] + (bdout[2] - bdout[1]) * ((x - bdin[1]) / (bdin[2] - bdin[1]))
}

surviving_haz_params<-para[survived.rows,]
surviving_haz_params<-unique(surviving_haz_params[,-c(1,7,8)])

set.seed(7)
V <- rtbeta(2*N, alpha = 5, beta = 5, a=0, b=1)
V<-map_range(V,c(0,1),c(-0.4,+0.4))


set.seed(8)
X <- rtbeta(2*N, alpha = 5, beta = 5, a=0, b=1)
X<-map_range(X,c(0,1),c(-0.4,+0.4))

set.seed(30)
samp<-sample(1:nrow(surviving_haz_params),2*N)

#setting up matrix A and matrix B
A<-data.frame(Q=Q_samp_A,surviving_haz_params[samp[1:N],],V=V[1:N],X=X[1:N])
B<-data.frame(Q=Q_samp_B,surviving_haz_params[samp[(N+1):(2*N)],],V=V[(N+1):(2*N)],X=X[(N+1):(2*N)])

#setting up matrices ABi for first order indices
AB_1st<-rbind(
ABi(1),
ABi(2),
ABi(3),
ABi(4),
ABi(5),
ABi(6),
ABi(7),
ABi(8)
)

#setting up matrices ABij for second order indices
AB_2nd<-rbind(
ABij(1,2),
ABij(1,3),
ABij(1,4),
ABij(1,5),
ABij(1,6),
ABij(1,7),
ABij(1,8),
ABij(2,3),
ABij(2,4),
ABij(2,5),
ABij(2,6),
ABij(2,7),
ABij(2,8),
ABij(3,4),
ABij(3,5),
ABij(3,6),
ABij(3,7),
ABij(3,8),
ABij(4,5),
ABij(4,6),
ABij(4,7),
ABij(4,8),
ABij(5,6),
ABij(5,7),
ABij(5,8),
ABij(6,7),
ABij(6,8),
ABij(7,8)
)

precalibrated_param_set<-rbind(A,B,AB_1st,AB_2nd)
save(precalibrated_param_set,file='./Outputs/RData/precalibrated_param_set.RData')

# ensemble
mat<-precalibrated_param_set
mat[, "Q"]<-map_range(mat[, "Q"],range(mat[, "Q"]),c(0,1))
mat[, "Z"]<-map_range(mat[, "Z"],c(-5,5),c(0,1))
mat[, "W"]<-map_range(mat[, "W"],c(-0.1,0.1),c(0,1))
mat[, "n_ch"]<-map_range(mat[, "n_ch"],c(0.02,0.1),c(0,1))
mat[, "n_fp"]<-map_range(mat[, "n_fp"],c(0.02,0.2),c(0,1))

n10<-length(mat[, "DEM"][mat[, "DEM"]==10])
n30<-length(mat[, "DEM"][mat[, "DEM"]==30])
n50<-length(mat[, "DEM"][mat[, "DEM"]==50])
set.seed(6)
mat[, "DEM"][mat[, "DEM"]==10]<-runif(n10,min=0,max=1/3)
set.seed(6)
mat[, "DEM"][mat[, "DEM"]==30]<-runif(n30,min=1/3,max=2/3)
set.seed(6)
mat[, "DEM"][mat[, "DEM"]==50]<-runif(n50,min=2/3,max=3/3)

mat[, "V"]<-map_range(mat[, "V"],c(-0.4,0.4),c(0,1))
mat[, "X"]<-map_range(mat[, "X"],c(-0.4,0.4),c(0,1))

precalibrated_ensemble<-mat
save(precalibrated_ensemble,file = './Outputs/RData/precalibrated_ensemble.RData')

rm(list=setdiff(ls(), c("my_files","code")))
