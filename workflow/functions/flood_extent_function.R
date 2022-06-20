flood_extent<-function(i){
  outputs <- data.frame()
  river <- sample_river
  par <- sample_par
  
  river[3, 7] <-
    as.numeric(para[i,"Q"]) # upstream discharge
  
  river[3, 5] <-
    as.numeric(river[3, 5]) + para[i,"Z"] # upstream river bed elevation
  river[7, 5] <-
    as.numeric(river[7, 5]) + para[i,"Z"] # downstream river bed elevation
  
  river[3, 3] <-
    as.numeric(river[3, 3]) * (1 + para[i,"W"]) # river width sections
  river[4, 3] <-
    as.numeric(river[4, 3]) * (1 + para[i,"W"]) # river width sections
  river[5, 3] <-
    as.numeric(river[5, 3]) * (1 + para[i,"W"]) # river width sections
  river[6, 3] <-
    as.numeric(river[6, 3]) * (1 + para[i,"W"]) # river width sections
  river[7, 3] <-
    as.numeric(river[7, 3]) * (1 + para[i,"W"]) # river width sections
  
  river[3, 4] <- para[i,"n_ch"] # upstream channel roughness
  river[7, 4] <- para[i,"n_ch"] # downstream channel roughness
  
  par[6, 2] <- para[i,"n_fp"] # floodplain roughness
  
  par[5, 2] <- paste0('dem', para[i,"DEM"], '.asc') # DEM resolution
  
  par[1, 2] <- paste0("run", i)
  par[7,2] <- paste0("run", i,".river")
 
  setwd(paste0(wd, '/LISFLOOD'))
  write.table(
    river,
    paste0("./run",i,".river"),
    row.names = F,
    col.names = F,
    quote = F,
    sep = "\t",
    na = ""
  )
  write.table(
    par,
    paste0("./run",i,".par"),
    row.names = F,
    col.names = F,
    quote = F,
    sep = "\t",
    na = ""
  )
  
  # Run LISFLOOD-FP on cluster
  command<-paste0('./lisflood.exe -v run',i,'.par')
  system(command)
  #file.rename(paste0("./results/run", i, ".max"), "./results/max.asc")
  file.copy(from=paste0("./results/run", i, ".max"), to=paste0('../Outputs/Initial_Outputs/Extent/run',i,'.max'))
  file.remove(paste0("./run",i,".river"))
  file.remove(paste0("./run",i,".par"))
  setwd(wd)
  
}
