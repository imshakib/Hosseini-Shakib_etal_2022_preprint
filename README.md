# Sobol Analysis
These scripts perform a coupled analysis to estimate the expected annual flood damages of 2,000 hypothetical houses in Selinsgrove, PA. The analysis is organized in four parts: (1) initialization of the study region and hypothetical houses; (2) a statistical analysis to sample the discharge uncertainty; (3) a hydraulic model (LISFLOOD-FP) to estimate the flood hazard; (4) an exposure-vulnerability model to estimate the flood risk. 

Users need to clone the R scripts and the “Inputs” folder, then run the code from 01 to 12 by the order. The exact roles of each piece of code and input files are described in detail below.

Required input files: 
Selinsgrove’s boundary shapefile (/Inputs/clip_area/clip_area.shp)
Selinsgrove’s clipped land use and land cover map (/Inputs/NLCD/NLCD2016_clip)
Land use grid (/Inputs/lulc.asc)
Roads shapefile (/Inputs/Roads/roads.shp)
Susquehanna River shapefile (/Inputs/Rivers/rivers.shp)
Selinsgrove’s boundaries shapefile (/Inputs/selinsgrove_shapefile/Selinsgrove.shp)
Susquehanna west river bank shapefile (/Inputs/Susquehanna_west_bank/west_bank.shp)
House price shapefile (/Inputs/houses_for_sale/houses_for_sale.shp)
*lisflood.exe as the application file that runs the LISFLOOD-FP model

01-DEMs_and_land_cover.R
This script reads Selinsgrove’s boundary shapefile and clipped land shapefile to generate three gridded files representing three digital elevation model (DEM) resolutions and another file representing the land use and land cover.

02-hypothetical_houses.R
This script reads the land use land cover file, the shapefiles of roads and rivers. Then it extracts the urban regions and randomly samples 2,000 hypothetical houses within the urban region. 

03-hypothetical_house_prices.R
This script reads the river bank shapefile and the house price shapefile. Then it uses a linear regression to estimate the unit house price based on the distance to the river and the elevation above the river. The prices of the hypothetical houses are determined by the best estimate of this regression model.

These three scripts form the initialization.

04-discharge_GEV_MLE.R
This script downloads the historical annual maximum flood discharge data, and uses a Generalized Extreme Value (GEV) model to fit the data. The maximum likelihood GEV parameter estimates are saved.

05-Estimate_MCMC.R
This script quantifies the uncertainty of GEV parameters by Markov Chain Monte Carlo (MCMC) method. It saves the MCMC chains of the parameters.

06-Return_Periods.R
This script estimates the discharge of a certain return level. It can compare the flood level with and without considering the GEV parameter uncertainty. In this study the estimated 100-year return level discharges based on MCMC results are saved.

These three scripts form the statistical analysis.

07-Sensobol_indices.R
This script generates all the input parameter samples of the LISFLOOD-FP model, and then runs the Sobol’ sensitivity analysis. The input parameters are discharge (sampled by MCMC analysis), river depth, river width, floodplain roughness, river channel roughness, and DEM resolution. This script then estimates the house damages based on house vulnerability and exposure. The LISFLOOD-FP model can estimate the grid-level flood depth at the hypothetical houses, which is the flood hazard. Multiplying hazard by vulnerability and exposure gives the risk. The Sobol’ analysis is conducted under both risk space and hazard space.

08-radial_plot_tables_risk.R
09-radial_plot_tables_hazard.R
These scripts organize the outputs from Sobol’ analysis to generate a table to make plots. One is in risk space and the other is in hazard space.

10-radial_plot_risk.R
11-radial_plot_hazard.R
These scripts plot a radial plot to visualize the Sobol’ analysis outputs. One is in risk space and the other is in hazard space.

12-prior_and_response_pdf_plot.R
This script plots the probability density distribution of the input parameters.

haz_risk_function.R
This script runs the LISFLOOD model and is called in script 07.

sobol_functions.R
This script contains some functions that test the significance of Sobol’ analysis outputs. 
