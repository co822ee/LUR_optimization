#--------------------------------
# 2019/10/19
# Merge road_cass_3, 4, and 5
#--------------------------------
library(raster)
library(gtools)
library(pbapply)



input_folder <- "../data/predictor_withoutMV/"
output_folder <- "../data/predictor_withoutMV/road_merge_laea/"

# Raster options for speeding up the computation
# rasterOptions(chunksize = 5e+15)
# rasterOptions(maxmemory = 1e+15)
# rasterOptions(memfrac=0.9)
# rasterOptions(tolerance=0.6)
# rasterOptions()

if(!dir.exists(input_folder)){
    dir.create(input_folder)
}
if(!dir.exists(output_folder)){
    dir.create(output_folder)
}


readMapNames <- function(pattern){
    fileName_map= list.files(path = input_folder, pattern=pattern)
    # Exclude the .xml files, which also contain the pattern of ".map"
    fileName_map <- fileName_map[grepl("^(?=.*map)(?!.*xml)(?!.*clone)", 
                                       fileName_map, perl=TRUE)]
    # Sort the file names in the order of buffer sizes (from small to large)
    fileName_map <- mixedsort(sort(fileName_map))
    filepath <- paste0(input_folder, fileName_map)
    return(filepath)
}

writeRaster_name <- function(r){
    # writeRaster(r, filename = paste0("road_merge_laea/", names(r), ".tif"))
    writeRaster(r, filename = paste0(output_folder, names(r), ".grd"))
}

# Read the road maps' path
filepath_road3 <- readMapNames('road_class_3')
filepath_road4 <- readMapNames('road_class_4')
filepath_road5 <- readMapNames('road_class_5')
# Read the road raster maps
road_map3 <- pblapply(filepath_road3, raster)
road_map4 <- pblapply(filepath_road4, raster)
road_map5 <- pblapply(filepath_road5, raster)
# Stack the road maps 
road_stack3 <- stack(road_map3)
road_stack4 <- stack(road_map4)
road_stack5 <- stack(road_map5)
road_stack3[[1]]
# Merge the roads maps with same buffer sizes
road_merge345 <- overlay(road_stack3, road_stack4, road_stack5,fun=sum)
names(road_merge345) <- names(road_stack3) %>% 
    pbsapply(FUN=sub, pattern="_3_", replacement="_M345_")
# Unstack the merged RasterStack and save all of them
un <- unstack(road_merge345)

pblapply(un, FUN = writeRaster_name)


