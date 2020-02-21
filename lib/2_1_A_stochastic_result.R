# This script visualizes the stochastic results from the 
# A_LURmodel_PF_improve_validation_stochastic_final.py
# Output file: objF_stochastic12.csv
#              frontierTrainAll_500.csv
#              onlySensorTrainAll_500.csv
#              onlyTropomiTrainAll_500.csv

library(dplyr)
library(pbapply)
library(gtools)

inputFilePath <- "../data/GLUE/"
target_b <- 8          #5
target_p <- 8          #10
nrOfTargetConvPoints <- 500   #1% of the sample points
#----------1. Combine all the simulation results----------
readFile <- function(runtime){
    filePath <- paste0(inputFilePath,"stochastic_0", runtime)
    txtFileName <- list.files(path=filePath,
                              pattern=".txt")
    txtFileName <- txtFileName[grepl("^(?=.*stochastic_)", txtFileName, perl=TRUE)]
    txtFileName <- mixedsort(sort(txtFileName))   #mixedsort in gtools package
    txt <- pblapply(paste0(filePath, '/', txtFileName), read.table, header=TRUE)
    rmse <-  do.call("rbind", txt)
    rmse_b <- rmse %>% rename(rmse_b=rmse)
    rmse_b
}
rmse_b1 <- readFile(1)
rmse_b2 <- readFile(2)

rmse_b <- rbind(rmse_b1,rmse_b2)

#-------2. Calculate the RMSE of the sensor data ------------
data_all <- read.csv("../data/sensorTrainData_all.csv")
lur  <- read.csv("../data/lur_lasso_norm_newData_1.csv", header = T)
y_est <- "AQValue"
lur_p <- rmse_b %>% select(-h, -rmse_b)

x <- data_all %>% select(lur$predName %>% as.character()) 
names(x) <- c("x1", "x2","x3")
data_p <- data_all %>% dplyr::select(y_est) %>% cbind(x)
BF_p <- merge(data_p, lur_p, all=T)

rmse_p <- BF_p %>% 
    mutate(y_bar=c+a*x1+b*x2+d*x3) %>% 
    mutate(dev_2=(AQValue-y_bar)^2) %>% 
    group_by(a,b,d,c) %>%                        
    summarise(rmse_p=sqrt(mean(dev_2)))     

#-------- Combine the two RMSE ---------------
objF_1 <- base::merge(rmse_p, rmse_b,by=c("a","b","d","c"))
objF_1 <- objF_1 %>% mutate(ID=1:nrow(objF_1))
target <- objF_1 %>% filter(rmse_b<target_b&rmse_p<target_p)

write.csv(objF_1, '../data/objF_stochastic12.csv', row.names = F)

#------------ 3. Three calibration settings ----------------
# 1) For considering both point and block
convObj <- objF_1[chull(objF_1$rmse_p, objF_1$rmse_b),]
targetConvObj <- convObj %>% filter(rmse_b<target_b&rmse_p<target_p)
temp_obj <- objF_1[which(!(objF_1$ID %in% convObj$ID)),]
while(nrow(targetConvObj)<nrOfTargetConvPoints){
    # All points on the boundary of the scatterplots
    temp_convObj <- temp_obj[chull(temp_obj$rmse_p, temp_obj$rmse_b),]  # grDevices package
    # All points on the boundary of the scatterplots falling within the desired area
    targetConvObj <- temp_convObj %>% 
        filter(rmse_b<target_b&rmse_p<target_p) %>% 
        rbind(targetConvObj, .)
    # All points excluding all points on the boundary
    temp_obj <- temp_obj[which(!(temp_obj$ID %in% temp_convObj$ID)),]
    # Prevent duplicated points
    targetConvObj <- targetConvObj[which(!duplicated(targetConvObj$ID)),]
}
write.csv(targetConvObj, '../data/GLUE/frontierTrainAll_500.csv', row.names = F)

# 2) For considering only point
targetConvObj <-  objF_1[order(objF_1$rmse_p),][1:nrOfTargetConvPoints,]
write.csv(targetConvObj, '../data/GLUE/onlySensorTrainAll_500.csv', row.names = F)

# 3) For considering only block
targetConvObj <-  objF_1[order(objF_1$rmse_b),][1:nrOfTargetConvPoints,]
write.csv(targetConvObj, '../data/GLUE/onlyTropomiTrainAll_500.csv', row.names = F)












#------------2. Analysis----------
target_b <- 8          #8
target_p <- 8          #8
objF_1 <- read.csv('objF_stochastic12_trainPoint_all.csv')
objF_1 <- objF_1 %>% select(-rmse_p) %>% rename(rmse_p=rmse_p_trainAll)
target <- objF_1 %>% filter(rmse_b<target_b&rmse_p<target_p)

# Find the coefficient values which lead to the min point rmse and block rmse
objF_1[which.min(objF_1$rmse_b),]
objF_1[which.min(objF_1$rmse_p),]


apply(objF_1, 2, range)
# apply(objF_1 %>% filter(rmse_b<target_b), 2, range)
# apply(objF_1 %>% filter(rmse_p<target_p), 2, range)
# apply(objF_1 %>% filter(rmse_b<target_b&rmse_p<target_p), 2, range)
findTargetPoints <- function(targetPoints, nrOfTargetPoints){
    if(targetPoints=="both"){
        # 1) For considering both point and block
        statement = 'pareto frontier'
        #-------  2.1. Compute convex hull  -----------------
        # Select points at the outer boundary of the scatterplot
        convObj <- objF_1[chull(objF_1$rmse_p, objF_1$rmse_b),]
        # Select points located on the frontier
        convTarget <- target[chull(target$rmse_p, target$rmse_b),]
        #------------ 2.1.2 while loop extract desired amount of points on the convex hull ----------------
        # convObj %>% filter(rmse_b<target_b&rmse_p<target_p) %>% 
        #   select(-rmse_p, -rmse_b) %>% apply(., 2, range)
        targetConvObj <- convObj %>% filter(rmse_b<target_b&rmse_p<target_p)
        temp_obj <- objF_1[which(!(objF_1$ID %in% convObj$ID)),]
        
        while(nrow(targetConvObj)<nrOfTargetPoints){
            # All points on the boundary of the scatterplots
            temp_convObj <- temp_obj[chull(temp_obj$rmse_p, temp_obj$rmse_b),]
            # All points on the boundary of the scatterplots falling within the desired area
            targetConvObj <- temp_convObj %>% filter(rmse_b<target_b&rmse_p<target_p) %>% rbind(targetConvObj, .)
            # All points excluding all points on the boundary
            temp_obj <- temp_obj[which(!(temp_obj$ID %in% temp_convObj$ID)),]
            # Prevent duplicated points
            targetConvObj <- targetConvObj[which(!duplicated(targetConvObj$ID)),]
        }
        
    }
    if(targetPoints=='point'){
        # 2) For considering only point
        statement <- paste0(nrOfTargetPoints, " min ", "rmse points")
        v <- objF_1 %>% mutate(ID_order=objF_1$ID[order(rmse_p)])
        v <- v$ID_order[1:nrOfTargetPoints]
        targetConvObj <- objF_1[which(objF_1$ID %in% v),]
    }
    if(targetPoints=='block'){
        # 3) For considering only block
        statement <- paste0(nrOfTargetPoints, " min ", "rmse blocks")
        v <- objF_1 %>% mutate(ID_order=objF_1$ID[order(rmse_b)])
        v <- v$ID_order[1:nrOfTargetPoints]
        targetConvObj <- objF_1[which(objF_1$ID %in% v),]
    }
    
    # write.csv(targetConvObj %>% mutate(ID=1:nrow(targetConvObj)),
    #           'frontier.csv', row.names = F)
    objF_new <- objF_1 %>% mutate(frontier=as.factor(ifelse(ID %in% targetConvObj$ID,  
                                                            paste0('target: ', statement), "others"))) %>% 
        mutate(all=as.factor("all"))
    objF_new
}

#------------------ 2.1.2.3 Visualization: correlation --------------
objF_new <- findTargetPoints("both",500)
targetPoint <- objF_new %>% filter(frontier!='others') %>% select(-frontier,-all)
# write.csv(targetPoint, 'frontierTrainAll_500.csv', row.names = F)


objF_new <- findTargetPoints("block",500)
targetPoint <- objF_new %>% filter(frontier!='others') %>% select(-frontier,-all)


objF_new <- findTargetPoints("point",500)
targetPoint <- objF_new %>% filter(frontier!='others') %>% select(-frontier,-all)

