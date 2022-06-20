# Hosseini-Shakib_etal_2022_Nat_Clim_Chang

**Uncertainties surrounding flood hazard estimates is the primary driver of riverine flood risk projections**

Iman Hosseini-Shakib<sup>1\*</sup>, Sanjib Sharma<sup>1</sup>, Benjamin Seiyon Lee<sup>2</sup>, Vivek Anand Srikrishnan<sup>3</sup>, Robert Nicholas<sup>1,4</sup>, and Klaus Keller<sup>1,5</sup>

<sup>1 </sup> Earth and Environmental Systems Institute, The Pennsylvania State University, University Park, PA, USA <br />
<sup>2 </sup> Department of Statistics, George Mason University, Fairfax, VA, USA <br />
<sup>3 </sup> Department of Biological & Environmental Engineering, Cornell University, Ithaca, NY, USA <br />
<sup>4 </sup> Department of Meteorology and Atmospheric Science, The Pennsylvania State University, University Park, PA, USA <br />
<sup>5 </sup> Thayer School of Engineering, Dartmouth College, Hanover, NH, USA

\* corresponding author:  ishakib@gmail.com 

## Abstract
Flooding drives considerable risks. Designing strategies to manage these risks is complicated by the often large uncertainty surrounding flood-risk projections. Uncertainty surrounding flood risks can stem, for example, from choices regarding boundary conditions, model structures, and parameters. Dynamic interactions among hazard, exposure, and vulnerability can modulate the uncertainty surrounding flood risks. A quantitative understanding of which factors drive uncertainties surrounding flood hazards and risks can inform the design of mission-oriented research. Here characterize key uncertainties impacting flood-risk projections and perfor a global sensitivity analysis to characterize the most important drivers of the uncertainties surrounding flood hazards and risks. We find that the flood risk model is sensitive to upstream discharge, river bed elevation, channel roughness and digital elevation model resolution. 

## Journal reference
Hosseini-Shakib, I., Sharma, S., Lee, B.S., Srikrishnan, V.A., Nicholas, R., & Keller, K. (2022). Uncertainties surrounding flood hazard estimates is the primary driver of riverine flood risk projections. _Nature Climate Change_, Under review

## Data reference

### Input data
The 1/3 arcsec digital elevation model (DEM) tile for Selinsgrove,PA is downloaded from the USGS website at API: https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/TIFF/historical/n41w077/USGS_13_n41w077_20220429.tif
The small size input data are stored in the "Inputs" folder and are as follows:
- "Isle of Que": shapefile of the Isle of Que in Selinsgrove
- "NLCD": Land use land cover 30m gridded data from the USGS National Land Cover Database (2016) clipped for Selinsgrove, PA
- "Rivers": shapefile of the Susquehanna River from Pennsylvania Spatial Data Access (https://www.pasda.psu.edu) clipped for the region
- "Roads": shapefile of the Roads from Pennsylvania Spatial Data Access (https://www.pasda.psu.edu) clipped for the region
- "Susquehanna_west_bank": shapefile of the west bank of Sussquehanna from Pennsylvania Spatial Data Access (https://www.pasda.psu.edu) clipped for the region
- "clip_area": a rectangular shapefile that covers Selinsgrove, PA used to clip DEMs
- "houses_for_sale": shapefile of the houses for sale in Selinsgrove obtained from Zillow
- "Selinsgrove_shapefile": shapefile of Selinsgrove, PA from Pennsylvania Spatial Data Access (https://www.pasda.psu.edu)

## Contributing modeling software
| Model | Version | Platform |
|-------|---------|-----------------|
| R | 3.6.0 | x86_64-redhat-linux-gnu (64-bit) |
| LISFLOOD-FP | 6.0.4 | x86_64-redhat-linux-gnu (64-bit) |

R packages used in this study are as follows in alphabetical order:
"adaptMCMC", "data.table", "dataRetrieval", "DEoptim", "doParallel", "evd", "evir", "extRemes", "foreach", "geosphere", "GGally", "ggplot2", "graphics", "parallel", "plotrix", "raster", "RColorBrewer", "rgdal", "sensobol", "TruncatedDistributions"

## Reproduce my experiment
These scripts perform a coupled analysis to estimate the expected annual flood damages of 2,000 hypothetical houses in Selinsgrove, PA. The analysis is organized in four parts: (1) initialization of the study region and hypothetical houses; (2) a statistical analysis to sample the discharge uncertainty; (3) a hydraulic model (LISFLOOD-FP) to estimate the flood hazard; (4) an exposure-vulnerability model to estimate the flood risk.

Users need to clone the R scripts and the “Inputs” folder, then run the "main_script.R" code that sources the codes in the "workflow" and "figures" folders by the order. The exact roles of each piece of code and input files are described in detail as follows:

Workflow:
| Script Name | Description |
| --- | --- |
| `code_w00-packages.R` | Script to run the first part of my experiment |
| `code_w01-DEMs_and_land_cover.R` | Script to run the last part of my experiment |
| `code_w02-hypothetical_houses.R` | Script to run the last part of my experiment |
| `code_w03-hypothetical_house_prices.R` | Script to run the last part of my experiment |
| `code_w04-discharge_GEV_MLE.R` | Script to run the last part of my experiment |
| `code_w05-MCMC_and_MLE_Bayes_Comparison.R` | Script to run the last part of my experiment |
| `code_w06-Initial_ensemble_for_precalib.R` | Script to run the last part of my experiment |
| `code_w07-Initial_GSA_model_run.R` | Script to run the last part of my experiment |
| `code_w08-precalibration.R` | Script to run the last part of my experiment |
| `code_w09-Sobol_GSA_ensemble.R` | Script to run the last part of my experiment |
| `code_w10-Sobol_GSA_model_run.R` | Script to run the last part of my experiment |
| `code_w11-Sobol_GSA_risk_hazard_indices.R` | Script to run the last part of my experiment |
| `code_w12-radial_plot_tables_risk.R` | Script to run the last part of my experiment |
| `code_w13-radial_plot_tables_hazard.R` | Script to run the last part of my experiment |
| `code_w14-OAT_ensemble.R` | Script to run the last part of my experiment |
| `code_w15-OAT_model_run.R` | Script to run the last part of my experiment |

4. Download and unzip the output data from my experiment [Output data](#output-data)
5. Run the following scripts in the `workflow` directory to compare my outputs to those from the publication

| Script Name | Description | How to Run |
| --- | --- | --- |
| `compare.py` | Script to compare my outputs to the original | `python3 compare.py --orig /path/to/original/data.csv --new /path/to/new/data.csv` |

## Reproduce my figures
Use the scripts found in the `figures` directory to reproduce the figures used in this publication.

| Script Name | Description | How to Run |
| --- | --- | --- |
| `generate_figures.py` | Script to generate my figures | `python3 generate_figures.py -i /path/to/inputs -o /path/to/outuptdir` |
