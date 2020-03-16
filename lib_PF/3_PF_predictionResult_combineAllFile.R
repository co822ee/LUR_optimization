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


readAllTxTFiles <- function(scenario){
  sensorfileName_training <- getFileNameWithOrder(paste0(scenario,'/evaluation_allOutputData'), 
                                                  'lurAtSensorLocations_training')
  sensorfileName_validation <- getFileNameWithOrder(paste0(scenario,'/evaluation_allOutputData'), 
                                                    'lurAtSensorLocations_validation')
  lurTropomifileName_training <- getFileNameWithOrder(paste0(scenario,'/evaluation_allOutputData'), 
                                                      'TropomiBlocks_training')
  lurTropomifileName_validation <- getFileNameWithOrder(paste0(scenario,'/evaluation_allOutputData'), 
                                                        'TropomiBlocks_validation')
  
  
  # LUR predictions:    lurAtSensorLocations      lurTropomiBlocks
  lurAtSensorLocations_training_list <- pblapply(sensorfileName_training, read.csv, header=T)
  lurAtSensorLocations_training <- do.call(rbind,lurAtSensorLocations_training_list)
  lurAtSensorLocations_training <- lurAtSensorLocations_training[which(!duplicated(lurAtSensorLocations_training$realizationID)),]
  
  lurAtSensorLocations_validate_list <- pblapply(sensorfileName_validation, read.csv, header=T)
  lurAtSensorLocations_validate <- do.call(rbind,lurAtSensorLocations_validate_list)
  lurAtSensorLocations_validate <- lurAtSensorLocations_validate[which(!duplicated(lurAtSensorLocations_validate$realizationID)),]
  
  names(lurAtSensorLocations_training) <- c(sensor_train$sensorID,'realizationID')
  names(lurAtSensorLocations_validate) <- c(sensor_validation$sensorID,'realizationID')
  
  #lurTropomiBlocks
  lurTropomiBlocks_training_list <- pblapply(lurTropomifileName_training, read.csv, header=T)
  lurTropomiBlocks_training <- do.call(rbind, lurTropomiBlocks_training_list)
  lurTropomiBlocks_training <- lurTropomiBlocks_training[which(!duplicated(lurTropomiBlocks_training$realizationID)),]
  names(lurTropomiBlocks_training) <- c(paste0('X',read.table("../data/tropomiID_TropomiTrain.txt")[,1]),
                                          'realizationID')
  
  
  lurTropomiBlocks_validation_list <- pblapply(lurTropomifileName_validation, read.csv, header=T)
  lurTropomiBlocks_validation <- do.call(rbind, lurTropomiBlocks_validation_list)
  lurTropomiBlocks_validation <- lurTropomiBlocks_validation[which(!duplicated(lurTropomiBlocks_validation$realizationID)),]
  names(lurTropomiBlocks_validation) <- c(paste0('X',read.table("../data/tropomiID_TropomiValidate.txt")[,1]),
                                          'realizationID')
  
  if(!dir.exists(paste0(scenario,'/evaluation_allOutputData/all/'))){
    dir.create(paste0(scenario,'/evaluation_allOutputData/all/'))
  }
  
  # write the combined data
  write.csv(lurAtSensorLocations_training, paste0(scenario,
                                                  '/evaluation_allOutputData/all/',
                                                  'lurAtSensorLocations_training_all.csv'), 
            row.names = F)
  write.csv(lurTropomiBlocks_training, paste0(scenario, 
                                              '/evaluation_allOutputData/all/',
                                              'lurTropomiBlocks_training_all.csv'),
            row.names = F)
  
  write.csv(lurAtSensorLocations_validate, paste0(scenario, 
                                                  '/evaluation_allOutputData/all/',
                                                  'lurAtSensorLocations_validation_all.csv'), 
            row.names = F)
  write.csv(lurTropomiBlocks_validation, paste0(scenario, 
                                                '/evaluation_allOutputData/all/',
                                                'lurTropomiBlocks_validation_all.csv'), 
            row.names = F)
  
}
readAllTxTFiles('../data_PF/PF_bothSensorAndTropomi')

