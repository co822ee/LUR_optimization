
# Functions to clean the TROPOMI data and convert to raster maps: 

# Convert the raw data to a matrix form (12 matrices in a list)
# The function extractToMatrix is adapted from 
# https://stackoverflow.com/questions/22634805/read-ascii-grid-data-into-matrix-format?answertab=active#tab-top
extractToMatrix <- function(f){
    bins.lon <- as.numeric(str_match(f[3], "Longitudes *: *([0-9]+) bins")[2])
    bins.lat <- as.numeric(str_match(f[4], "Latitudes *: *([0-9]+) bins")[2])
    # number of characters that represent a value
    num.width <- 4
    
    # how many lines do we need to encode the longitude bins
    bins.lon.lines <- as.integer(bins.lon / (80/num.width))
    
    # where does the data start
    curr.lat.line <- 5
    curr.lat.bin <- 1
    
    m <- matrix(nrow=bins.lat, ncol=bins.lon+1)
    
    repeat {
        
        # get current latitude
        lat <- as.numeric(str_match(f[curr.lat.line], "lat=\ +([0-9\\.\\-]+)")[2])
        
        # show progress - not necessary
        cat(curr.lat.bin, lat); cat("\n")
        
        # get the values for the longitudes at current latitude
        vals <- paste(f[(curr.lat.line+1):(curr.lat.line+bins.lon.lines)], sep="", collapse="")
        
        # split them by 4 and assign to the proper entry
        m[curr.lat.bin, ] <- c(lat, as.numeric(lapply(seq(1, nchar(vals), 4), function(i) substr(vals, i, i+3))))
        
        curr.lat.bin <- curr.lat.bin + 1
        curr.lat.line <- curr.lat.line + bins.lon.lines + 1
        
        if (curr.lat.bin > bins.lat) { break }
        
    }
    
    m <- m[nrow(m):1, -1]     # Non-defined pixels have values of -999
    return(m)
}

# Convert from 12 matrices of monthly tropomi data to 12 raster maps
matrixToRaster <- function(m){
    # Tropospheric verticle colume density is in a unit of e15 molecules/cm2.
    # Non-defined values are -9.99.
    # The data of the matrix obtained from the function extractToMatrix covers the whole globe.
    r <- raster(m/100)       
    extent(r) <- c(-179.9375-0.125/2,179.9375+0.125/2,-89.9375-0.125/2,89.9375+0.125/2)
    projection(r)=crs('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84')
    plot(r)
    return(r)
}

# Write the 12 raster maps into .grd file 
# Write Raster maps which contain non-defined pixel values as -9.99
writeR <- function(i, raster, fileName, filePath){
    fileType <- ".grd"
    writeRaster(raster[[i]], filename = 
                    paste0(filePath,'/', gsub(".asc.gz", "",fileName[i]) , 
                           fileType),overwrite=T)
}