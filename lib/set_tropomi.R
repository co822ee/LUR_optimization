library(raster)

# Raw data
predictor_map <- raster("../data/raw_data/predictor_map/road_class_5_800.map")
# Intermediate data for processing
tropomiRaster_filepath <- '../data/TROPOMI_temis_laea/raster'   
# Final data for the later modeling in PCRaster
tropomiFinal_filepath <- '../data/TROPOMI_temis_laea'    

if(!dir.exists(tropomiRaster_filepath)){
    dir.create(tropomiRaster_filepath)
}

# Setting:
# original projection: laea
lon=5.616667
lat=52.083333
localProj <- crs(paste0(' +proj=laea +lon_0=', lon, ' +lat_0=', lat, 
                        ' +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs'))

