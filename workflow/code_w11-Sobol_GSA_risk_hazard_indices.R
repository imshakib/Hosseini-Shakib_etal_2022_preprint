##==============================================================================
##
## Script calculates Sobol indices for flood hazard response surface
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
library("sensobol")
library("ggplot2")

# Set working directory
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)

# calculation of sobol indices for risk
load('./precalibrated_ensemble.RData')
load('./model_response.RData')
#load('./Sobol_setup.RData')

#Set up required variables for Sobol indices
params<-c("Q","Z","W","n_ch","n_fp","DEM","V","X")
k=length(params)
N=2000
matrices<-c("A","B","AB")
order<-"second"
conf=0.95
type="norm"
R=1000

mat<-precalibrated_ensemble
y_risk=model_response[,3]


# plot_uncertainty(Y = y_risk, N = N) + labs(y = "Counts", x = "Total Damage (USD)")

pdf("scatter_plots_risk.pdf",width =11, height =8.5)
plot_scatter(data = mat, N = N, Y = y_risk, params = params)
dev.off()

# plot_multiscatter(data = mat, N = N, Y = y_risk, params = params)

ind <- sobol_indices(matrices = matrices, Y = y_risk, N = N, params = params, boot = T, R = R,
                     type = type, conf = conf,order = order,first = "saltelli",total = "janon")
cols <- colnames(ind$results)[1:5]

ind$results[, (cols):= round(.SD, 3), .SDcols = (cols)]
ind
write.csv(ind$results,"ind_totalDamage.csv")


ind.dummy <- sobol_dummy(Y = y_risk, N = N, params = params, boot = T,R=R)
write.csv(ind.dummy,'./dummy_risk.csv')
# plot(ind, dummy = ind.dummy,order = "first")
# plot(ind, dummy = ind.dummy,order = "second")

# sub.sample <- seq(100, N, 100) # Define sub-samples
# 
# convergence<-sobol_convergence(
#   matrices,
#   Y=y_risk,
#   N,
#   sub.sample,
#   params,
#   first="saltelli",
#   total = "jansen",
#   order = order,
#   seed = 666,
#   plot.order=order,
#   boot=T,
#   R=R
# )
# write.csv(convergence[1],"converge_totalDamage.csv")
# # convergence[2]
# # convergence[3]
# 
# pdf("converge_first_risk.pdf",width =11, height =8.5)
# convergence[2]
# dev.off()
# 
# pdf("converge_second_risk.pdf",width =11, height =8.5)
# convergence[3]
# dev.off()

######################################################
# calculation of sobol indices for hazard

y_haz=model_response[,2]
ind <- sobol_indices(Y = y_haz, N = N, params = params, boot = T, R = R,
                     type = type, conf = conf,order = order,first = "saltelli",total="janon")
cols <- colnames(ind$results)[1:5]

ind$results[, (cols):= round(.SD, 3), .SDcols = (cols)]
ind
write.csv(ind$results,"ind_totalHazard.csv")

ind.dummy <- sobol_dummy(Y = y_haz, N = N, params = params, boot = T,R=R)
ind.dummy
write.csv(ind.dummy,'./dummy_haz.csv')

# plot(ind, dummy = ind.dummy,order = "first")
# plot(ind, dummy = ind.dummy,order = "second")
