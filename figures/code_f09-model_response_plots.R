##==============================================================================
##
## Script creates plots of the distributions of model response
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

load('./Outputs/RData/precalibrated_param_set.RData')
load('./Outputs/RData/model_response.RData')
#load('./Pregenerated_run_results/model_response.RData')
params<-c('Discharge (CMS)','River Bed Elevation Error (m)',
          'River Width Error','Channel Roughness',
          'Floodplain Roughness','DEM Resolution (m)',
          'Vulnerability Error','Exposure Error')

pdf('./Outputs/Figures/precalibrated_parameters_pdfs.pdf',width =11, height =8.5)

par(cex=0.2,mai=c(0.25,0.25,0.25,0.25),mfrow=c(3,3))

for(i in 1:8) hist(precalibrated_param_set[,i],main = params[i])

dev.off()

hazard<-model_response[,2]
haz_cdf_fun<-ecdf(hazard[order(hazard)])
risk<-model_response[,3]/1e6
risk_cdf_fun<-ecdf(risk[order(risk)])

#########################################################
### HAZARD PLOTS ###
#########################################################

pdf('./Outputs/Figures/hazard_response_pdfs.pdf',width =8.5, height =11)

par(mai=c(0.8,0.8,0.1,0.1),mfrow=c(4,1)) #c(bottom, left, top, right)
# boxplot
par(cex=0.5,fig=c(0,0.3*1.618,0.85,0.99)) #c(x1, x2, y1, y2)
boxplot(hazard,horizontal = T,frame.plot=F,xaxt="n")
mtext("(a)",side=3,adj=1,cex=1.2)

# histogram and PDF
par(cex=1,fig=c(0,0.3*1.618,0.6,0.9),new=T) #c(x1, x2, y1, y2)
hist(hazard,breaks=100,probability = T,ylim = c(0, max(density(hazard)$y)),
     xlim=c(-0.1,6),xaxt="n",xaxs="i",xlab = "", ylab = "", xaxt="n", yaxt="n",main=NA)
lines(density(hazard),lwd=2)
axis(side=1, at=axTicks(1), 
     labels=formatC(axTicks(1), format="d"),cex.axis=1.2)
axis(side=2, at=c(0,max(density(hazard)$y)), 
     labels=formatC(c(0,max(density(hazard)$y)), format="f",digits=1, big.mark=','),cex.axis=1.2)
# mtext("Average Flood Depth (m)",side=1,line=3,cex=1.2)
mtext("Density",side=2,line=2.5,cex=1.2)
mtext("(b)",side=3,adj=1,cex=1.2)

# CDF
# The base plot
par(cex=1,fig=c(0,0.3*1.618,0.3,0.6),new=T) #c(x1, x2, y1, y2)
plot(sort(hazard),haz_cdf_fun(sort(hazard)),type='l',frame.plot=F, 
     xlim=c(-0.1,6),xaxt="n",xaxs="i",xlab = "", ylab = "",xaxt="n", yaxt="n",ylim=c(0,1),lwd=2)
axis(side=1, at=axTicks(1), 
     labels=formatC(axTicks(1), format="d", big.mark=','),cex.axis=1.2)
axis(side=2, at=c(0,1), labels=c(0,1),cex.axis=1.2)
# mtext("Average Flood Depth (m)",side=1,line=3,cex=1.2)
mtext("Cumulative Density",side=2,line=2.5,cex=1.2)
mtext("(c)",side=3,adj=1,cex=1.2)
# survival
par(cex=1,fig=c(0,0.3*1.618,0,0.3),new=T) #c(x1, x2, y1, y2)
plot(sort(hazard),1-haz_cdf_fun(sort(hazard)),log='y',type='l',frame.plot=F, 
     xlim=c(-0.1,6),xaxt="n",xaxs="i",xlab = "", ylab = "",xaxt="n", yaxt="n",ylim=c(1e-5,1),lwd=2)
axis(side=1, at=axTicks(1), 
     labels=formatC(axTicks(1), format="d", big.mark=','),cex.axis=1.2)
axis(side=2, at=axTicks(2), 
     labels=formatC(axTicks(2), format="e", digits = 0),cex.axis=1.2)
mtext("Average Flood Depth (m)",side=1,line=3,cex=1.2)
mtext("Survival (1-CDF)",side=2,line=2.5,cex=1.2)
mtext("(d)",side=3,adj=1,cex=1.2)
dev.off()

#########################################################
### RISK PLOTS ###
#########################################################

pdf('./Outputs/Figures/risk_response_pdfs.pdf',width =8.5, height =11)

par(mai=c(0.8,0.8,0.1,0.1),mfrow=c(4,1)) #c(bottom, left, top, right)
# boxplot
par(cex=0.5,fig=c(0,0.3*1.618,0.85,0.99)) #c(x1, x2, y1, y2)
boxplot(risk,horizontal = T,frame.plot=F,xaxt="n")
mtext("(a)",side=3,adj=1,cex=1.2)
# histogram and PDF
par(cex=1,fig=c(0,0.3*1.618,0.6,0.9),new=T) #c(x1, x2, y1, y2)
hist(risk,breaks=100,probability = T,ylim = c(0, max(density(risk)$y)),
     xlim=c(-0.1,3.5),xaxt="n",xaxs="i",xlab = "", ylab = "", xaxt="n", yaxt="n",main=NA)
lines(density(risk),lwd=2)
axis(side=1, at=axTicks(1), 
     labels=formatC(axTicks(1), format="f", big.mark=',',digits=1),cex.axis=1.2)
axis(side=2, at=c(0,max(density(risk)$y)), 
     labels=formatC(c(0,max(density(risk)$y)), format="f",digits=1, big.mark=','),cex.axis=1.2)
# mtext("Total Damage (Million USD)",side=1,line=3,cex=1.2)
mtext("Density",side=2,line=2.5,cex=1.2)
mtext("(b)",side=3,adj=1,cex=1.2)
# CDF
# The base plot
par(cex=01,fig=c(0,0.3*1.618,0.3,0.6),new=T) #c(x1, x2, y1, y2)
plot(sort(risk),risk_cdf_fun(sort(risk)),type='l',frame.plot=F, 
     xlim=c(-0.1,3.5),xaxt="n",xaxs="i",xlab = "", ylab = "",xaxt="n", yaxt="n",ylim=c(0,1),lwd=2)
axis(side=1, at=axTicks(1), 
     labels=formatC(axTicks(1), format="f", big.mark=',',digits=1),cex.axis=1.2)
axis(side=2, at=c(0,1), labels=c(0,1),cex.axis=1.2)

# mtext("Total Damage (Million USD)",side=1,line=3,cex=1.2)
mtext("Cumulative Density",side=2,line=2.5,cex=1.2)
mtext("(c)",side=3,adj=1,cex=1.2)
# survival
par(cex=1,fig=c(0,0.3*1.618,0,0.3),new=T) #c(x1, x2, y1, y2)
plot(sort(risk),1-risk_cdf_fun(sort(risk)),log='y',type='l',frame.plot=F, 
     xlim=c(-0.1,3.5),xaxt="n",xaxs="i",xlab = "", ylab = "",xaxt="n", yaxt="n",ylim=c(1e-5,1),lwd=2)
axis(side=1, at=axTicks(1), 
     labels=formatC(axTicks(1), format="f", big.mark=',',digits=1),cex.axis=1.2)
axis(side=2, at=axTicks(2), 
     labels=formatC(axTicks(2), format="e", digits = 0),cex.axis=1.2)
mtext("Total Damage (Million USD)",side=1,line=3,cex=1.2)
mtext("Survival (1-CDF)",side=2,line=2.5,cex=1.2)
mtext("(d)",side=3,adj=1,cex=1.2)
dev.off()
rm(list=setdiff(ls(), c("my_files","code")))

