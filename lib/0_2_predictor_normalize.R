#---------------------------------------------------------------------------
# 2019/10/19
# The predictor variables are normalized by the corresponding buffer radius.
#---------------------------------------------------------------------------
library(gtools)
library(pbapply)
library(raster)
library(dplyr)

input_folder <- "../data/predictor_withoutMV/"
input_merge_folder <- "../data/predictor_withouMV/road_merge_laea/"
output_folder <- "../data/predictor_normalize_area/"

# Raster options for speeding up the computation
# rasterOptions(chunksize = 5e+15)
# rasterOptions(maxmemory = 1e+18)
# rasterOptions(tolerance=0.5)
# rasterOptions(memfrac=0.8)
# rasterOptions()
# memory.limit(TRUE)

# write the output maps in the normalize_area folder
writeRaster_name <- function(r){
    writeRaster(r, filename = paste0(output_folder, 
                                     names(r) %>% sub(pattern = '.map',replacement = '',x = .), 
                                     ".grd"))
    print('Finish writing the output maps.')
    
}
#------------- normalize all the laea predictor maps ----------
fileName_map= list.files(pattern=".map", path = input_folder)
# exclude the .xml files, which also contain the pattern of ".map"
fileName_map <- fileName_map[grepl("^(?=.*map)(?!.*xml)(?!.*clone)", fileName_map, perl=TRUE)]
# sort the file names in the order of buffer sizes (from small to large)
fileName_map <- mixedsort(sort(fileName_map))
fileName_path <- paste0(input_folder, fileName_map)
# read the raster maps
readMap <- pbsapply(fileName_path, raster::raster)

bufferSize <- c(25,50,100,300,500,800,1000,3000,5000)
bufferSize <- rep(bufferSize, length(readMap)/length(bufferSize))
laeaStack <- readMap %>% stack()
names(laeaStack) <- fileName_map

laeaStack_norm <- laeaStack/bufferSize

un <- unstack(laeaStack_norm)
pblapply(un, FUN = writeRaster_name)

#------ normalize the merged road maps (laea) --------
fileName_m= list.files(pattern=".grd", path = input_merge_folder)
fileName_m <- fileName_m[grepl("^(?=.*grd)(?!.*xml)", fileName_m, perl=TRUE)]
# Sort the file names in the order of buffer sizes (from small to large)
fileName_m <- mixedsort(sort(fileName_m))
fileName_path_m <- paste0(input_merge_folder, fileName_m)
# Read the raster maps
readMap_m <- pbsapply(fileName_path_m, raster)

bufferSize <- c(25,50,100,300,500,800,1000,3000,5000)
bufferSize <- rep(bufferSize, length(readMap_m)/length(bufferSize))
laeaStack_m <- readMap_m %>% stack()
names(laeaStack_m) <- fileName_m %>% sub(pattern = '.grd',replacement = '',x = .)

laeaStack_m_norm <- laeaStack_m/bufferSize
un_m <- unstack(laeaStack_m_norm)
pblapply(un_m, FUN = writeRaster_name)
