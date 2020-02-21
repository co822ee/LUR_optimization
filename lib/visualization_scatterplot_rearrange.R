library(dplyr)
library(ggplot2)
library(gridExtra)
library(grid)

source("visualization_scatterplotFunction_rearrange.R")
source('read_GLUE_results.R')

frontierSensorTrain_m <- frontierSensorTrain %>% apply(., 2, median)
frontierSensorValidate_m <- frontierSensorValidate %>% apply(.,2,median)
frontierTropomiValidate_m <- frontierTropomiValidate %>% apply(.,2,median)
frontierTropomiTrain_m <- frontierTropomiTrain %>% apply(.,2,median)

#------------ sensor Training ---------------
frontierP <- ScatterPlotsWithDefinedSampleSize_m(frontierSensorTrain_m, 
                                                 sensor_train$AQValue, 
                                                 list(T,sensor_train),
                                                 '')


onlySensorP <-  ScatterPlotsWithDefinedSampleSize(sensorSensorTrain, 
                                                  sensor_train$AQValue, 1, 
                                                  list(T,sensor_train),
                                                 '')

onlyTropomiP <- ScatterPlotsWithDefinedSampleSize(
                        cbind(tropomiSensorTrain, tropomiSensorValidate),
                        c(sensor_train$AQValue, sensor_validation$AQValue), 1,
                        list(T,rbind(sensor_train,sensor_validation)),
                        '')

gridScatterP <- list(frontierP+theme(legend.position = "none")+
                         labs(x='')+
                         theme(plot.margin = unit(c(0.1, 0, 0.2, 0), "in")),
                     onlySensorP+labs(y='')+theme(legend.position = "none"),
                     onlyTropomiP+labs(y='',x='')+
                         theme(plot.margin = unit(c(0.1, 0, 0.2, 0), "in")))
grid.arrange(grobs=gridScatterP, nrow=1, 
             top = textGrob('B. sensor training data', 
                            gp = gpar(fontsize = 28)))  

# Save image
tiff("../graphs/glue_LUR_sensorTrain.tiff", height=5, width=12, units='in', res=600)
grid.arrange(grobs=gridScatterP, nrow=1, 
             top = textGrob('B. sensor training data', 
                            gp = gpar(fontsize = 28)))  
dev.off()

#----------- tropomi training ---------------
frontierP <- ScatterPlotsWithDefinedSampleSize_m(frontierTropomiTrain_m,
                                                 tropomiValues_training, 
                                                 list(F,NULL),
                                                 '')

onlySensorP <- ScatterPlotsWithDefinedSampleSize(cbind(sensorTropomiTrain, sensorTropomiValidate), 
                                                 c(tropomiValues_training,tropomiValues_validation), 1, list(F,NULL),
                                                 '')

onlyTropomiP <- ScatterPlotsWithDefinedSampleSize(tropomiTropomiTrain, 
                                                  tropomiValues_training, 1, list(F,NULL),
                                                  '')
gridScatterP <- list(frontierP+theme(legend.position = "none")+labs(x='')+
                         theme(plot.margin = unit(c(0.1, 0, 0.2, 0), "in")),
                     onlySensorP+labs(y='')+theme(legend.position = "none"),
                     onlyTropomiP+labs(y='')+labs(x='')+
                         theme(plot.margin = unit(c(0.1, 0, 0.2, 0), "in")))
grid.arrange(grobs=gridScatterP, nrow=1, 
             top = textGrob('D. tropomi training pixels ', 
                            gp = gpar(fontsize = 28)))  

# Save image
tiff("../graphs/glue_LUR_tropomiTrain.tiff", height=5, width=12, units='in', res=600)
grid.arrange(grobs=gridScatterP, nrow=1, 
             top = textGrob('D. tropomi training pixels ', 
                            gp = gpar(fontsize = 28)))  
dev.off()
#------sensor Validation data----------
frontierP <- ScatterPlotsWithDefinedSampleSize_m(frontierSensorValidate_m, 
                                                 sensor_validation$AQValue,
                                                 list(T,sensor_validation),
                                                 '(a) frontier')

onlySensorP <- ScatterPlotsWithDefinedSampleSize(sensorSensorValidate, 
                                                 sensor_validation$AQValue, 1, 
                                                 list(T,sensor_validation),
                                                 '(b) onlySensor')

onlyTropomiP <- ScatterPlotsWithDefinedSampleSize(cbind(tropomiSensorTrain, tropomiSensorValidate), 
                                                  c(sensor_train$AQValue, sensor_validation$AQValue), 1, 
                                                  list(T,rbind(sensor_train,sensor_validation)),
                                                  '(c) onlyTropomi')

gridScatterP <- list(frontierP+theme(legend.position = "none")+labs(x='')+
                         theme(plot.margin = unit(c(0.1, 0, 0.2, 0), "in")),
                     onlySensorP+labs(y='')+theme(legend.position = "none"),
                     onlyTropomiP+labs(y='')+labs(x='')+
                         theme(plot.margin = unit(c(0.1, 0, 0.2, 0), "in")))
grid.arrange(grobs=gridScatterP, nrow=1, 
             top = textGrob('A. sensor validation data', 
                            gp = gpar(fontsize = 28)))  

# Save image
tiff("../graphs/glue_LUR_sensorValidate.tiff", height=5, width=12, units='in', res=600)
grid.arrange(grobs=gridScatterP, nrow=1, 
             top = textGrob('A. sensor validation data', 
                            gp = gpar(fontsize = 28)))  
dev.off()

#----------- Tropomi Validation pixels
frontierP <-  ScatterPlotsWithDefinedSampleSize_m(frontierTropomiValidate_m, 
                                                  tropomiValues_validation, 
                                                  list(F,NULL),
                                                  '')

onlySensorP <- ScatterPlotsWithDefinedSampleSize(cbind(sensorTropomiTrain, sensorTropomiValidate), 
                                                 c(tropomiValues_training,tropomiValues_validation), 1, list(F,NULL),
                                                 '')

onlyTropomiP <- ScatterPlotsWithDefinedSampleSize(tropomiTropomiValidate, 
                                                  tropomiValues_validation, 1, list(F,NULL),
                                                  '')

gridScatterP <- list(frontierP+theme(legend.position = "none")+labs(x='')+
                         theme(plot.margin = unit(c(0.1, 0, 0.2, 0), "in")),
                     onlySensorP+labs(y='')+theme(legend.position = "none"),
                     onlyTropomiP+labs(y='')+labs(x='')+
                         theme(plot.margin = unit(c(0.1, 0, 0.2, 0), "in")))
grid.arrange(grobs=gridScatterP, nrow=1, 
             top = textGrob('C. tropomi validation pixels', 
                            gp = gpar(fontsize = 28)))  

# Save image
tiff("../graphs/glue_LUR_tropomiValidate.tiff", height=5, width=12, units='in', res=600)
grid.arrange(grobs=gridScatterP, nrow=1, 
             top = textGrob('C. tropomi validation pixels', 
                            gp = gpar(fontsize = 28)))  
dev.off()

