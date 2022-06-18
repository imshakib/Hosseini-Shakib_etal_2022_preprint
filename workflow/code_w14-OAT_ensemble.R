# Set working directory
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)
load('Q_sample_A.RData')
load('./Q_sample_B.RData')

parnames <- c("Q", "Z", "W", "n_ch", "n_fp", "DEM","V","X") # name of parameters
parvals <- c(11300,0,0,0.03,0.12,30,0,0)

nsamp <- 10
DEMsamp <- 3
nrows<-(length(parnames)-1)*nsamp+DEMsamp
ncols=length(parvals)
parcolumn=NULL
for (i in parnames) {
  data<-matrix(rep(i,nsamp),nrow=nsamp)
  parcolumn<-rbind(parcolumn,data)
}
parcolumn<-parcolumn[-(54:60),]
para<-matrix(NA,nrows,ncols)
for (i in 1:nrows) {
  para[i,]<-parvals
}
colnames(para)<-parnames
para<-data.frame(variable=parcolumn,para)
Q_range<-range(c(Q_samp_A,Q_samp_B))
Q<-seq(Q_range[1],Q_range[2],length.out=nsamp)
Z<-seq(-5,+5,length.out=nsamp)
W<-seq(-0.1,+0.1,length.out=nsamp)
n_ch<-seq(0.02,0.1,length.out=nsamp)
n_fp<-seq(0.02,0.2,length.out=nsamp)
DEM<-c(10,30,50)
V<-seq(-0.4,+0.4,length.out=nsamp)
X<-seq(-0.4,+0.4,length.out=nsamp)

para[para[,1]==parnames[1],'Q']<-Q
para[para[,1]==parnames[2],'Z']<-Z
para[para[,1]==parnames[3],'W']<-W
para[para[,1]==parnames[4],'n_ch']<-n_ch
para[para[,1]==parnames[5],'n_fp']<-n_fp
para[para[,1]==parnames[6],'DEM']<-DEM
para[para[,1]==parnames[7],'V']<-V
para[para[,1]==parnames[8],'X']<-X
para<-para[,-1]
save(para,file='./OAT_parameter_set.RData')

