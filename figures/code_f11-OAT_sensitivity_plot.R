##==============================================================================
##
## Script for OAT sensitivity results plot
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


#parameter sets and model responses
load('Outputs/RData/OAT_parameter_set.RData')
load('./Outputs/RData/OAT_model_response.RData')
# load('./Pregenerated_outputs/RData/OAT_model_response.RData')
params <- c("Q", "Z", "W", "n_ch", "n_fp", "DEM","V","X") # name of parameters
labels<-c('Upstream discharge (Q)','River bed elevation (Z)','River width (W)',
          'Channel roughness (n_ch)','Floodplain roughness (n_fp)','DEM resolution (DEM)',
          'Vulnerability (V)','Exposure (X)')
names(labels)<-params

# function to map  a bounded parameter range
map_range <- function(x, bdin, bdout) {
  bdout[1] + (bdout[2] - bdout[1]) * ((x - bdin[1]) / (bdin[2] - bdin[1]))
}


nsamp <- 10
DEMsamp <- 3
nrows<-(length(params)-1)*nsamp+DEMsamp
ncols=length(params)
parcolumn=NULL
for (i in params) {
  data<-matrix(rep(i,nsamp),nrow=nsamp)
  parcolumn<-rbind(parcolumn,data)
}
parcolumn<-parcolumn[-(54:60),]
data<-data.frame(para,model_response[,2:3],variable=parcolumn)

#ranges of hazard and risk variability
haz_range<-range(data[,9])
risk_range<-range(data[,10])

haz_risk_table<-NULL
ranges_table<-as.data.frame(matrix(NA,length(params),9))
for (i in 1:length(params)) {
table<-data[data[,'variable']==params[i],]
quant<-(table[,params[i]]-min(table[,params[i]]))*100/
  (max(table[,params[i]])-min(table[,params[i]]))
tab<-cbind(
rep(params[i],nrow(table)),
quant,
table[,9:10])
haz_risk_table<-rbind(haz_risk_table,tab)

ranges_table[i,1]<-params[i]
ranges_table[i,2]<-as.numeric(min(table[,9]))
ranges_table[i,3]<-as.numeric(max(table[,9]))
ranges_table[i,4]<-as.numeric(min(table[,10]))
ranges_table[i,5]<-as.numeric(max(table[,10]))
#map ranges to [0,100]
ranges_table[i,6]<-map_range(ranges_table[i,2],haz_range,c(0,100))
ranges_table[i,7]<-map_range(ranges_table[i,3],haz_range,c(0,100))
ranges_table[i,8]<-map_range(ranges_table[i,4],risk_range,c(0,100))
ranges_table[i,9]<-map_range(ranges_table[i,5],risk_range,c(0,100))

}
colnames(haz_risk_table)<-c('variable','quantile','hazard','risk')
colnames(ranges_table)<-c('parameter','min_haz','max_haz','min_risk','max_risk',
                          'haz_low_range','haz_up_range','risk_low_range','risk_up_range')
########### PLOT ##############
pdf("./Outputs/Figures/OAT_Plot.pdf",width =7, height =5)

par(cex=0.5,mai=c(0.4,0.1,0.1,0.1)) #c(bottom, left, top, right)

###risk variability
par(cex=0.5,fig=c(0.05,0.55,0.05,0.5)) # c(x1, x2, y1, y2) 

ymin=-1e5
ymax=1.5e6
xmin=0
xmax=200

# The base plot
plot(NA,xlim = c(xmin,xmax),xaxt="n",xaxs="i",yaxs="i",ylim=c(ymin,ymax),
     yaxt="n",main="",xlab = "",ylab="")

# Axis 
axis(1,pos=ymin, at=c(0,25,0,50,75,100),cex.axis=1.5,lwd=1)


# x axis label 
mtext("Percent of total variance",
      side=1,line=3,cex=0.8)
ys<-(length(params):1)*(ymax-ymin)/10
width=100e3
tab<-ranges_table[order(ranges_table$risk_up_range,decreasing = T),]
for (i in 1:length(params)) {
polygon(x=c(tab[i,8:9],rev(tab[i,8:9])),y=c(ys[i],ys[i],ys[i]+width,ys[i]+width),col=i) 
if(tab[i,9]-tab[i,8]<1) color='grey' else color='black'
text(x=xmax-5,y=ys[i]+width/2,labels=labels[tab[i,1]],adj=1,cex=1.5,col=color) 
 }
abline(v=50,lty=2)

# Panel indicator 
mtext("b) Risk",cex=1,adj=0,line=1)

###risk quantiles

par(cex=0.5,fig=c(0.55,0.9,0.05,0.5),new=T) # c(x1, x2, y1, y2) 

xmin=0
xmax=100

# The base plot
plot(NA,xlim = c(0,100),xaxt="n",xaxs="i",yaxs="i",ylim=c(ymin,ymax),
     yaxt="n",main="",xlab = "",ylab="")

# Axes 
axis(1,pos=ymin, at=c(0,25,50,75,100),cex.axis=1.5,lwd=1)
axis(4,pos=100, at = c(seq(0,ymax,by=0.5e6)),
     labels=formatC(seq(0,ymax/1e6,by=0.5), format="g", big.mark=','),
     cex.axis=1.5,lwd=1)

# x and y axis labels 
mtext("Quantile of sample (%)",side=1,line=3,cex=0.8)
mtext(expression("Total damage (million USD)"),side=4,line=4,cex=0.8)

for (i in 1:nrow(tab)) {
  tab2<-haz_risk_table[haz_risk_table[,1]==tab[i,1],]
lines(as.numeric(tab2[,2]),as.numeric(tab2[,4]),col=i,lwd=2)  
points(as.numeric(tab2[,2]),as.numeric(tab2[,4]),col=i,pch=5)
}
abline(v=50,lty=2)
#################################
###hazard variability
par(cex=0.5,fig=c(0.05,0.55,0.5,0.95),new=T) # c(x1, x2, y1, y2) 

ymin=-0.1
ymax=2
xmin=0
xmax=200

# The base plot
plot(NA,xlim = c(xmin,xmax),xaxt="n",xaxs="i",yaxs="i",ylim=c(ymin,ymax),
     yaxt="n",main="",xlab = "",ylab="")

# Axis 
axis(1,pos=ymin, at=c(0,25,0,50,75,100),cex.axis=1.5,lwd=1,labels=F)

ys<-(length(params):1)*(ymax-ymin)/10
width=(ymax-ymin)/16
tab<-ranges_table[order(ranges_table$haz_up_range,decreasing = T),]
for (i in 1:(length(params)-2)) {
  polygon(x=c(tab[i,6:7],rev(tab[i,6:7])),y=c(ys[i],ys[i],ys[i]+width,ys[i]+width),col=i) 
  if(tab[i,7]-tab[i,6]<1) color='grey' else color='black'
  text(x=xmax-5,y=ys[i]+width/2,labels=labels[tab[i,1]],adj=1,cex=1.5,col=color) 
}
abline(v=50,lty=2)

# Panel indicator 
mtext("a) Hazard",cex=1,adj=0,line=1)

###hazard quantiles
par(cex=0.5,fig=c(0.55,0.9,0.5,0.95),new=T) # c(x1, x2, y1, y2)

xmin=0
xmax=100

# The base plot
plot(NA,xlim = c(0,100),xaxt="n",xaxs="i",yaxs="i",ylim=c(ymin,ymax),
     yaxt="n",main="",xlab = "",ylab="")
# Axes 
axis(1,pos=ymin, at=c(0,25,50,75,100),cex.axis=1.5,lwd=1,labels=F)
axis(4,pos=100, at = c(seq(0,ymax,by=0.5)),
     labels=formatC(seq(0,ymax,by=0.5), format="g", big.mark=','),
     cex.axis=1.5,lwd=1)

# x and y axis labels 
mtext(expression("Average flood depth (m)"),side=4,line=4,cex=0.8)

for (i in 1:nrow(tab)) {
  tab2<-haz_risk_table[haz_risk_table[,1]==tab[i,1],]
  lines(as.numeric(tab2[,2]),as.numeric(tab2[,3]),col=i,lwd=2)  
  points(as.numeric(tab2[,2]),as.numeric(tab2[,3]),col=i,pch=5)  
  
}
abline(v=50,lty=2)
dev.off()
rm(list=setdiff(ls(), c("my_files","code")))
