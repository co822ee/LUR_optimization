
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

scenario <- c('frontier', 'onlySensor', 'onlyTropomi')
folder_scenario <- c('all_frontierTrainAll_500', 'all_onlySensorTrainAll_500', 'all_onlyTropomiTrainAll_500')

for(i in 1:length(scenario)){
    f_name <- list.files(path = paste0('../data/GLUE/', folder_scenario[i]), 
                         pattern = '.map')
    lur <- lapply(paste0('../data/GLUE/', folder_scenario[i], '/',f_name),
                  raster, crs=localProj)
    lur_s <- do.call(stack, lur)
    # Reproject the shp data
    adm_laea <- spTransform(adm_all, CRSobj = localProj)
    adm_laea_c <- crop(adm_laea, lur[[1]])
    
    #-------------------present----------------
    tmap_mode("plot")
    # industry_5000_t <- projectRaster(industry_5000, res=12000, crs=localProj)
    
    lurMap <- tm_shape(lur_s)+
        tm_raster(palette = matlab.like2(20), style = "cont")+
        tm_shape(adm_laea_c) +
        tm_borders(col='black')+
        tm_layout(legend.title.size = 1.2, legend.text.size = 1, 
                  legend.text.color = 'white', 
                  title.color = 'white')
    
    # tmap_save(road_M, filename = 'road_M345_5000.tiff', dpi=600, height=6, width=4, units='in')
    tmap_save(lurMap, filename = paste0('../graphs/', scenario[i], 
                                        '_uncertainty_regional.tiff'), 
              dpi=600, height=5.5, width=6, units='in')
}

#------
plot(lur_s, col=matlab.like2(80))

library(quickPlot)
Plot(lur_s, col=matlab.like2(80))
#------
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

