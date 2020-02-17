# Create a boolean map of validation for the whole study area
source('set_tropomi.R')

r_yrmean_na_12p5 <- raster(paste0(tropomiRaster_filepath,'/tropomi_laea12p5.grd'))

set.seed(22)
cellID <- sample(1:ncell(r_yrmean_na_12p5), ncell(r_yrmean_na_12p5)*0.6)
cellID <- cellID[order(cellID)]

m_id <- matrix(data = rep(0,ncell(r_yrmean_na_12p5)), 
               nrow = nrow(r_yrmean_na_12p5), ncol = ncol(r_yrmean_na_12p5),
               byrow = T)
m_id[cellID]=1
# View(m_id)
boolean_ID12p5 <- raster(m_id)
extent(boolean_ID12p5)<- extent(r_yrmean_na_12p5)
crs(boolean_ID12p5) <- crs(r_yrmean_na_12p5)

boolean_ID25 <- projectRaster(boolean_ID12p5, predictor_map, method='ngb', 
                              crs=localProj)
# plot(boolean_ID12p5)
# plot(boolean_ID25)
writeRaster(boolean_ID25, paste0(tropomiFinal_filepath, "/scalar_train_25.grd"))

