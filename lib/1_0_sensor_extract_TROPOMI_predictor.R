# 2019/10/24
#------------------------------------------
# Extract the tropomi value
# Extract the predictor values
# Input data: NO2_data.csv (The NO2 monitoring data, including site locations)
# output data: data_laea_new_correctTropomi.csv 
#              (The site locations of the monitoring data are in laea projection)
#------------------------------------------
library(dplyr)
library(raster)
library(gtools)
library(pbapply)
library(rgdal)

# Input
NO2p <- read.csv('../data/NO2_data.csv')
tropomi_ngb_25 <- raster("../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ngb")
predictor_map_path <- '../data/normalize_area'
# Output
output_csv <- '../data/data_laea_new_correctTropomi.csv'

# Setting:
# original projection: laea
lon=5.616667
lat=52.083333
localProj <- crs(paste0(' +proj=laea +lon_0=', lon, ' +lat_0=', lat, ' +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs'))

#------------- Extract the TROPOMI values ----------------
NO2p <- NO2p[!duplicated(NO2p$AirQualityStationNatCode),]
coor <- NO2p %>% dplyr::select('Longitude','Latitude','AirQualityStationNatCode')

coordinates(coor) <- ~Longitude+Latitude
crs(coor) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

coor_r <- spTransform(coor, localProj)
coor_r_d <- as.data.frame(coor_r)

tropomi_no2 <- raster::extract(tropomi_ngb_25,coor_r,method='simple')
data_all <- cbind(NO2p, tropomi=tropomi_no2)

#------------ Extract the predictor values -------------
fileName_map= list.files(path=predictor_map_path, pattern=".grd")
# Sort the file names in the order of buffer sizes (from small to large)
fileName_map <- mixedsort(sort(fileName_map))
# Read the raster maps
readMap <- pbsapply(fileName_map, raster)
readMap <- pbsapply(readMap, function(r){ crs(r) <- localProj; return(r)})
# Transform the coordinates from the projected coordinate system (EPSG:4979)
# into the geographic coordinate system (laea)
coor_r <- spTransform(coor, localProj)
coor_r_d <- as.data.frame(coor_r)
data_all_laea <- inner_join(coor_r_d, data_all, by="AirQualityStationNatCode") %>% 
    rename(Longitude.laea=Longitude.x, Longitude.wgs84=Longitude.y,
           Latitude.laea=Latitude.x, Latitude.wgs84=Latitude.y)
val <- pbsapply(readMap, raster::extract, y=coor_r)
val <- as.data.frame(val)
names(val)
names(val) <- pbsapply(names(val), sub, pattern='.grd', replacement='')
data_all_laea_pred <- cbind(data_all_laea, val)
setwd(dirname(getActiveDocumentContext()$path))
write.csv(data_all_laea_pred, output_csv, row.names = F)
