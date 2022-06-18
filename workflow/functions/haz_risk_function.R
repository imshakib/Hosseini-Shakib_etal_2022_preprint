haz_risk_run<-function(i){
  library(raster)
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
  
  setwd(paste0(wd, '/LISFLOOD'))
  write.table(
    river,
    "./Selinsgrove.river",
    row.names = F,
    col.names = F,
    quote = F,
    sep = "\t",
    na = ""
  )
  write.table(
    par,
    "./Selinsgrove.par",
    row.names = F,
    col.names = F,
    quote = F,
    sep = "\t",
    na = ""
  )
  
  print(paste("Run", i))
  # Run LISFLOOD-FP on Desktop
  system("./lisflood -v Selinsgrove.par")
  # Run LISFLOOD-FP on cluster
  #system("./lisflood.exe -v Selinsgrove.par")
  #file.rename(paste0("./results/run", i, ".max"), "./results/max.asc")
  
  #flood extent
  model_hazard <- raster(paste0("./results/run", i, ".max"), format = "ascii")

  
  #flood hazard at houses
  model_hazard_crop <- crop(model_hazard, house_price)
  new_crop <- resample(model_hazard_crop, house_price)
  houses_model_hazard <- mask(new_crop, house_price)
  houses_table <- as.data.frame(houses_model_hazard , xy = T)
  mean_hazard <- sum(houses_table[,3], na.rm = T)/2000

    #vulnerability
  vulnerability <-
    approx(vulner_table$Water_height_m,
           vulner_table$Damage_percent,
           houses_table[, 3])
  houses_table$damage_percent <- vulnerability$y / 100
  xyz <- cbind(houses_table[, 1:2], houses_table[, 4])
  vulnerability_raster <- (1 + para[i,"V"]) * rasterFromXYZ(xyz)
  
  #flood risk
  houses_model_risk <-
    vulnerability_raster * (1 + para[i,"X"]) * house_price * 250 # assuming average house area of 250 square meters in Selinsgrove
  damage_USD <- as.data.frame(houses_model_risk)
  damaged_houses <- na.omit(damage_USD)
  damaged_houses <- damaged_houses[damaged_houses>1,] # damage > 1 USD
  total_damage_USD <- if(length(damaged_houses>0)) sum(damaged_houses) else 0
  
  
  # saving results: model flood extend, hazard and risk
  setwd(wd)
   
  outputs[1, 1] <- i
  outputs[1, 2] <- mean_hazard
  outputs[1, 3] <- total_damage_USD
  outputs[1,4] <- length(damaged_houses)
  
  # Save results
  writeRaster(
    model_hazard,
    paste0("./Outputs/Extent/Run_", i, ".asc"),
    format = "ascii",
    overwrite = T
  )
  writeRaster(
    houses_model_hazard,
    paste0("./Outputs/Hazard/Run_", i, ".asc"),
    format = "ascii",
    overwrite = T
  )
  writeRaster(
    houses_model_risk,
    paste0("./Outputs/Risk/Run_", i, ".asc"),
    format = "ascii",
    overwrite = T
  )
  
  colnames(outputs) <-
    c("run no.","mean hazard (m)", "total risk (USD)","n damaged houses")
  write.csv(outputs, paste0("./Outputs/Summary/Run_", i, ".csv"))
}
