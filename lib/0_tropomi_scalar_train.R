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

#------Visualization---------
source('set_tropomi.R')
library(tmap)
library(rgdal)
library(dplyr)
boolean_ID25 <- raster(paste0(tropomiFinal_filepath, '/scalar_train_25.grd'))

data_t <- read.csv('../data/sensorTrainData_all.csv')
data_v <- read.csv('../data/sensorValidateData_all.csv')
data_p <- rbind(data_t, data_v) %>% mutate(trainBoolean=c(rep('training',nrow(data_t)),
                                                          rep('validation', nrow(data_v))))

adm <- readOGR('../data/visualization/NLD_adm/NLD_adm1.shp')
adm_DE <- readOGR('../data/visualization/DEU_adm/DEU_adm1.shp')
adm_BL <- readOGR('../data/visualization/BEL_adm/BEL_adm1.shp')

adm_all <- bind(adm, adm_BL, adm_DE)
adm_laea <- spTransform(adm_all, CRSobj = localProj)
adm_laea_c <- crop(adm_laea, boolean_ID25)

locations_sf = st_as_sf(data_p, coords = c("Longitude.laea","Latitude.laea"), crs=localProj)

tmap_mode('plot')
tm_shape(boolean_ID25)+
    tm_raster(palette=c('#42f572', '#f5f231'), style = "cat", 
              title = 'TROPOMI')+
    
    tm_shape(locations_sf) +
    tm_dots(col = c("trainBoolean"), 
            size = 0.1,
            title = 'sensor data') + 
    
    tm_shape(adm_laea_c) +
    tm_borders(col='black')+
    tm_scale_bar(text.size=1, text.color='white', position = c('center','top'))+
    tm_compass(text.size = 0.6, position = c('right','top'))+
    tm_layout(legend.title.size = 1.2, legend.text.size = 1, legend.text.color = 'black')

