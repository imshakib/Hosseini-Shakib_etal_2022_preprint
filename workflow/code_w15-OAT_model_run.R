library("raster")
library("foreach")
library("doParallel")

# Set working directory
(wd <- getwd())
if (!is.null(wd))
  setwd(wd)

# model setup and run

#parameter sets and functions
load('OAT_parameter_set.RData')
source('./OAT_haz_risk_function.R')

# Read the depth-damage table and hypothetical houses unit price estimate raster
vulner_table <-
  read.csv("./Inputs/vulnerability.csv") # depth-damage table for Selinsgrove for a one story house without basement from (Stuart A. Davis and L. Leigh Skaggs 1992)
house_price <- raster("./Inputs/house_price.asc")

# Read LISFLOOD-FP river and parameter files
sample_river <-
  as.matrix(read.delim2("./LISFLOOD_8/Sample_Selinsgrove.river", header = F)) # sample Susquehanna River file
sample_par <-
  as.matrix(read.delim2("./LISFLOOD_8/Sample_Selinsgrove.par", header = F)) # sample parameter file

# Output folders
if (dir.exists(paste0(wd, "/OAT")) == F)
  dir.create(paste0(wd, "/OAT"))
if (dir.exists(paste0(wd, "/OAT/Extent")) == F)
  dir.create(paste0(wd, "/OAT/Extent"))
if (dir.exists(paste0(wd, "/OAT/Hazard")) == F)
  dir.create(paste0(wd, "/OAT/Hazard"))
if (dir.exists(paste0(wd, "/OAT/Risk")) == F)
  dir.create(paste0(wd, "/OAT/Risk"))
if (dir.exists(paste0(wd, "/OAT/Summary")) == F)
  dir.create(paste0(wd, "/OAT/Summary"))


run_start = 1 #starting row number of the parameters table to read
run_end = nrow(para) #ending row number of the parameters table to read


#setwd(paste0(wd,'/LISFLOOD'))
#system("./chmod a+x lisflood.exe") # activate the .exe file for the first time lisflood.exe is being executed

#setup parallel backend to use many processors
cores=detectCores()
cl <- makeCluster(cores[1]-1) # -1 not to overload system
registerDoParallel(cl)

start<-proc.time()

# the loop to parallel run the flood risk model for the parameter sets
# depending on the HPC capabilities, this loop might take several days or weeks to run
# it is recommended to run the loop in smaller groups and then merge the results as
# each run (row in the parameter sets matrix) is independent of other runs
foreach (i = run_start:run_end) %dopar% {
 print(i)
 haz_risk_run(i)
}

# for (i in run_start:run_end) haz_risk_run(i) # non-parallel runs
end<-proc.time()

print(end-start)
stopCluster(cl)

# model run end

# creating the model response table
list <- list.files('./OAT/Summary', pattern = '.csv')

model_response<-data.frame()
for (i in seq_along(list)) {
  print(i)
  data = read.csv(paste0('./OAT/Summary/', list[i]))
  model_response[i,(1:4)] = data[1,(2:5)]
}
model_response <- model_response[order(model_response$run.no.),]
write.csv(model_response,"OAT_model_response.csv")
save(model_response,file="./OAT_model_response.RData")
rm(list = ls())
