# Hosseini-Shakib_etal_2022_preprint

**Uncertainties surrounding flood hazard estimates is the primary driver of riverine flood risk projections**

Iman Hosseini-Shakib<sup>1\*</sup>, Sanjib Sharma<sup>1</sup>, Benjamin Seiyon Lee<sup>2</sup>, Vivek Anand Srikrishnan<sup>3</sup>, Robert Nicholas<sup>1,4</sup>, and Klaus Keller<sup>1,5</sup>

<sup>1 </sup> Earth and Environmental Systems Institute, The Pennsylvania State University, University Park, PA, USA <br />
<sup>2 </sup> Department of Statistics, George Mason University, Fairfax, VA, USA <br />
<sup>3 </sup> Department of Biological & Environmental Engineering, Cornell University, Ithaca, NY, USA <br />
<sup>4 </sup> Department of Meteorology and Atmospheric Science, The Pennsylvania State University, University Park, PA, USA <br />
<sup>5 </sup> Thayer School of Engineering, Dartmouth College, Hanover, NH, USA

\* corresponding author:  ishakib@gmail.com 

## Abstract
Flooding drives considerable risks. Designing strategies to manage these risks is complicated by the often large uncertainty surrounding flood-risk projections. Uncertainty surrounding flood risks can stem, for example, from choices regarding boundary conditions, model structures, and parameters. Dynamic interactions among hazard, exposure, and vulnerability can modulate the uncertainty surrounding flood risks. A quantitative understanding of which factors drive uncertainties surrounding flood hazards and risks can inform the design of mission-oriented research. Here characterize key uncertainties impacting flood-risk projections and perform a global sensitivity analysis to characterize the most important drivers of the uncertainties surrounding flood hazards and risks. We find that the flood risk model is sensitive to upstream discharge, river bed elevation, channel roughness and digital elevation model resolution. 

## Journal reference
Hosseini-Shakib, I., Sharma, S., Lee, B.S., Srikrishnan, V.A., Nicholas, R., & Keller, K. (2022). Uncertainties surrounding flood hazard estimates is the primary driver of riverine flood risk projections. _preprint_

## Data reference

### Input data
The 1/3 arcsec digital elevation model (DEM) tile for Selinsgrove,PA is downloaded from the USGS website at API: https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/TIFF/historical/n41w077/USGS_13_n41w077_20220429.tif <br />
The small size input data are stored in the "Inputs" folder and are as follows:
- "Isle of Que": shapefile of the Isle of Que in Selinsgrove
- "NLCD": Land use land cover 30m gridded data from the USGS National Land Cover Database (2016) clipped for Selinsgrove, PA
- "Rivers": shapefile of the Susquehanna River from Pennsylvania Spatial Data Access (https://www.pasda.psu.edu) clipped for the region
- "Roads": shapefile of the Roads from Pennsylvania Spatial Data Access (https://www.pasda.psu.edu) clipped for the region
- "Susquehanna_west_bank": shapefile of the west bank of Sussquehanna from Pennsylvania Spatial Data Access (https://www.pasda.psu.edu) clipped for the region
- "clip_area": a rectangular shapefile that covers Selinsgrove, PA used to clip DEMs
- "houses_for_sale": shapefile of the houses for sale in Selinsgrove obtained from zillow.com accessed in February 2020
- "Selinsgrove_shapefile": shapefile of Selinsgrove, PA from Pennsylvania Spatial Data Access (https://www.pasda.psu.edu)

## Contributing modeling software
| Model | Version | Platform |
|-------|---------|-----------------|
| R | 3.6.0 | x86_64-redhat-linux-gnu (64-bit) |
| LISFLOOD-FP | 6.0.4 | x86_64-redhat-linux-gnu (64-bit) |

R packages used in this study are as follows in alphabetical order:
"adaptMCMC", "data.table", "dataRetrieval", "DEoptim", "doParallel", "evd", "evir", "extRemes", "foreach", "geosphere", "GGally", "ggplot2", "graphics", "parallel", "plotrix", "raster", "RColorBrewer", "rgdal", "sensobol", "TruncatedDistributions".

## Reproduce my experiment
These scripts perform a coupled analysis to estimate the expected annual flood damages of 2,000 hypothetical houses in Selinsgrove, PA. The analysis is organized in four parts: (1) initialization of the study region and hypothetical houses; (2) a statistical analysis to sample the discharge uncertainty; (3) a hydraulic model (LISFLOOD-FP) to estimate the flood hazard; (4) an exposure-vulnerability model to estimate the flood risk.

We estimate the run time for this repository using 400 CPUs from the Pennsylvania State Unversity high-performance computation facilities to be approximately 3 weeks. If you do not have access to high-performance computation facilities and wish to reproduce our results and plots, you can use the files in the `pregenerated_run_results` to avoid running the precalibration (10,000 model runs), the Sobol global sensitivity analysis (76,000 model runs) and the Morris one-step-at-a-time sensitivity analysis (73 model runs).

Users need to clone the `Inputs`, `LISFLOOD`,`figures`, and `workflow` folders, then run the `main_script.R` code that sources the codes in the `workflow` and `figures` folders by the order. The exact roles of each piece of code and input files are described in detail as follows:

Workflow:
| Script Name | Description |
| --- | --- |
| `code_w00-packages.R` | Script to install the required R packages |
| `code_w01-DEMs_and_land_cover.R` | Script to create land use map and DEMs at different resolutins for Selinsgrove, PA |
| `code_w02-hypothetical_houses.R` | Script to create 2,000 hypothetical houses in Selinsgrove, PA |
| `code_w03-hypothetical_house_prices.R` | Script to estimate hypothetical house prices based on the exposure module |
| `code_w04-discharge_GEV_MLE.R` | Script to use frequentist maximum likelihood method to estimate GEV parameters for the annual maxima of discharge |
| `code_w05-MCMC_and_MLE_Bayes_Comparison.R` | Script to use the Metropolis-Hastings Markov Chain Monte Carlo method to quantify the uncertainty sorrounding the annual maxima of discharge |
| `code_w06-initial_ensemble_for_precalib.R` | Script to an initial ensemble of 10,000 rows for precalibration |
| `code_w07-initial_model_run.R` | Script to run the flood hazard model for 10,000 runs for precalibration |
| `code_w08-precalibration.R` | Script to perform precalibration |
| `code_w09-Sobol_GSA_ensemble.R` | Script to set up the 76,000 row ensemble used for global sensitivity analysis |
| `code_w10-Sobol_GSA_model_run.R` | Script to run flood risk model for the 76,000 row parameter set |
| `code_w11-Sobol_GSA_risk_hazard_indices.R` | Script to calculate Sobol sensitivity indices for hazard and risk parameters |
| `code_w12-radial_plot_tables_risk.R` | Script to set up the tables required for plotting the flood risk sensitivity results |
| `code_w13-radial_plot_tables_hazard.R` | Script to set up the tables required for plotting the flood hazard sensitivity results |
| `code_w14-OAT_ensemble.R` | Script to set up the ensemble of 73 rows for the Morris one-step-at-a-time sensitivity analysis |
| `code_w15-OAT_model_run.R` | Script to run the flood risk model for the Morris one-step-at-a-time sensitivity analysis |

The following scripts are the functions used by the codes in the `workflow` directory and are stored in `workflow/functions/`

Functions:
| Script Name | Description |
| --- | --- |
| `OAT_haz_risk_function.R` | Function to estimate average flood depth in m and total damage in USD for the Morris one-step-at-a-time analysis |
| `batchmeans.R` | Functions to calculate consistent batch means and imse estimators of Monte Carlo standard errors |
| `flood_extent_function.R` | Function to estimate flood extent and grid cell flood depth in m in Selinsgrove, PA used for precalibration |
| `haz_risk_function.R` | Function to estimate average flood depth in m and total damage in USD for the Sobol global sensitivity analysis method  |
| `sobol_functions.R` | Functions used in plotting Sobol sensitivity results for hazard and risk |

## Reproduce my figures
Use the scripts found in the `figures` directory to reproduce the figures used in this publication.

Figures:
| Script Name | Description |
| --- | --- |
| `code_f01-discharge_annual_maxima.R` | Script to plot the annual maxima of discharge for the USGS gauge of Susquehanna River at Sunbury |
| `code_f02-discharge_90percent_uncert_plot.R` | Script to plot the results of MCMC for upstream discharge |
| `code_f03-return_periods_90CI.R` | Script to plot uncertainty bounds of upstream discharge for different return periods |
| `code_f04-MCMC_pairs_plot.R` | Script to plot MCMC GEV parameters pairs |
| `code_f05-initial_parameters_pdf_plots.R` | Script to plot the pdfs of the initial parameter sets used for precalibration |
| `code_f06-initial_parameter_pairs_plot.R` | Script to plot initial parameters pairs used for precalibration |
| `code_f07-precalibrated_parameters_pdf_plots.R` | Script to plot pdfs of parameters used in the Sobol global sensitivity analysis |
| `code_f08-precalibrated_parameter_pairs_plot.R` | Script to plot the parameter sets pairs used in the Sobol global sensitivity analysis |
| `code_f09-model_response_plots.R` | Script to plot flood hazard and risk results used in the Sobol global sensitivity analysis |
| `code_f10-radial_plot_hazard.R` | Script to plot the results of flood hazard global sensitivity analysis |
| `code_f11-radial_plot_risk.R` | Script to plot the results of flood risk global sensitivity analysis |
| `code_f12-OAT_sensitivity_plot.R` | Script to plot the results of the Morris one-step-at-a-time sensitivity analysis |
