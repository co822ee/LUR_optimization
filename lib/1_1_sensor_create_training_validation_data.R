#----Create sensor training data and sensor validation data for the whole study area ------

library(dplyr)
library(raster)

data_all_sensor <- read.csv('../data/data_laea_new_correctTropomi.csv', header=T)
data_all_sensor <- data_all_sensor %>% mutate(sensorID=1:nrow(.))

ratioofStationType <- function(df, stationType){
    ((df$AirQualityStationType[df$AirQualityStationType==stationType]) %>% length())/(df %>% nrow)
}

ratioofStationType(data_all_sensor, 'background')
ratioofStationType(data_all_sensor, 'traffic')
ratioofStationType(data_all_sensor, 'industrial')

nrOfStationType <- function(df, stationType, train=T){
    if(train){dfRatio=0.6}else{dfRatio=0.4}
    round(dfRatio * nrow(df) * ratioofStationType(df,stationType))
}
#Training 
nrOfStationType(data_all_sensor, 'background')           #23
nrOfStationType(data_all_sensor, 'traffic')              #11
nrOfStationType(data_all_sensor, 'industrial')           #4

generateValidationData <- function(df){
    nrOfStationType(df, 'background', F)
    nrOfStationType(df, 'traffic', F)
    nrOfStationType(df, 'industrial', F)
    
    set.seed(123)
    # Select samples from the original validation sensor data
    nrOfBackground <- sample((df %>% filter(AirQualityStationType=='background') %>% dplyr::select(sensorID))[,1],nrOfStationType(df, 'background', F))
    nrOfTraffic <- sample((df %>% filter(AirQualityStationType=='traffic') %>% dplyr::select(sensorID))[,1],nrOfStationType(df, 'traffic', F))
    nrOfIndustrial <- sample((df %>% filter(AirQualityStationType=='industrial') %>% dplyr::select(sensorID))[,1],nrOfStationType(df, 'industrial', F))
    nrOfBackground
    newValidationSensorID <- c(nrOfBackground, nrOfTraffic, nrOfIndustrial)
    df_new_validation <- df[which(df$sensorID %in% newValidationSensorID),]
    df_new_validation
}
sensor_all_validation <- generateValidationData(data_all_sensor)
sensor_all_training <- data_all_sensor[which(!(data_all_sensor$sensorID %in% sensor_all_validation$sensorID)),]


# ratioofStationType(sensor_all_validation, 'background')
# ratioofStationType(sensor_all_training, 'background')
# ratioofStationType(data_all_sensor, 'background')
# 
# ratioofStationType(sensor_all_validation, 'traffic')
# ratioofStationType(sensor_all_training, 'traffic')
# ratioofStationType(data_all_sensor, 'traffic')
# 
# ratioofStationType(sensor_all_validation, 'industrial')
# ratioofStationType(sensor_all_training, 'industrial')
# ratioofStationType(data_all_sensor, 'industrial')
# 
# 
# sensor_all_validation %>% filter(AirQualityStationType=='background') %>% nrow()
# sensor_all_training %>% filter(AirQualityStationType=='background') %>% nrow()
# data_all_sensor %>% filter(AirQualityStationType=='background') %>% nrow()
# 
# sensor_all_validation %>% filter(AirQualityStationType=='traffic') %>% nrow()
# sensor_all_training %>% filter(AirQualityStationType=='traffic') %>% nrow()
# data_all_sensor %>% filter(AirQualityStationType=='traffic') %>% nrow()
# 
# sensor_all_validation %>% filter(AirQualityStationType=='industrial') %>% nrow()
# sensor_all_training %>% filter(AirQualityStationType=='industrial') %>% nrow()
# data_all_sensor %>% filter(AirQualityStationType=='industrial') %>% nrow()



write.csv(sensor_all_training, '../data/sensorTrainData_all.csv', row.names = F)
write.csv(sensor_all_validation, '../data/sensorValidateData_all.csv', row.names = F)

