library(dplyr)
library(ggplot2)
library(gridExtra)
library(grid)

source("visualization_scatterplotFunction.R")
source('read_GLUE_results.R')

#------------ sensor Training ---------------
sensorTrainingScatterP <- ScatterPlotsWithDefinedSampleSize(sensorSensorTrain, 
                                                            sensor_train$AQValue, 1, 
                                                            list(T,sensor_train),
                                                            '(b) sensor training data')

sensorValidationScatterP <- ScatterPlotsWithDefinedSampleSize(sensorSensorValidate, 
                                                              sensor_validation$AQValue, 1, 
                                                              list(T,sensor_validation),
                                                              '(a) sensor validation data')

tropomiBothScatterP <- ScatterPlotsWithDefinedSampleSize(cbind(sensorTropomiTrain, sensorTropomiValidate), 
                                                         c(tropomiValues_training,tropomiValues_validation), 1, list(F,NULL),
                                                         '(c) all TROPOMI pixels')
gridScatterP <- list(sensorValidationScatterP+theme(legend.position = "none"),
                     sensorTrainingScatterP+labs(y=''),
                     tropomiBothScatterP)
grid.arrange(grobs=gridScatterP, nrow=2, 
             top = textGrob('B. calibrated by sensor training data', gp = gpar(fontsize = 18)))  

# Save image
tiff("../graphs/glue_LUR&obsSensor.tiff", height=8, width=8.5, units='in', res=600)
grid.arrange(grobs=gridScatterP, nrow=2, 
             top = textGrob('B. calibrated by sensor training data', gp = gpar(fontsize = 18)))  
dev.off()

#----------- tropomi training ---------------
sensorBothScatterP <- ScatterPlotsWithDefinedSampleSize(cbind(tropomiSensorTrain, tropomiSensorValidate), 
                                                              c(sensor_train$AQValue, sensor_validation$AQValue), 1, 
                                                              list(T,rbind(sensor_train,sensor_validation)),
                                                              '(a) all sensor data')

tropomiValidationScatterP <- ScatterPlotsWithDefinedSampleSize(tropomiTropomiValidate, 
                                                               tropomiValues_validation, 1, list(F,NULL),
                                                               '(b) TROPOMI validation pixels')
tropomiTrainingScatterP <- ScatterPlotsWithDefinedSampleSize(tropomiTropomiTrain, 
                                                             tropomiValues_training, 1, list(F,NULL),
                                                             '(c) TROPOMI training pixels')

blank <- grid.rect(gp=gpar(col="white"))
gridScatterPBoth <- list(sensorBothScatterP,blank,tropomiValidationScatterP,
                         tropomiTrainingScatterP+ylab(''))
grid.arrange(grobs=gridScatterPBoth, nrow=2, 
             top = textGrob('C. calibrated by TROPOMI training pixels', gp = gpar(fontsize = 18)))  


# Save
tiff("../graphs/glue_LUR&obsTROPOMI.tiff", height=8, width=8.5, units='in', res=600)
grid.arrange(grobs=gridScatterPBoth, nrow=2, 
             top = textGrob('C. calibrated by TROPOMI training pixels', gp = gpar(fontsize = 18)))  

dev.off()

#------median----------
frontierSensorTrain_m <- frontierSensorTrain %>% apply(., 2, median)
frontierSensorValidate_m <- frontierSensorValidate %>% apply(.,2,median)
frontierTropomiValidate_m <- frontierTropomiValidate %>% apply(.,2,median)
frontierTropomiTrain_m <- frontierTropomiTrain %>% apply(.,2,median)

sensorTrainingScatterP <- ScatterPlotsWithDefinedSampleSize_m(frontierSensorTrain_m, 
                                                              sensor_train$AQValue, 
                                                              list(T,sensor_train),
                                                              '(b) sensor training data')

sensorValidationScatterP <- ScatterPlotsWithDefinedSampleSize_m(frontierSensorValidate_m, 
                                                                sensor_validation$AQValue,
                                                                list(T,sensor_validation),
                                                                '(a) sensor validation data')

tropomiValidationScatterP <- ScatterPlotsWithDefinedSampleSize_m(frontierTropomiValidate_m, 
                                                                 tropomiValues_validation, 
                                                                 list(F,NULL),
                                                                 '(c) TROPOMI validation pixels')
tropomiTrainingScatterP <- ScatterPlotsWithDefinedSampleSize_m(frontierTropomiTrain_m,
                                                               tropomiValues_training, 
                                                               list(F,NULL),
                                                               '(d) TROPOMI training')
gridScatterP <- list(sensorValidationScatterP+theme(legend.position = "none"),
                     sensorTrainingScatterP+labs(y=''),
                     tropomiValidationScatterP,
                     tropomiTrainingScatterP+labs(y=''))
grid.arrange(grobs=gridScatterP, nrow=2, 
             top = textGrob('A. calibrated by both TROPOMI and sensor training data', 
                            gp = gpar(fontsize = 15)))  

# Save 
tiff("../graphs/glue_LUR&obsFrontierMedium.tiff", height=8, width=8.5, units='in', res=600)
grid.arrange(grobs=gridScatterP, nrow=2, 
             top = textGrob('A. calibrated by both TROPOMI and sensor training data', gp = gpar(fontsize = 18)))  
dev.off()

