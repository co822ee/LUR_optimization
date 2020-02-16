# Preprocess the TROPOMI data
#--------------------------------------
# The monthly average tropospheric VCDs were downloaded from the TEMIS website:
# http://www.temis.nl/airpollution/no2col/no2month_tropomi.php
# From Febuary 2018 to January 2019

library(stringr)
library(dplyr)
library(raster)
library(pbapply)

source('set_tropomi.R')
source('0_tropomi_clean_functions.R')
input_filepath <- '../data/raw_data/TROPOMI/'

#----------- clean & preprocess -----------
# Read the TROPOMI_TEMIS raw data
fileName_tropomi <- list.files(path = input_filepath, pattern=".asc")
t <- pblapply(paste0(input_filepath, fileName_tropomi), readLines)

# Clean the TROPOMI data 
t[[1]][1:5]   # Data information
ma <- pblapply(t, extractToMatrix)  # Non-defined pixels have values of -999
r <- pblapply(ma, matrixToRaster)   # Non-defined pixels have values of-9.99
pblapply(1:length(r), writeR, raster=r, fileName=fileName_tropomi, 
         filePath=tropomiRaster_filepath)  

# Calculate the annual average of tropomi data
# Assign undefined values as NAs so that they can be ignored when computing annual mean
rstack_na <- stack(pblapply(r, function(r){ r[r==-9.99] <- NA; return(r) }))
r_yrmean_na <- mean(rstack_na,na.rm=TRUE)

#----------- reprojection/crop -----------
#3) nearest neighbor resampling but restraining the spatial resolution as 12.5*12.5 km
rasterSample <- raster(ncol=ncol(r_yrmean_na), nrow=nrow(r_yrmean_na))
values(rasterSample) <- c(rep(1,n=ncol(r_yrmean_na)*nrow(r_yrmean_na)))
rasterSample_r <- projectRaster(rasterSample, predictor_map, 
                                crs=localProj)
rasterSample_r_aggregate <- aggregate(rasterSample_r,fact=500)
# aggregation let the extent change from extent     : -161867.6, 161867.6, -247830, 252660.6  (xmin, xmax, ymin, ymax)
#                                     to extent     : -161867.6, 163142.6, -259855.4, 252660.6  (xmin, xmax, ymin, ymax)
r_yrmean_na_12p5 <- projectRaster(from = r_yrmean_na, to = rasterSample_r_aggregate)
r_yrmean_na_12p5_ngb <- projectRaster(r_yrmean_na, rasterSample_r_aggregate, method='ngb')



# Create a raster map of tropomi ID 
r_yrmean_na_12p5_ID <- matrix(data = seq(1,ncell(r_yrmean_na_12p5)), 
                           nrow = nrow(r_yrmean_na_12p5), ncol = ncol(r_yrmean_na_12p5),
                           byrow = T) %>% raster()

extent(r_yrmean_na_12p5_ID)<- extent(r_yrmean_na_12p5)
crs(r_yrmean_na_12p5_ID) <- crs(r_yrmean_na_12p5)

#The ID raster map for the areaaverage in PCRaster: r_yrmean_na_ID_25
r_yrmean_na_ID_25 <- projectRaster(r_yrmean_na_12p5_ID, predictor_map, method='ngb', crs=localProj)

# "reproject" the tropomi data from 12.5km to 25m---------
# Use the ID raster map to "reproject" the tropomi data (r_yrmean_na_12p5)
# with same spatial extent as the predictor maps but with 12.5km resolution 
# Output raster map: r_yrmean_na_12p5_25_ngb.grd
r_yrmean_na_r_25 <- projectRaster(r_yrmean_na_12p5, predictor_map, method='ngb', crs=localProj)
r_yrmean_na_r_25                                          # 25meter using sampleRaster and then ngb

writeRaster(r_yrmean_na_12p5, filename=paste0(tropomiRaster_filepath,'/tropomi_laea12p5.grd'))
writeRaster(r_yrmean_na_ID_25,paste0(tropomiFinal_filepath, '/r_yrmean_na_12p5_25_ID.grd'))
writeRaster(r_yrmean_na_r_25, paste0(tropomiFinal_filepath, '/r_yrmean_na_12p5_25_ngb.grd'))



