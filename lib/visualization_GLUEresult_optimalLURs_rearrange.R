
library(rgdal)
library(tmap)
library(colorRamps)
library(raster)

lon=5.616667
lat=52.083333
# original projection: laea
localProj <- crs(paste0(' +proj=laea +lon_0=', lon, ' +lat_0=', lat, ' +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs'))


# The data of the administrative area  was downloaded through DIVA-GIS
# http://www.diva-gis.org/datadown
# Nice tutorial for plotting spatial data
# https://nceas.github.io/oss-lessons/spatial-data-gis-law/3-mon-intro-gis-in-r.html
adm <- readOGR('../data/visualization/NLD_adm/NLD_adm1.shp')
adm_DE <- readOGR('../data/visualization/DEU_adm/DEU_adm1.shp')
adm_BL <- readOGR('../data/visualization/BEL_adm/BEL_adm1.shp')

# Merge the polygon (with bind)
# Union function in raster package is for combining two overlapping polygons
adm_all <- bind(adm, adm_BL, adm_DE)

obs <- c('lur.map', 'lurT.map')
breaks <- list(seq(10,60,length.out = 6), seq(0,20,length.out = 6))

# surface level concentrations (ug/m^3)
for(i in 1:length(obs)){
  
  frontier <- raster(paste0('../data/visualization/all_frontierTrainAll_500/', obs[i]), 
                     crs=localProj)
  onlySensor <- raster(paste0('../data/visualization/all_onlySensorTrainAll_500/', obs[i]), 
                       crs=localProj)
  onlyTropomi <- raster(paste0('../data/visualization/all_onlyTropomiTrainAll_500/', obs[i]), 
                        crs=localProj)
  
  # Reproject the shp data
  adm_laea <- spTransform(adm_all, CRSobj = localProj)
  adm_laea_c <- crop(adm_laea, frontier)
  
  #-------------------present----------------
  tmap_mode("plot")
  # industry_5000_t <- projectRaster(industry_5000, res=12000, crs=localProj)
  
  frontierMap <- tm_shape(frontier)+
    tm_raster(palette = matlab.like2(20), style = "cont", title = '', breaks=breaks[[i]])+
    tm_shape(adm_laea_c) +
    tm_borders(col='black')+
    tm_layout(legend.title.size = 1.2, legend.text.size = 1, legend.text.color = 'white', 
              title = '(a) frontier',
              title.color = 'white')
  
  onlySensorMap <- tm_shape(onlySensor)+
      tm_raster(palette = matlab.like2(20), style = "cont", title = '', breaks=breaks[[i]])+
      tm_shape(adm_laea_c) +
      tm_borders(col='black')+
      tm_layout(legend.title.size = 1.2, legend.text.size = 1, legend.text.color = 'white', 
                title = '(b) onlySensor',
                title.color = 'white')
  
  onlyTropomiMap <- tm_shape(onlyTropomi)+
    tm_raster(palette = matlab.like2(20), style = "cont", title = '', breaks=breaks[[i]])+
    tm_shape(adm_laea_c) +
    tm_borders(col='black')+
    tm_scale_bar(text.size=1, text.color='white', position = c('center','top'))+
    tm_compass(text.size = 0.6, position = c('right','top'), text.color = c('white', 'black')[i])+
    tm_layout(legend.title.size = 1.2, legend.text.size = 1, 
              attr.color = 'white',  
              title = '(c) onlyTropomi',
              title.color = 'white')
  
  # tmap_save(road_M, filename = 'road_M345_5000.tiff', dpi=600, height=6, width=4, units='in')
  mergeMap <- tmap_arrange(frontierMap, onlySensorMap, onlyTropomiMap, nrow=1, 
                           outer.margins=0.01)
  tmap_save(mergeMap, filename = paste0('../graphs/', obs[i], '_optimalLURs.tiff'), 
            dpi=600, height=5, width=10, units='in')
}

tropomi <- raster('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ngb.map')

tropomi_map <- tm_shape(tropomi)+
  tm_raster(palette = matlab.like2(20), style = "cont", title = '', breaks=seq(0,20,length.out = 6))+
  tm_shape(adm_laea_c) +
  tm_borders(col='black')+
  tm_scale_bar(text.size=1, text.color='black', position = c('center','bottom'))+
  tm_compass(text.size = 0.6, position = c('right','bottom'))+
  tm_layout(legend.title.size = 1.2, legend.text.size = 1, legend.text.color = 'white',  
            main.title = 'TROPOMI VCDs (1e15 molecules/cm^2)', main.title.size = 0.85,
            attr.outside = T)

tmap_save(tropomi_map, filename ='../graphs/tropomi.tiff', dpi=600, height=6, width=3, units='in')



#--------------explanatory--

lur <- raster('../data/visualization/all_onlySensorTrainAll_500/lur.map', crs=localProj)
lur_tropomi <- raster('../data/visualization/all_onlySensorTrainAll_500/lurT.map', crs=localProj)
lur
lur_tropomi

lur <- raster('../data/visualization/all_frontierTrainAll_500/lur.map', crs=localProj)
lur_tropomi <- raster('../data/visualization/all_frontierTrainAll_500/lurT.map', crs=localProj)

lur
lur_tropomi

lur <- raster('../data/visualization/all_onlyTropomiTrainAll_500//lur.map', crs=localProj)
lur_tropomi <- raster('../data/visualization/all_onlyTropomiTrainAll_500/lurT.map', crs=localProj)
lur
lur_tropomi

