library(dplyr)
library(ggplot2)
library(gridExtra)
library(grid)

source('read_GLUE_results.R')

#------fall in 95% interval----------
fallIn95Interval <- function(i, observation, quantile){
  if(observation[i]>quantile[1,i] & observation[i]<quantile[2,i]){
    return(1)
  }else{return(0)}
}

percentageFallIn95Interval <- function(frontier, sensor, tropomi, observations){
  frontierQ <- apply(frontier,2,quantile, probs = c(0.05, 0.95))
  sensorQ <- apply(sensor,2,quantile, probs = c(0.05, 0.95))
  tropomiQ <- apply(tropomi,2,quantile, probs = c(0.05, 0.95))
  
  
  test <- data.frame(frontierTrain =sapply(1:length(observations), fallIn95Interval,
                                           observation=observations, quantile=frontierQ), 
                     sensorTrain = sapply(1:length(observations), fallIn95Interval, 
                                          observation=observations, quantile=sensorQ),
                     tropomiTrain = sapply(1:length(observations), fallIn95Interval, 
                                           observation=observations, quantile=tropomiQ))
  sensor_train_result <- test %>% select(matches('Train')) %>% 
    summarise(tropomi=(sum(tropomiTrain)/length(observations)) %>% round(digits = 3),
              sensor=(sum(sensorTrain)/length(observations)) %>% round(digits = 3),
              frontier=(sum(frontierTrain)/length(observations)) %>% round(digits = 3))
  sensor_train_result*100
  # return(observations)
}
percentageFallIn95Interval(frontierSensorValidate, sensorSensorValidate, tropomiSensorValidate, 
                           sensor_validation$AQValue)
# percentageFallIn95Interval(frontierSensorTrain, sensorSensorTrain, tropomiSensorTrain, sensor_train$AQValue)
percentageFallIn95Interval(frontierTropomiValidate, sensorTropomiValidate, tropomiTropomiValidate, 
                           tropomiValues_validation)


unstandardizeBoundRangeBoxplot <- function(frontier, sensor, tropomi, observations){
  frontierQ <- apply(frontier,2,quantile, probs = c(0.05, 0.95))
  sensorQ <- apply(sensor,2,quantile, probs = c(0.05, 0.95))
  tropomiQ <- apply(tropomi,2,quantile, probs = c(0.05, 0.95))
  
  n=ncol(tropomiQ)
  
  d <- data.frame(values=c((tropomiQ[2,] - tropomiQ[1,]),
                           (sensorQ[2,] - sensorQ[1,]),
                           (frontierQ[2,] - frontierQ[1,])),
                  calibration=c(rep('tropomi',n), rep('sensor',n), rep('both',n)))
  ggplot(d, aes(x=calibration,y=values))+
    geom_boxplot()+
    xlab('calibration data sets')
}
t <- unstandardizeBoundRangeBoxplot(frontierTropomiValidate, sensorTropomiValidate, tropomiTropomiValidate, 
                             tropomiValues_validation) + 
  labs(title = ' (b) TROPOMI validation pixels') +
  ylab('uncertainty bound width \n (1e15molecules/cm^2)')+
  theme(axis.text = element_text(size=15),
        axis.title = element_text(size=15),
        title = element_text(size=18),
        plot.margin = unit(c(0.05,0.2,0.1,0.05), "in"))

s <- unstandardizeBoundRangeBoxplot(frontierSensorValidate, sensorSensorValidate, tropomiSensorValidate, 
                               tropomiValues_validation) + 
  labs(title = '(a) sensor validation locations') +
  ylab('uncertainty bound width \n (ug/m^2)')+
  theme(axis.text = element_text(size=15),
        axis.title = element_text(size=15),
        title = element_text(size=18),
        plot.margin = unit(c(0.05,0.2,0.1,0.05), "in"))

do.call(grid.arrange, list(s,t))

tiff("../graphs/glue_boxplot_boundwidth.tiff", height=8, width=5, units='in', res=600)
do.call(grid.arrange, list(s,t))
dev.off()
