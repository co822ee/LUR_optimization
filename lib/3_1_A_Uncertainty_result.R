library(dplyr)
library(gtools)

outputFilePath <- '../data/GLUE/evaluation_allOutputData/'

if(!(file.exists(outputFilePath))){dir.create(outputFilePath)}


sensor_validation <- read.csv('../data/sensorValidateData_all.csv',header=T)
sensor_train <- read.csv('../data/sensorTrainData_all.csv',header=T)
sensor_all <- read.csv('../data/data_laea_new_correctTropomi.csv',header=T)

#---------------Functions--------------
getFileNameWithOrder <- function(scenario, pattern){
    inputFile <- paste0('../data/GLUE/', scenario)
    fileName <- list.files(path = inputFile, pattern=pattern)
    if(grepl('sensor',pattern)){fileName <- fileName[grepl("^(?!.*trop)", 
                                                           fileName, perl=TRUE)]}
    fileName <- mixedsort(sort(fileName))
    paste0(inputFile,'/',fileName)
}
readAllTxTFiles <- function(scenario){
    
    sensorfileName_training <- getFileNameWithOrder(scenario, 'lur_sensor_train')
    sensorfileName_validation <- getFileNameWithOrder(scenario, 'lur_sensor_validation')
    lurTropomifileName_training <- getFileNameWithOrder(scenario, 'lur_tropomi_train')
    lurTropomifileName_validation <- getFileNameWithOrder(scenario, 'lur_tropomi_validate')
    
    
    # LUR predictions:    lurAtSensorLocations      lurTropomiBlocks
    lurAtSensorLocations_training_list <- lapply(sensorfileName_training, 
                                                 read.table)
    lurAtSensorLocations_training <- do.call(cbind,
                                             lurAtSensorLocations_training_list) %>% t()
    lurAtSensorLocations_training <- data.frame(lurAtSensorLocations_training, 
                                                row.names = 1:nrow(lurAtSensorLocations_training))
    
    lurAtSensorLocations_validate_list <- lapply(sensorfileName_validation, read.table)
    lurAtSensorLocations_validate <- do.call(cbind,lurAtSensorLocations_validate_list) %>% t()
    lurAtSensorLocations_validate <- data.frame(lurAtSensorLocations_validate, 
                                                row.names = 1:nrow(lurAtSensorLocations_validate))
    
    names(lurAtSensorLocations_training) <- sensor_train$sensorID
    names(lurAtSensorLocations_validate) <- sensor_validation$sensorID
    #lurTropomiBlocks
    lurTropomiBlocks_training_list <- lapply(lurTropomifileName_training, read.table)
    lurTropomiBlocks_training <- do.call(cbind, lurTropomiBlocks_training_list) %>% t()
    lurTropomiBlocks_training <- data.frame(lurTropomiBlocks_training, 
                                            row.names = 1:nrow(lurTropomiBlocks_training))
    names(lurTropomiBlocks_training) <- read.table("../data/tropomiID_TropomiTrain.txt")[,1]
    
    lurTropomiBlocks_validation_list <- lapply(lurTropomifileName_validation, read.table)
    lurTropomiBlocks_validation <- do.call(cbind, lurTropomiBlocks_validation_list) %>% t()
    lurTropomiBlocks_validation <- data.frame(lurTropomiBlocks_validation, 
                                              row.names = 1:nrow(lurTropomiBlocks_validation))
    names(lurTropomiBlocks_validation) <- read.table("../data/tropomiID_TropomiValidate.txt")[,1]
    
    
    # write the combined data
    write.csv(lurAtSensorLocations_training, paste0(outputFilePath,
                                                    scenario,'_lurAtSensorLocations_training','.csv'), 
              row.names = F)
    write.csv(lurTropomiBlocks_training, paste0(outputFilePath,
                                                scenario,'_lurTropomiBlocks_training','.csv'), 
              row.names = F)
    
    write.csv(lurAtSensorLocations_validate, paste0(outputFilePath,scenario,
                                                    '_lurAtSensorLocations_validation','.csv'), 
              row.names = F)
    write.csv(lurTropomiBlocks_validation, paste0(outputFilePath,scenario,
                                                  '_lurTropomiBlocks_validation','.csv'), 
              row.names = F)
    
}
readAllTxTFiles('all_onlySensorTrainAll_500')
readAllTxTFiles('all_onlyTropomiTrainAll_500')
readAllTxTFiles('all_frontierTrainAll_500')
