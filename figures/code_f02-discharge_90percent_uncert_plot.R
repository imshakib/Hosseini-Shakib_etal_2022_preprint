##==============================================================================
##
## Script to plot upstream discharge pdfs and survival functions for the
## sampled and observed data as well as the MLE and MCMC results.
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

# Global variables
wd<-getwd()
setwd(wd)
set.seed(0)
if("fExtremes" %in% (.packages())){
  detach("package:fExtremes", unload=TRUE)
}
if("evd" %in% (.packages())){
  detach("package:evd", unload=TRUE)
}

library(evir)
myblue<-rgb(0.68, 0.85, 0.90,0.5)
load("./annual_maxima_cms.RData") # Annual maxima of discharge in cms
load("./GEV_Parameters.RData") # Frequentist maximum likelihood GEV parameter set
load("./GEV_Parameters_MCMC.RData") # MCMC parameter sets
load('./Q_sample_A.RData') # sampled discharge data

pdf_fun <- function(x,mu,sigma,xi){
  d<-dgev(x,mu=mu,sigma=sigma,xi=xi)
  return(d)
}

# GEV CDF function
cdf_fun<- function(x,mu,sigma,xi) {
  library(evir)
  cd<-pgev(x,mu=mu,sigma=sigma,xi=xi)
  return(cd)
}

#---------------------------------------------------------------------

plot_Qs <- c(seq(1000,35000,500)) # discharge values of axis x 

#Annual maxima of discharge
histogram<-hist(annu_max_Q$peak_va, freq=F) # observed maxima histogram
histogram$density<-histogram$density/(sum(histogram$density)*2000)
annu_Q_order<-annu_max_Q[order(annu_max_Q[,2]),2]
cdf_annu_Q<-ecdf(annu_Q_order)
surv_annu_Q<-1-cdf_annu_Q(annu_Q_order)

#Maximum Likelihood GEV 
MLE_Q<-dgev(min(plot_Qs):max(plot_Qs),mu=GEV_params[1],sigma=GEV_params[2],
            xi=GEV_params[3]) # discharge densities based on the maximum likelihood GEV
surv_mle<- sapply(min(plot_Qs):max(plot_Qs), function (x){1-cdf_fun(x,
                  mu=GEV_params[1],sigma=GEV_params[2],xi=GEV_params[3])})

#MCMC Discharge

PDF<-sapply(1:nrow(mcmcSamples), function(x) {
  pdf_fun(plot_Qs, mu=mcmcSamples[x,1], sigma=mcmcSamples[x,2], xi=mcmcSamples[x,3])
})
PDF[is.nan(PDF)] <- 1e-20
rownames(PDF)<-plot_Qs
save(PDF,file='./discharge_uncertainty_pdf.RData')
#load('./discharge_uncertainty_pdf.RData')

# Matrix of MCMC CDF values
CDF<-sapply(1:nrow(mcmcSamples), function(x) {
  cdf_fun(plot_Qs, mu=mcmcSamples[x,1], sigma=mcmcSamples[x,2], xi=mcmcSamples[x,3])
})
CDF[is.nan(CDF)] <- 1e-20
rownames(CDF)<-plot_Qs
save(CDF,file='./discharge_uncertainty_cdf.RData')
#load('./discharge_uncertainty_cdf.RData')

#Bayesian posterior mean  
mean_Bayes_Q<-sapply(1:length(plot_Qs), function(x){mean(PDF[x,])})
mean_surv_bayes<- sapply(1:length(plot_Qs), function(x){1-mean(CDF[x,])})

#Bayesian maximum a posteriori GEV 

# max_Bayes_Q<-dgev(min(plot_Qs):max(plot_Qs),mu=GEV_est_MAP[1],sigma=GEV_est_MAP[2],
#               xi=GEV_est_MAP[3])
# max_surv_bayes<- sapply(min(plot_Qs):max(plot_Qs), function (x){1-cdf_fun(x,
#                                                             mu=GEV_est_MAP[1],sigma=GEV_est_MAP[2],xi=GEV_est_MAP[3])})
#Sampled discharge
sample_Q<-sort(Q_samp_A) # 2000 samples from MCMC results
pdf_sample_Q<-density(sample_Q)
cdf_sample_Q<-ecdf(sample_Q)
surv_sample_Q<-1-cdf_sample_Q(sample_Q)


 # Find upper and lower density limits of MCMC discharge data
lower_5 <- sapply(1:length(plot_Qs), function (x){quantile(PDF[x,],0.05)})
upper_95 <- sapply(1:length(plot_Qs), function (x) {quantile(PDF[x,],0.95)})
surv_lower_5 <- sapply(1:length(plot_Qs), function (x){1-quantile(CDF[x,],0.95)})
surv_upper_95 <- sapply(1:length(plot_Qs), function (x) {1-quantile(CDF[x,],0.05)})

pdf("Discharge_90percent_Uncertainty_PDF.pdf",width =4.86,height =7.88)
################################################
### Panel A
################################################

# plot pdfs
par(mfrow=c(2,1))
par(cex=0.5,mai=c(0.5,0.4,0.1,0.3)) # mai   c(bottom, left, top, right)

ymin=0
ymax=1.1*max(upper_95)
xmin=0
xmax=max(plot_Qs)

# The base plot
plot(histogram, freq=F,xlim = c(xmin,xmax),xaxt="n",xaxs="i",yaxs="i",
     ylim = c(ymin,ymax),yaxt="n",main="",xlab = "",ylab="")

# Axes 
axis(1,pos=ymin, at=seq(0,xmax,5000),labels=formatC(seq(0,xmax,5000), format="d", big.mark=','),cex.axis=1.5,lwd=1)
axis(2, pos=xmin,at = c(0,round(max(upper_95),5)),labels=c(0,"0.0004"),lwd=1,cex.axis=1.5)

# x and y axis labels 
mtext(expression("Discharge (m"^3*"/s)"),side=1,line=3,cex=0.8)
mtext("Density",side=2,line=2.5,cex=0.8)

# Box around the plot 
lines(x=c(xmin,xmax),y=c(ymin,ymin))
lines(x=c(xmin,xmin),y=c(ymin,ymax))
lines(x=c(xmin,xmax),y=c(ymax,ymax))
lines(x=c(xmax,xmax),y=c(ymin,ymax))

# Uncertainty boundaries
polygon(x = c(plot_Qs,rev(plot_Qs)), 
        y = c(lower_5, rev(upper_95)),
        border = NA , col=myblue)

# MLE PDF and samples PDF

lines(min(plot_Qs):max(plot_Qs),MLE_Q,lty=1,col="red",lwd=2)
lines(plot_Qs,mean_Bayes_Q,lty=1,col="blue",lwd=2)
# lines(pdf_sample_Q$x[-(1:19)],pdf_sample_Q$y[-(1:19)] ,lty=2,col="green",lwd=2)
lines(pdf_sample_Q$x,pdf_sample_Q$y ,lty=2,col="green",lwd=2)
# Legend
legend(12000,ymax-ymax*0.01,
       c("Maximum likelihood (frequentist)","Posterior mean (Bayesian)","Sampled discharge","90% credible interval (uncertainty)","Observed annual maxima of discharge"),
       col = c('red','blue','green',myblue,'black'),
       pt.bg = c(NA,NA,NA, myblue,"white"),
       pch = c(NA,NA,NA, 22,22),
       lty = c(1,1,2,NA,NA),
       lwd = c(2,2,2,NA,0.5),
       bty = 'n',
       pt.cex = c(NA,NA,NA,2,2),
       cex=1.5)
# Panel indicator 
text(xmin+1000,ymax-ymax*0.05,"a)",cex=1.5)

################################################
### Panel B
################################################
# plot survival functions
#pdf("Discharge_Uncertainty_PDF1.pdf",width =3.94,height =2.43)

par(cex=0.5,mai=c(0.5,0.4,0.1,0.3)) # mai   c(bottom, left, top, right)

ymin=1.5e-5
ymax=2
xmin=0
xmax=max(plot_Qs)

# The base plot
plot(plot_Qs,mean_surv_bayes, xlim = c(xmin,xmax),pch=NA,xaxt="n",xaxs="i",yaxs="i",
     ylim = c(ymin,ymax),yaxt="n",main="",xlab = "",ylab="",log = "y")

# Axes 
axis(1,pos=ymin, at=seq(0,xmax,5000),labels=formatC(seq(0,xmax,5000), format="d", big.mark=','),cex.axis=1.5,lwd=1)
axis(2, pos=xmin,lwd=1,cex.axis=1.5)

# x and y axis labels 
mtext(expression("Discharge (m"^3*"/s)"),side=1,line=3,cex=0.8)
mtext("Survival (1-CDF)",side=2,line=2.5,cex=0.8)

# Box around the plot 
lines(x=c(xmin,xmin),y=c(ymin,ymax))
lines(x=c(xmin,xmax),y=c(ymax,ymax))
lines(x=c(xmax,xmax),y=c(ymin,ymax))

# Uncertainty boundaries
polygon(x = c(plot_Qs,rev(plot_Qs)), 
        y = c(surv_lower_5,
              rev(surv_upper_95)),
        border = NA , col=myblue)

# MLE PDF
lines(min(plot_Qs):max(plot_Qs),surv_mle,lty=1,col="red",lwd=2)
lines(plot_Qs,mean_surv_bayes,lty=1,col="blue",lwd=2)
lines(sample_Q,surv_sample_Q,lty=2,col="green",lwd=2)
points(annu_Q_order,surv_annu_Q,pch=16)

# Legend
legend(12000,1.5,
       c("Maximum likelihood (frequentist)","Posterior mean (Bayesian)","Sampled discharge","90% credible interval (uncertainty)","Observed annual maxima of discharge"),
       col = c('red','blue','green',myblue,'black'),
       pt.bg = c(NA,NA,NA, myblue,"white"),
       pch = c(NA,NA,NA, 22,16),
       lty = c(1,1,2,NA,NA),
       lwd = c(2,2,2,NA,0.5),
       bty = 'n',
       pt.cex = c(NA,NA,NA,2,2),
       cex=1.5)

text(xmin+1000,0.5,"b)",cex=1.5)

dev.off()

