##==============================================================================
##
## Script rearranges the sensitivity results table for the radial plot
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

#a=read.table("./Sobol-2_mostlikely_scenario.txt",header = T)
#Setting up radial plot tables for first and total order indices
col_names<-c("Parameter", "S1", "S1_conf_low", "S1_conf_high", "ST", "ST_conf_low", "ST_conf_high")
df=NULL
table<-read.csv('./ind_totalDamage.csv')
params <- c("Q", "Z", "W", "n_ch", "n_fp", "DEM","V","X") # name of parameters

S1<-table[table$sensitivity == "Si",]
ST<-table[table$sensitivity == "Ti",]

df<-data.frame(S1$parameters,S1$original,S1$low.ci,S1$high.ci,ST$original,ST$low.ci,ST$high.ci)
colnames(df)<-col_names
write.csv(df,'radial_plot_table_1_risk.csv')

#Setting up radial plot tables for second order indices
col_names<-c("Parameter_1", "Parameter_2",  "S2", "S2_conf_low",  "S2_conf_high")
S2<-table[table$sensitivity == "Sij",]
parameters= t(as.data.frame(strsplit(S2$parameters, split=".",fixed=T)))
df=data.frame(parameters,S2$original,S2$low.ci,S2$high.ci)
rownames(df)<-1:nrow(df)
colnames(df)<-col_names
write.csv(df,'radial_plot_table_2_risk.csv')






