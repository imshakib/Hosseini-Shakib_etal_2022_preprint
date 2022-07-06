##==============================================================================
##
## Script to plot return periods of upstream discharge uncertainty and the 
## histogram of the 500-yr return period flood
##
## Authors: Iman Hosseini-Shakib (ishakib@gmail.com)
##          Klaus Keller (kzk10@psu.edu)
##
##  Modified from a code by Mahkameh Zarekarizi available at:
## https://github.com/scrim-network/Zarekarizi-flood-home-elavate/blob/master/Source_Code/S11_Return_Level.R
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

myblue <- rgb(0.68, 0.85, 0.90,0.5)
if("fExtremes" %in% (.packages())){
  detach("package:fExtremes", unload=TRUE)
}
if("evd" %in% (.packages())){
  detach("package:evd", unload=TRUE)
}
library('DEoptim')
library(evir)
#--------------------------------------------------------------
# Functions----------------------------------------------------

## function to estimate the return level from GEV distribution
myreturnlevel <- function(t,mu,sigma,xi){
  x<-qgev(p=1-(1/t),xi=xi,mu=mu,sigma=sigma)
  return(x)
}

# define empirical probability searching function
median.auxiliary.func <- function(p, e, n){
  out <- abs((1-pbinom(e-1, n, p))-0.5)
  return(out)
}

# Numerical median probability return period formula
median.rt <- function(obs){
  l <- length(obs)
  # define variables
  e <- 1:l # the ranks of the events
  n <- l # sample size for the events
  pb <- txtProgressBar(min = 0, max = l, initial = 0, char = '=', style = 1) # loading bar
  prob <- vector(mode = 'numeric', length = l)
  for (i in 1:l) {
    setTxtProgressBar(pb, i) # loading bar
    fit <- DEoptim(median.auxiliary.func, lower = 0, upper = 1, e = e[i], n = n, control = DEoptim.control(trace = FALSE))
    prob[i] <- fit$optim$bestmem
  }
  close(pb)
  out <- sort(1/prob, decreasing = FALSE)
  return(out)
}

#---------------------------------------------------------------------
# Load libraries and data required to run this code
load("./Outputs/RData/annual_maxima_cms.RData") # Annual maxima of discharge in cms
load("./Outputs/RData/GEV_Parameters.RData") # Frequentist maximum likelihood GEV parameter set
load("./Outputs/RData/GEV_Parameters_MCMC.RData") # MCMC parameter sets
# load("./Pregenerated_outputs/RData/annual_maxima_cms.RData") # Annual maxima of discharge in cms
# load("./Pregenerated_outputs/RData/GEV_Parameters.RData") # Frequentist maximum likelihood GEV parameter set
# load("./Pregenerated_outputs/RData/GEV_Parameters_MCMC.RData") # MCMC parameter sets

library(evir)
plot_rps <- c(seq(1,2,0.1),seq(3,9,1),seq(10,90,10),seq(100,500,100))

# Find return levels for each parameter set
MC_rl <- sapply(1:nrow(mcmcSamples), function(x) {
  myreturnlevel(plot_rps, mu=mcmcSamples[x,1], sigma=mcmcSamples[x,2], xi=mcmcSamples[x,3])
})
rownames(MC_rl)<-plot_rps

# Find upper and lower limits for 90% CI bounds
lower_5 <- sapply(1:length(plot_rps), function (x){quantile(MC_rl[x,],0.05)})
upper_95 <- sapply(1:length(plot_rps), function (x) {quantile(MC_rl[x,],0.95)})

# We need a second panel to show the density at return level of 500
rl_500 <- MC_rl[32,]
h500<-hist(rl_500,40,plot = T,probability = T)

#frequentist maximum likelihood return levels
MC_rl_freq<-myreturnlevel(plot_rps,GEV_params[1],GEV_params[2],GEV_params[3])

# posterior mean return levels
MC_rl_mean<-sapply(1:nrow(MC_rl),function (x) {mean(MC_rl[x,])})
########### PLOT ##############
pdf("./Outputs/Figures/Return_Period_90percent_Uncertainty_Plot_hist.pdf",width =3.94, height =2.43)

# plot high-level variables
par(cex=0.5,mai=c(0.4,0.4,0.2,0.15)) #c(bottom, left, top, right)
par(cex=0.5,fig=c(0,0.7,0.05,1))

ymin=0
ymax=50000
xmin=1
xmax=500

# The base plot
plot(plot_rps,MC_rl_mean, log="x", xlim = c(xmin,xmax),type="n",bty="n",xaxt="n",xaxs="i",yaxs="i",
     ylim = c(ymin,ymax),yaxt="n",xlab = "",ylab="")

# Axes 
axis(1,pos=ymin, at=c(1,10,100,1000,500),cex.axis=1,lwd=1)
axis(2,pos=xmin, at = c(seq(ymin,ymax,by=20000)),labels=formatC(seq(ymin,ymax,by=20000), format="d", big.mark=','),cex.axis=1,lwd=1)

# x and y axis labels 
mtext("Return period (years)",side=1,line=2.5,cex=0.5)
mtext(expression("Discharge (m"^3*"/s)"),side=2,line=2.5,cex=0.5)

# Box around the plot 
lines(x=c(xmin,xmin),y=c(ymin,ymax))
lines(x=c(xmin,xmax),y=c(ymax,ymax))
lines(x=c(xmax,xmax),y=c(ymin,ymax))
lines(x=c(xmin,xmax),y=c(ymin,ymin))


# Uncertainty boundaries
polygon(x = c(plot_rps[2:length(plot_rps)],rev(plot_rps[2:length(plot_rps)])), 
        y = c(upper_95[2:length(plot_rps)], rev(lower_5[2:length(plot_rps)])), border = NA , col = myblue)

# With and without uncertainty lines
lines(plot_rps[2:length(plot_rps)],MC_rl_mean[2:length(MC_rl_mean)],lty=1,col="blue")
lines(plot_rps[2:length(plot_rps)],MC_rl_freq[2:length(MC_rl_freq)],lty=1,col="red")

# Observation points
points(median.rt(sort(annu_max_Q[,2])), sort(annu_max_Q[,2]), lwd = 1, cex = 0.75, pch = 20, bg = "white")

# Legend
legend(2,ymax-ymax*0.01,
       c("Maximum likelihood (frequentist)","Posterior mean (Bayesian)",
         "90% credible interval (uncertainty)","Observed annual maxima of discharge"),
       col = c('red',"blue", myblue,'black'),
       pt.bg = c(NA, NA, myblue,"white"),
       pch = c(NA, NA, 22,20),
       lty = c(1, 1,NA,NA),
       lwd = c(1, 1, NA,1.5),
       bty = 'n',
       pt.cex = c(NA, NA, 2,1),
       inset = c(0.01, -0.01),
       cex=1)
text(xmin+xmin*0.4,ymax-ymax*0.05,"a)",cex=1.5)

## Second panel 
par(cex=0.5,fig=c(0.62,1,0.05,1),new=TRUE)
xmin=0
xmax=max(h500$density)
xmax=xmax+0.1*xmax
ymean=MC_rl_mean[32]
yfreq=MC_rl_freq[32]

plot(NA,xlim = c(xmin,xmax),xaxt="n",xaxs="i",yaxs="i",
     ylim = c(ymin,ymax),yaxt="n",main="",xlab = "",ylab="")
axis(1,pos=ymin,at=c(xmin,max(h500$density)),labels=c(0,signif(max(h500$density),0)),cex.axis=1,lwd=1)
mtext("Projected density of\n500-year return period",side=1,line=3,cex=0.5)

# 500-yr floods histogram
for(i in 1:(length(h500$breaks)-1)){
polygon(x=c(0,h500$density[i],h500$density[i],0),
        y=c(h500$breaks[i],h500$breaks[i],h500$breaks[i+1],h500$breaks[i+1]),
        border = myblue,lwd=0.5)
}

lines(x=c(xmin,xmax),y=c(ymean,ymean),col="blue")
lines(x=c(xmin,xmax),y=c(yfreq,yfreq),col="red")
 
# Legend
legend(2e-5,ymax-ymax*0.01,
       c("Projected\nhistogram"),
       pch=22,
       pt.cex = 2,
       pt.bg ="white",
       pt.lwd =0.5,
       col=myblue,
       bty = 'n',
       cex=1)
# Panel indicator 
text(xmax*0.1,ymax-ymax*0.05,"b)",cex=1.5)

dev.off()
rm(list=setdiff(ls(), c("my_files","code")))
