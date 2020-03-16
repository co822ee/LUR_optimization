library(dplyr)
library(pbapply)
library(gtools)

sensor_validation <- read.csv('../data/sensorValidateData_all.csv',header=T)
sensor_train <- read.csv('../data/sensorTrainData_all.csv',header=T)
sensor_all <- read.csv('../data/data_laea_new_correctTropomi.csv',header=T)

#---------------Functions--------------
getFileNameWithOrder <- function(scenario, pattern){
  fileName <- list.files(path = scenario, pattern=pattern)
  # if(grepl('sensor',pattern)){fileName <- fileName[grepl("^(?!.*trop)", fileName, perl=TRUE)]}
  fileName <- mixedsort(sort(fileName))
  paste0(scenario,'/',fileName)
}
getFileNumber <- function(scenario, pattern){
  fileName <- list.files(path = scenario, pattern=pattern)
  # if(grepl('sensor',pattern)){fileName <- fileName[grepl("^(?!.*trop)", fileName, perl=TRUE)]}
  fileName <- mixedsort(sort(fileName))
  as.numeric(regmatches(fileName, regexpr("[[:digit:]]+", fileName)))
}


readAllTxTFiles <- function(scenario){
  sensorfileName_training <- getFileNameWithOrder(scenario, 'lur_sensor_train')
  sensorfileName_validation <- getFileNameWithOrder(scenario, 'lur_sensor_validate')
  lurTropomifileName_training <- getFileNameWithOrder(scenario, 'lur_tropomi_train')
  lurTropomifileName_validation <- getFileNameWithOrder(scenario, 'lur_tropomi_validate')
  
  lst <- getFileNumber(scenario, 'lur_sensor_train')
  lsv <- getFileNumber(scenario, 'lur_sensor_validate')
  ltt <- getFileNumber(scenario, 'lur_tropomi_train')
  ltv <- getFileNumber(scenario, 'lur_tropomi_validate')
  
  # LUR predictions:    lurAtSensorLocations      lurTropomiBlocks
  lurAtSensorLocations_training_list <- pblapply(sensorfileName_training, read.table)
  lurAtSensorLocations_training <- do.call(cbind,
                                           lurAtSensorLocations_training_list) %>% t()
  lurAtSensorLocations_training <- data.frame(lurAtSensorLocations_training, 
                                              row.names = 1:nrow(lurAtSensorLocations_training))
  
  lurAtSensorLocations_validate_list <- pblapply(sensorfileName_validation, read.table)
  lurAtSensorLocations_validate <- do.call(cbind,
                                           lurAtSensorLocations_validate_list) %>% t()
  lurAtSensorLocations_validate <- data.frame(lurAtSensorLocations_validate, 
                                              row.names = 1:nrow(lurAtSensorLocations_validate))
  
  names(lurAtSensorLocations_training) <- sensor_train$sensorID
  names(lurAtSensorLocations_validate) <- sensor_validation$sensorID
  
  lurAtSensorLocations_training <- lurAtSensorLocations_training %>% mutate(realizationID = lst)
  lurAtSensorLocations_validate <- lurAtSensorLocations_validate %>% mutate(realizationID = lsv)
  
  #lurTropomiBlocks
  lurTropomiBlocks_training_list <- pblapply(lurTropomifileName_training, read.table)
  lurTropomiBlocks_training <- do.call(cbind, lurTropomiBlocks_training_list) %>% t()
  lurTropomiBlocks_training <- data.frame(lurTropomiBlocks_training, 
                                          row.names = 1:nrow(lurTropomiBlocks_training))

  
  lurTropomiBlocks_validation_list <- pblapply(lurTropomifileName_validation, read.table)
  lurTropomiBlocks_validation <- do.call(cbind, lurTropomiBlocks_validation_list) %>% t()
  lurTropomiBlocks_validation <- data.frame(lurTropomiBlocks_validation, 
                                            row.names = 1:nrow(lurTropomiBlocks_validation))
  
  names(lurTropomiBlocks_training) <- read.table("../data/tropomiID_TropomiTrain.txt")[,1]
  names(lurTropomiBlocks_validation) <- read.table("../data/tropomiID_TropomiValidate.txt")[,1]
  
  lurTropomiBlocks_training <- lurTropomiBlocks_training %>% mutate(realizationID = ltt)
  lurTropomiBlocks_validation <- lurTropomiBlocks_validation %>% mutate(realizationID = ltv)
  
  if(!dir.exists(paste0(scenario, '/evaluation_allOutputData/'))){
    dir.create(paste0(scenario, '/evaluation_allOutputData/'))
  }
  # write the combined data
  write.csv(lurAtSensorLocations_training, paste0(scenario, 
                                                  '/evaluation_allOutputData/',
                                                  'lurAtSensorLocations_training_',
                                                  range(lst)[1],'_',range(lst)[2],'.csv'), 
            row.names = F)
  write.csv(lurTropomiBlocks_training, paste0(scenario, 
                                              '/evaluation_allOutputData/',
                                              'lurTropomiBlocks_training_',
                                              range(ltt)[1],'_',range(ltt)[2],'.csv'), 
            row.names = F)
  
  write.csv(lurAtSensorLocations_validate, paste0(scenario, 
                                                  '/evaluation_allOutputData/',
                                                  'lurAtSensorLocations_validation_',
                                                  range(lsv)[1],'_',range(lsv)[2],'.csv'), 
            row.names = F)
  write.csv(lurTropomiBlocks_validation, paste0(scenario, 
                                                '/evaluation_allOutputData/',
                                                'lurTropomiBlocks_validation_',
                                                range(ltv)[1],'_',range(ltv)[2],'.csv'), 
            row.names = F)
  
}
readAllTxTFiles('../data_PF/PF_bothSensorAndTropomi')

