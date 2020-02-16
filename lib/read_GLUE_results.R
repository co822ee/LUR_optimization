
# Observations
sensor_validation <- read.csv('../data/sensorValidateData_all.csv',header=T)
sensor_train <- read.csv('../data/sensorTrainData_all.csv',header=T)
sensor_all <- read.csv('../data/data_laea_new_correctTropomi.csv',header=T)

tropomiValues_training <- read.table('../data/tropomiInTropomiTBlock.txt')[,1]
tropomiValues_validation <- read.table('../data/tropomiInTropomiVBlock.txt')[,1]

#LUR prediction realizations
readFile <- function(scenario,sensorOrTropomi,training=T){
    fileName <- list.files(path = '../data/GLUE/evaluation_allOutputData',pattern = scenario)
    fileName <- fileName[grepl("^(?!.*clip)", fileName, perl=TRUE)]
    if(training){fileName <- fileName[grepl("^(?=.*training)", fileName, perl=TRUE)]}else{fileName <- fileName[grepl("^(?=.*validation)", fileName, perl=TRUE)]}
    if(sensorOrTropomi=='sensor'){
        fileName <- fileName[grepl("^(?=.*SensorLocations)", fileName, perl=TRUE)]
    }
    if(sensorOrTropomi=='tropomi'){
        fileName <- fileName[grepl("^(?=.*TropomiBlocks)", fileName, perl=TRUE)]
    }
    print(fileName)
    read.csv(paste0('../data/GLUE/evaluation_allOutputData/', fileName), header = T)
}

# All the values are acquired from the validation pixels or validation monitoring stations
frontierSensorTrain <- readFile('frontier', 'sensor',T)
frontierSensorValidate <- readFile('frontier', 'sensor',F)
frontierTropomiTrain <- readFile('frontier', 'tropomi',T)
frontierTropomiValidate <- readFile('frontier', 'tropomi',F)


sensorSensorTrain <- readFile('onlySensor', 'sensor',T)
sensorSensorValidate <- readFile('onlySensor', 'sensor',F)
sensorTropomiTrain <- readFile('onlySensor', 'tropomi',T)
sensorTropomiValidate <- readFile('onlySensor', 'tropomi',F)

tropomiSensorTrain <- readFile('onlyTropomi', 'sensor',T)
tropomiSensorValidate <- readFile('onlyTropomi', 'sensor',F)
tropomiTropomiTrain <- readFile('onlyTropomi', 'tropomi',T)
tropomiTropomiValidate <- readFile('onlyTropomi', 'tropomi',F)
