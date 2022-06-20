##==============================================================================
##
## Script estimates GEV distribution parameters using MCMC and generates discharge
## samples for the Sobol analysis
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

wd<-getwd()
setwd(wd)
load("./Outputs/RData/annual_maxima_cms.RData") #annual maxima of discharge in cms
library(extRemes)

####################################################################################################
####################################################################################################
dat<-annu_max_Q[,2]
####################################################################################################
####################################################################################################
# Maximum Likelihood Approach
####################################################################################################
####################################################################################################
# The following code fits the GEV model using the fevd function from the extRemes package
fit<-fevd(dat,type = 'GEV', method = 'MLE', initial = list(c(0,1,0.5)))
# GEV location, shape, and scale parameters
location<-fit$results$par[1]
scale<-fit$results$par[2]
shape<-fit$results$par[3]
GEV_params=c(location,scale,shape)
GEV_params
save(GEV_params,file="./Outputs/RData/GEV_Parameters.RData")
GEV_mle<-ci(fit, alpha = 0.05, type = c("parameter")) # From the fExtremes Packages

save(GEV_mle,file="./Outputs/RData/GEV_MLE.RData")

#######################################################################################################################################
#######################################################################################################################################
#######################################################################################################################################
# Bayesian Approach
#######################################################################################################################################
#######################################################################################################################################
#######################################################################################################################################
# Log Likelihood Function
llhd<-function(par,dat){
  p<-sum(devd(x=dat, loc = par[1], scale = exp(par[2]), shape = par[3], log = TRUE,
       type = c("GEV")))
  if(p==-Inf){
    return(-999999999)
  }else{return(p)}
}

# Log Prior Density Function
lprior<-function(par){
  dnorm(x=par[1],mean=0,sd=sqrt(1e+10), log = TRUE) + dnorm(x=par[2],mean=0,sd=sqrt(100), log = TRUE) + dnorm(x=par[3],mean=0,sd=sqrt(1), log = TRUE)
}
# Log Posterior Density Function
lposterior<-function(par,dat){
  llhd(par,dat)+lprior(par)
}


#######################################################################################################################################
#######################################################################################################################################
# Bayesian Approach - Maximum A Posteriori
par.init<-GEV_params
par.init[2]<-log(GEV_params[2])
MAPoptimOutput<-optim(par = par.init ,fn = lposterior, dat=dat,  control=list(fnscale=-1),hessian=FALSE,
                   method = "L-BFGS-B" , 
                   lower = c(-Inf,-Inf,-Inf), upper = c(Inf,Inf,Inf))
GEV_est_MAP<-MAPoptimOutput$par
GEV_est_MAP[2]<-exp(GEV_est_MAP[2])
GEV_est_MAP
save(GEV_est_MAP,file="./Outputs/RData/GEV_Max_a_Posteriori.RData")

#######################################################################################################################################
#######################################################################################################################################
# Bayesian Approach - MCMC

# Bayesian Approach
library(adaptMCMC)
accept.mcmc = 0.234										# Optimal acceptance rate as # parameters->infinity
#	(Gelman et al, 1996; Roberts et al, 1997)
niter.mcmc = 2e5										# number of iterations for MCMC
gamma.mcmc = 0.7										# rate of adaptation (between 0.5 and 1, lower is faster adaptation)
burnin = round(niter.mcmc*0.5)				# how much to remove for burn-in
dat=annu_max_Q[,2]
# Run MCMC algorithm
par.init<-c(GEV_est_MAP[1],log(GEV_est_MAP[2]),GEV_est_MAP[3])

amcmc.out = MCMC(p=lposterior, n=niter.mcmc, init=par.init, adapt=TRUE, 
                 acc.rate=accept.mcmc,
                 gamma=gamma.mcmc, list=TRUE, n.start=round(0.01*niter.mcmc), dat=dat)

amcmc.out$acceptance.rate
mcmcSamples<-amcmc.out$samples[-(1:burnin),]
mcmcSamples[,2]<-exp(mcmcSamples[,2])
save(mcmcSamples,file="./Outputs/RData/GEV_Parameters_MCMC.RData")

#####################################
# Check for the convergence of MCMC parameters
source("./workflow/functions/batchmeans.R") # Load helper functions
summaryMCMC<-bmmat(mcmcSamples) # Computes the batch means standard error for mcmc Chain
summaryMCMC<-cbind(summaryMCMC,abs(summaryMCMC[,1]*0.01))
# rows pertain to the GEV parameters - location, scale, and shape
# columns refer to (1) sample mean;  (2) batch means standard error; and (3) 1% of the sample mean

# One way to check convergence of the mcmc chain is to see if the batch means standard error is 
# less than 1% of the absolute sample mean
summaryMCMC[,2]<summaryMCMC[,3]

# V1   V2   V3 
# TRUE TRUE TRUE 

#####################################
# Highest Posterior Density Function
## Using Ming-Hui Chen's paper in Journal of Computational and Graphical Stats.
hpd <- function(samp,p=0.05){
  ## to find an approximate (1-p)*100% HPD interval from a
  ## given posterior sample vector samp
  
  r <- length(samp)
  samp <- sort(samp)
  rang <- matrix(0,nrow=trunc(p*r),ncol=3)
  dimnames(rang) <- list(NULL,c("low","high","range"))
  for (i in 1:trunc(p*r)) {
    rang[i,1] <- samp[i]
    rang[i,2] <- samp[i+(1-p)*r]
    rang[i,3] <- rang[i,2]-rang[i,1]
  }
  hpd <- rang[order(rang[,3])[1],1:2]
  return(hpd)
}

######################################
bayesEstimator<-apply(mcmcSamples,2,function(x){c(mean(x), hpd(x))})
rownames(bayesEstimator)<-c("Posterior Mean" , "95%CI-Low", "95%CI-High")
# Results from Bayesian Approach (MCMC)
bayesEstimator
save(bayesEstimator,file="./Outputs/RData/GEV_Posterior_Mean.RData")

# Results from MLE Approach
GEV_mle

# Comparative plots for the results
xSeq<-seq(from=0,to=20000, length.out=100000)
yDensity<-devd(x = xSeq, loc = GEV_params[1] , scale = GEV_params[2] , shape = GEV_params[3],type="GEV")
yDensityBayes<-devd(x = xSeq , loc = bayesEstimator[1,1] , scale = bayesEstimator[1,2] , shape = bayesEstimator[1,3],type="GEV")
par(mfrow=c(2,2))
plot(x=annu_max_Q[,1], y=annu_max_Q[,2], pch=16, main = "Observations")
plot(density(annu_max_Q[,2]) , main= "Observation Density")
plot(x=xSeq , y=yDensity, type = "l",col="red" , main="Comparison of Densities: MLE vs. Bayes")
lines(x=xSeq , y=yDensityBayes)

# Trace plots for MCMC
par(mfrow=c(2,3), mar=c(2,2,2,2))
plot.ts(mcmcSamples[,1], main="location", ylim=range(mcmcSamples[,1], GEV_params[1])) ; abline(h=GEV_params[1], col="red")
plot.ts(mcmcSamples[,2], main="scale", ylim=range(mcmcSamples[,2], GEV_params[2])); abline(h=GEV_params[2], col="red")
plot.ts(mcmcSamples[,3], main="shape", ylim=range(mcmcSamples[,3], GEV_params[3])); abline(h=GEV_params[3], col="red")
plot(density(mcmcSamples[,1]), main="location"); abline(v=GEV_params[1], col="red")
plot(density(mcmcSamples[,2]), main="scale"); abline(v=GEV_params[2], col="red")
plot(density(mcmcSamples[,3]), main="shape"); abline(v=GEV_params[3], col="red")

n=1 # number of random discharge samples from each MCMC parameter set
discharge_df<-apply(mcmcSamples,1,function(x){revd(n,loc=x[1],scale=x[2],shape=x[3])})
discharge_df<-as.data.frame(discharge_df)
colnames(discharge_df)<-c('discharge_cms')
save(discharge_df,file="./Outputs/RData/MCMC_Discharge_CMS.RData")
#Taking random sample data from MCMC results
N=2000
set.seed(1)
Q_samp_A<-sample(discharge_df[,1],N)
set.seed(91)
Q_samp_B<-sample(discharge_df[,1],N)

library("dataRetrieval")
discharge<-readNWISdv(
  siteNumbers = "01554000",
  parameterCd = "00060",
  startDate = "2011-09-08",
  endDate = "2011-09-08")
discharge<-discharge[1,4]*0.3048^3 # convert to cms
error<-0.06 # based on USGS individual discharge measurement maximum error from:
# https://pubs.usgs.gov/of/1992/ofr92-144/#:~:text=The%20study%20indicates%20that%20standard,3%20percent%20to%206%20percent.

# which runs have discharge values within the range of error?
Q_for_precalib<-discharge_df[discharge_df[,1]>discharge*(1-error),]
Q_for_precalib<-Q_for_precalib[Q_for_precalib<discharge*(1+error)]

save(Q_samp_A,file='./Outputs/RData/Q_sample_A.RData')
save(Q_samp_B,file='./Outputs/RData/Q_sample_B.RData')
save(Q_for_precalib,file='./Outputs/RData/Q_for_precalib.RData')#for precailbration

rm(list=setdiff(ls(), c("my_files","code")))
