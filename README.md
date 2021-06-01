# Mitigating Houston Heat using Spatial Econometrics  

## Project Description 
The purpose of this project is to examine extreme heat locations in Houston and understand how green mitigation strategies can reduce the urban heat effect. 

## Usage Instructions 
### Installation 
R and Rstudio are required to read the scripts associated with this project. R can be downloaded from an internet browser to a local computer, and RStudio can be downloaded as well to edit and run all of the files and complete everything associated with this project.

### Version
R Version 3.1.0 or newer is needed for this project. 

### Dependencies 
The following R packages and their requirements are required in this project:
tidyverse, config, lubridate, caret, fastDummies, janitor, sf, spdep, spatialreg, spNNGP, scales

### Configuration
In config.yml, set ```working_path``` as the absolute path of the project folder.

### Data 
All the data for this project can be found on Box in ```Data for Github``` folder.\
Download spatial_cleaned.csv, SN_to_Rects_250m.csv, rectangles_250m.shx, rectangles_250m.shp, rectangles_250m.sbx, rectangles_250m.sbn, rectangles_250m.prj, rectangles_250m.dbf, rectangles_250m.cpg from Box and put all these files in the ```data``` folder.

### Main Execution File
The ```Main.Rmd``` executes the data science pipeline. Only need to run this file to get the predicted output of a mitigation strategy on a super neighborhood.\
After loading and fitting the models, a mitigation strategy can be flexibily defined and applied on a selected super neighborhood. A data frame with temperature after mitigation will be returned. \
Results from Gulfton, Westwood, Greater Uptown, Eldridge/West Oaks, and Braeburn with a predefined mitigation strategy are already included in ```output``` folder. Generating output for new mitigation strategies or neighborhoods takes around 1 hour.

### Usage Steps
1. Download or clone the repository.
2. Set up R and Rstudio.
3. Set ```working_path``` accordingly as described in Configuration.
4. Include all necessary files in ```data``` folder.
5. Open ```Heat_Sp21.Rproj``` and run the main execution file  ```Main.Rmd```.

## Script Descriptions
### Data Loading
The ```scripts/00_Util``` contains the ```Load_Data.R``` script, which is utilized by the main file to load all of the grouped grid data. The main file allows for the data to be loaded in different potential groupings.

### Wrangling 
The ```scripts/01_Wrangling``` folder contains scripts three scripts that clean the original data and merge all datasets into either a spatial or temporal dataset. The purpose of wrangling is to have the data in the most useful structure for exploration and modeling. 

* 311_dataWrangling: Cleans the 311 fire related call data to be merged into the spatial dataset.  
* Spatial_Wrangling: Cleans the spatial data and merges all HEAT and City of Houston data into a single dataset.  
* Temporal_Wrangling: Cleans the temporal NOAA data. 

### Exploration
The ```scripts/02_Exploration``` folder contains a script for each of the two datasets used in the project. These scripts explore key features in the data and seek to identify patterns and relationships that help with modeling. 

* All spatial exploration is completed in ArcGIS Pro.  
* Temporal_Exploration: Explores and visualizes the trends in Houston temperature since 2016. 

### Modeling 
The ```scripts/03_Modeling``` folder contains scripts detailing the models used to highlight the relationship between heat and Houston's composition.

* Spatial_Modeling: Performs OLS Regression, Spatial Lag, Spatial Error, and Gaussian Process Spatial Regression on the spatial dataset to identify the relationship between heat, landcover, and neighborhood population and predict effects of green mitigation strategies on selected socially vulnerable super neighborhoods.
* Temporal_Modeling: Forecasts the trend of temperature in Houston over the next ten years.

### More information about this project can be found in the written reports.

| `air` | `contrast` |
| --- | --- | --- |
| ![air skin](https://github.com/sarvade/portfolio/tree/master/images/figure3.png) | ![contrast skin](https://github.com/sarvade/portfolio/tree/master/images/figure9.png) | 

| `air` | `contrast` |
| --- | --- | --- |
| ![air skin](https://github.com/sarvade/portfolio/tree/master/images/figure10.png) | ![contrast skin](https://github.com/sarvade/portfolio/tree/master/images/figure11.png) | 





