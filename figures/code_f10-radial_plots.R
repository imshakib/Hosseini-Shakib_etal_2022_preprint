##==============================================================================
##
## Script for radial plot of flood hazard and risk
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

mygreen <- rgb(44/255, 185/255, 95/255, 1) 
myblue <- rgb(0/255, 128/255, 1, 1)
myred <- rgb(1, 102/255, 102/255, 1)

# Loading libraries 
library(RColorBrewer)
library(graphics)
library(plotrix)

source('./workflow/functions/sobol_functions.R')

# input files that contain sobol indices
sobol_file_1 <- "./Outputs/RData/radial_plot_table_1_haz.RData"
sobol_file_2 <- "./Outputs/RData/radial_plot_table_2_haz.RData"
load('./Outputs/RData/dummy_haz.RData')
# sobol_file_1 <- "./Pregenerated_outputs/RData/radial_plot_table_1_haz.RData"
# sobol_file_2 <- "./Pregenerated_outputs/RData/radial_plot_table_2_haz.RData"
# load('./Pregenerated_outputs/RData/dummy_haz.RData')

pdf('./Outputs/Figures/radial_plots.pdf',width =3.94*2, height =3.94)
par(mfrow=c(1,2),cex=0.7)

#######################
#######################
##HAZARD RADIAL PLOT
#######################
#######################
n_params <- 8 # set number of parameters
names=c('Discharge','River Bed\nElevation','River\nWidth','Channel\nRoughness',
        'Floodplain\nRoughness','DEM\nResolution','','')
cols=c('darkgreen','darkgreen','darkgreen','darkgreen',
       'darkgreen','darkgreen')

## Import data from sensitivity analysis
# First- and total-order indices
load(sobol_file_1)
s1st <- df
parnames <- s1st[,1]

# Import second-order indices
load(sobol_file_2)
s2_table <- df

# Convert second-order to upper-triangular matrix
s2 <- matrix(nrow=n_params, ncol=n_params, byrow=FALSE)
s2[1:(n_params-1), 2:n_params] = upper.diag(s2_table$S2)
s2 <- as.data.frame(s2)
colnames(s2) <- rownames(s2) <- s1st$Parameter

# Convert confidence intervals to upper-triangular matrix
s2_conf_low <- matrix(nrow=n_params, ncol=n_params, byrow=FALSE)
s2_conf_high <- matrix(nrow=n_params, ncol=n_params, byrow=FALSE)
s2_conf_low[1:(n_params-1), 2:n_params] = upper.diag(s2_table$S2_conf_low)
s2_conf_high[1:(n_params-1), 2:n_params] = upper.diag(s2_table$S2_conf_high)

s2_conf_low <- as.data.frame(s2_conf_low)
s2_conf_high <- as.data.frame(s2_conf_high)
colnames(s2_conf_low) <- rownames(s2_conf_low) <- s1st$Parameter
colnames(s2_conf_high) <- rownames(s2_conf_high) <- s1st$Parameter

# Determine which indices are statistically significant
dummy<-ind.dummy
sig.cutoff_S1 <- dummy$high.ci[1]
sig.cutoff_ST <- dummy$high.ci[2]
 
# S1 & ST: using the confidence intervals
s1st1<-s1st

for (i in 1:nrow(s1st)) {
s1st1$s1_sig[i]<-if(s1st1$S1[i]-sig.cutoff_S1>=0) 1 else(0)
s1st1$st_sig[i]<-if(s1st1$ST[i]-sig.cutoff_ST>=0) 1 else(0)
s1st1$sig[i]<-max(s1st1$s1_sig[i],s1st1$st_sig[i])
}

# S2: using the confidence intervals
s2_sig1 <- stat_sig_s2(s2,s2_conf_low,s2_conf_high,method='gtr',greater=0)

# Settings for the radial plot
cent_x=0
cent_y=0.2
radi=0.6
alph=360/(n_params)

#pdf('./Outputs/Figures/radial_plot_hazard.pdf',width =3.94, height =3.94)
par(mai=c(0.1,0.1,0.1,0.1))
plot(c(-1,1),c(-1,1),bty="n",xlab="",ylab="",xaxt="n",yaxt="n",type="n")
draw.circle(0,.2,0.5,border = NA,col="gray90")

for(j in 1:(n_params)){
  i=j-1
  cosa=cospi(alph*i/180)
  sina=sinpi(alph*i/180)
  text(cent_x+cosa*(radi+radi*.25),cent_y+sina*(radi+radi*.15),names[j],srt=0,cex=1,col=cols[j])
  
  myX=cent_x+cosa*(radi-0.2*radi)
  myY=cent_y+sina*(radi-0.2*radi)
  for (z in j:n_params){ #Second-order interactions 
    if(s2_sig1[j,z]==1){
      g=z-1
      cosaa=cospi(alph*g/180)
      sinaa=sinpi(alph*g/180)
      EndX=cent_x+cosaa*(radi-0.2*radi)
      EndY=cent_y+sinaa*(radi-0.2*radi)
      lines(c(myX,EndX),c(myY,EndY),col='darkblue',
            lwd=qunif((s2[j,z]*s2_sig1[j,z]-min(s2*s2_sig1,na.rm=T))/(max(s2*s2_sig1,na.rm=T)-min(s2*s2_sig1,na.rm=T)),0.5,5))
    }
  }
  
  if(s1st1[j,9]>=1){ #Total-order nodes 
    draw.circle(cent_x+cosa*(radi-0.2*radi),cent_y+sina*(radi-0.2*radi),
                radius = qunif((s1st1[j,5]-min(s1st1[,5]))/(max(s1st1[,5])-min(s1st1[,5])),0.03,0.1),
                col="black")}
  
  if(s1st1[j,8]>=1){ #First-order nodes 
    draw.circle(cent_x+cosa*(radi-0.2*radi),cent_y+sina*(radi-0.2*radi),
                radius = qunif((s1st1[j,2]-min(s1st1[,2]))/(max(s1st1[,2])-min(s1st1[,2])),0.01,0.08),
                col=rgb(1, 102/255, 102/255,1),border = NA)}
}

# Plot the box below the plot 
x1=0.3
y1=0
draw.circle(x1+-0.9,y1+-0.97,0.08,border = NA,col=rgb(1, 102/255, 102/255,1))
draw.circle(x1+-0.7,y1+-0.97,0.01,border = NA,col=rgb(1, 102/255, 102/255,1))
text(x1+-0.9,y1+-0.83,paste(round(100*max(s1st1[s1st1[,"s1_sig"]>=1,2])),'%',sep=""))
text(x1+-0.7,y1+-0.83,paste(round(100*min(s1st1[s1st1[,"s1_sig"]>=1,2])),'%',sep=""))
text(x1+-0.8,y1+-0.75,'First-order')

draw.circle(x1+-0.4,y1+-0.97,0.1,col="black")
draw.circle(x1+-0.2,y1+-0.97,0.03,col="black")
text(x1+-0.4,y1+-0.83,paste(round(100*max(s1st1[s1st1[,"st_sig"]>=1,4])),'%',sep=""))
text(x1+-0.2,y1+-0.83,paste(round(100*min(s1st1[s1st1[,"st_sig"]>=1,4])),'%',sep=""))
text(x1+-0.3,y1+-0.75,'Total-order')

lines(c(x1+0.1,x1+0.2),c(y1+-0.97,y1+-0.97),lwd=5,col="darkblue")
text(x1+0.15,y1+-0.83,paste(round(100*max(s2[s2_sig1>=1],na.rm=T)),'%',sep=""))
text(x1+0.15,y1+-0.75,'Second-order')
mtext("a)",adj=0,line=-2,cex=2)
#######################
#######################
##RISK RADIAL PLOT
#######################
#######################
# input files that contain sobol indices
sobol_file_1 <- "./Outputs/RData/radial_plot_table_1_risk.RData"
sobol_file_2 <- "./Outputs/RData/radial_plot_table_2_risk.RData"
load('./Outputs/RData/dummy_risk.RData')
# sobol_file_1 <- "./Pregenerated_outputs/RData/radial_plot_table_1_risk.RData"
# sobol_file_2 <- "./Pregenerated_outputs/RData/radial_plot_table_2_risk.RData"
# load('./Pregenerated_outputs/RData/dummy_risk.RData')

n_params <- 8 # set number of parameters
names=c('Discharge','River Bed\nElevation','River\nWidth','Channel\nRoughness',
        'Floodplain\nRoughness','DEM\nResolution','Vulnerability','Exposure')
cols=c('darkgreen','darkgreen','darkgreen','darkgreen',
       'darkgreen','darkgreen','darkred','purple')

## Import data from sensitivity analysis
# First- and total-order indices
load(sobol_file_1)
s1st <- df
parnames <- s1st[,1]

# Import second-order indices
load(sobol_file_2)
s2_table <- df

# Convert second-order to upper-triangular matrix
s2 <- matrix(nrow=n_params, ncol=n_params, byrow=FALSE)
s2[1:(n_params-1), 2:n_params] = upper.diag(s2_table$S2)
s2 <- as.data.frame(s2)
colnames(s2) <- rownames(s2) <- s1st$Parameter

# Convert confidence intervals to upper-triangular matrix
s2_conf_low <- matrix(nrow=n_params, ncol=n_params, byrow=FALSE)
s2_conf_high <- matrix(nrow=n_params, ncol=n_params, byrow=FALSE)
s2_conf_low[1:(n_params-1), 2:n_params] = upper.diag(s2_table$S2_conf_low)
s2_conf_high[1:(n_params-1), 2:n_params] = upper.diag(s2_table$S2_conf_high)

s2_conf_low <- as.data.frame(s2_conf_low)
s2_conf_high <- as.data.frame(s2_conf_high)
colnames(s2_conf_low) <- rownames(s2_conf_low) <- s1st$Parameter
colnames(s2_conf_high) <- rownames(s2_conf_high) <- s1st$Parameter

# Determine which indices are statistically significant
dummy<-ind.dummy
sig.cutoff_S1 <- dummy$high.ci[1]
sig.cutoff_ST <- dummy$high.ci[2]


# S1 & ST: using the confidence intervals
s1st1<-s1st

for (i in 1:nrow(s1st)) {
  s1st1$s1_sig[i]<-if(s1st1$S1[i]-sig.cutoff_S1>=0) 1 else(0)
  s1st1$st_sig[i]<-if(s1st1$ST[i]-sig.cutoff_ST>=0) 1 else(0)
  s1st1$sig[i]<-max(s1st1$s1_sig[i],s1st1$st_sig[i])
}

# S2: using the confidence intervals
s2_sig1 <- stat_sig_s2(s2,s2_conf_low,s2_conf_high,method='gtr',greater=0)


# Settings for the radial plot
cent_x=0
cent_y=0.2
radi=0.6
alph=360/(n_params)


#pdf('./Outputs/Figures/radial_plot_risk.pdf',width =3.94, height =3.94)

par(mai=c(0.1,0.1,0.1,0.1))
plot(c(-1,1),c(-1,1),bty="n",xlab="",ylab="",xaxt="n",yaxt="n",type="n")
draw.circle(0,.2,0.5,border = NA,col="gray90")

for(j in 1:(n_params)){
  i=j-1
  cosa=cospi(alph*i/180)
  sina=sinpi(alph*i/180)
  text(cent_x+cosa*(radi+radi*.25),cent_y+sina*(radi+radi*.15),names[j],srt=0,cex=1,col=cols[j])
  
  myX=cent_x+cosa*(radi-0.2*radi)
  myY=cent_y+sina*(radi-0.2*radi)
  for (z in j:n_params){ #Second-order interactions 
    if(s2_sig1[j,z]==1){
      g=z-1
      cosaa=cospi(alph*g/180)
      sinaa=sinpi(alph*g/180)
      EndX=cent_x+cosaa*(radi-0.2*radi)
      EndY=cent_y+sinaa*(radi-0.2*radi)
      lines(c(myX,EndX),c(myY,EndY),col='darkblue',
            lwd=qunif((s2[j,z]*s2_sig1[j,z]-min(s2*s2_sig1,na.rm=T))/(max(s2*s2_sig1,na.rm=T)-min(s2*s2_sig1,na.rm=T)),0.5,5))
    }
  }
  
  if(s1st1[j,9]>=1){ #Total-order nodes 
    draw.circle(cent_x+cosa*(radi-0.2*radi),cent_y+sina*(radi-0.2*radi),
                radius = qunif((s1st1[j,5]-min(s1st1[,5]))/(max(s1st1[,5])-min(s1st1[,5])),0.03,0.1),
                col="black")}
  
  if(s1st1[j,8]>=1){ #First-order nodes 
    draw.circle(cent_x+cosa*(radi-0.2*radi),cent_y+sina*(radi-0.2*radi),
                radius = qunif((s1st1[j,2]-min(s1st1[,2]))/(max(s1st1[,2])-min(s1st1[,2])),0.01,0.08),
                col=rgb(1, 102/255, 102/255,1),border = NA)}
}

# Plot the box below the plot 
x1=0.3
y1=0
draw.circle(x1+-0.9,y1+-0.97,0.08,border = NA,col=rgb(1, 102/255, 102/255,1))
draw.circle(x1+-0.7,y1+-0.97,0.01,border = NA,col=rgb(1, 102/255, 102/255,1))
text(x1+-0.9,y1+-0.83,paste(round(100*max(s1st1[s1st1[,"s1_sig"]>=1,2])),'%',sep=""))
text(x1+-0.7,y1+-0.83,paste(round(100*min(s1st1[s1st1[,"s1_sig"]>=1,2])),'%',sep=""))
text(x1+-0.8,y1+-0.75,'First-order')

draw.circle(x1+-0.4,y1+-0.97,0.1,col="black")
draw.circle(x1+-0.2,y1+-0.97,0.03,col="black")
text(x1+-0.4,y1+-0.83,paste(round(100*max(s1st1[s1st1[,"st_sig"]>=1,4])),'%',sep=""))
text(x1+-0.2,y1+-0.83,paste(round(100*min(s1st1[s1st1[,"st_sig"]>=1,4])),'%',sep=""))
text(x1+-0.3,y1+-0.75,'Total-order')

lines(c(x1+0.1,x1+0.2),c(y1+-0.97,y1+-0.97),lwd=5,col="darkblue")
text(x1+0.15,y1+-0.83,paste(round(100*max(s2[s2_sig1>=1],na.rm=T)),'%',sep=""))
text(x1+0.15,y1+-0.75,'Second-order')
mtext("b)",adj=0,line=-2,cex=2)

dev.off()
rm(list=setdiff(ls(), c("my_files","code")))
