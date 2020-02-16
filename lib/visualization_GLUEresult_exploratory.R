library(dplyr)
library(ggplot2)
library(corrplot)
library(GGally)
library(gridExtra)
library(pbapply)

path <- '../data/GLUE/evaluation_allOutputData'


sensor_validation <- read.csv('../data/sensorValidateData_all.csv',header=T)
sensor_train <- read.csv('../data/sensorTrainData_all.csv',header=T)

tropomiValues_training <- read.table('../data/tropomiInTropomiTBlock.txt')[,1]
tropomiValues_validation <- read.table('../data/tropomiInTropomiVBlock.txt')[,1]

observation <- list(sensor_train$AQValue, sensor_validation$AQValue, 
                    tropomiValues_training, tropomiValues_validation)

# Model predictions
# sensorTraining, sensorValidation, tropomiTraining, tropomiValidation
onlySensor <- list.files(path = path, pattern='all_onlySensor') %>% 
    paste0(path,'/',.) %>% 
    pblapply(., read.csv, header=T)
onlyTropomi <- list.files(path = path, pattern='all_onlyTropomi') %>% 
    paste0(path,'/',.) %>% 
    pblapply(., read.csv, header=T)
frontier <- list.files(path = path, pattern='all_frontier') %>% 
    paste0(path,'/',.) %>% 
    pblapply(., read.csv, header=T)


rmseCalculate <- function(i, prediction, obs){
    pred <- prediction[[i]]
    obs <- obs[[i]]
    dev <- (t(pred)-obs) %>% t()
    return(apply(dev^2, 1, mean) %>% sqrt())
}

medianCalculate <- function(i, prediction, obs){
    pred <- prediction[[i]]
    return(apply(pred, 2, median))
}


rmse_onlySensor <- pblapply(1:length(onlySensor), rmseCalculate, 
                            prediction=onlySensor, obs=observation) %>% 
    do.call(cbind, .) %>% 
    as.data.frame() %>% rename(St=V1, Sv=V2, 
                               Tt=V3, Tv=V4)
rmse_onlyTropomi <- pblapply(1:length(onlyTropomi), rmseCalculate, 
                            prediction=onlyTropomi, obs=observation) %>% 
    do.call(cbind, .) %>% 
    as.data.frame() %>% rename(St=V1, Sv=V2, 
                               Tt=V3, Tv=V4)
rmse_frontier <- pblapply(1:length(frontier), rmseCalculate, 
                          prediction=frontier, obs=observation) %>% 
    do.call(cbind, .) %>% 
    as.data.frame() %>% rename(St=V1, Sv=V2, 
                               Tt=V3, Tv=V4)

median_onlySensor <- pblapply(1:length(onlySensor), medianCalculate, 
                              prediction=onlySensor) 
median_onlyTropomi <- pblapply(1:length(onlyTropomi), medianCalculate, 
                               prediction=onlyTropomi)
median_frontier <- pblapply(1:length(frontier), medianCalculate, 
                            prediction=frontier) 
data_onlySensor <- read.csv('../data/GLUE/onlySensorTrainAll_500.csv', header=T) %>% 
    cbind(., rmse_onlySensor)
data_onlyTropomi <- read.csv('../data/GLUE/onlyTropomiTrainAll_500.csv', header=T) %>% 
    cbind(., rmse_onlyTropomi)
data_frontier <- read.csv('../data/GLUE/frontierTrainAll_500.csv', header=T) %>% 
    cbind(., rmse_frontier)


#-----------onlySensor----------------------
rmseMedianPrediction <- 
    data.frame(
        onlySensor=lapply(1:4, function(i, obs, pred){
            dev2 <- (obs[[i]]-as.numeric(pred[[i]]))^2
            return(dev2 %>% mean() %>% sqrt())}, obs=observation, pred=median_onlySensor) %>% 
            unlist(),
        onlyTropomi=lapply(1:4, function(i, obs, pred){
            dev2 <- (obs[[i]]-as.numeric(pred[[i]]))^2
            return(dev2 %>% mean() %>% sqrt())}, obs=observation, pred=median_onlyTropomi) %>% 
            unlist(),
        frontier=lapply(1:4, function(i, obs, pred){
            dev2 <- (obs[[i]]-as.numeric(pred[[i]]))^2
            return(dev2 %>% mean() %>% sqrt())}, obs=observation, pred=median_frontier) %>% 
            unlist())
rmseMedianPrediction <- rmseMedianPrediction %>% mutate(data=c('SensorTraining', 'SensorValidation',
                                                               'TropomiTraining', 'TropomiValidation'))

#---------- 0.1 Visualization: boxplot ---------
gg_color_hue <- function(n) {
    hues = seq(15, 375, length = n + 1)
    hcl(h = hues, l = 65, c = 100)[1:n]
}
all <- rbind(sensor_train, sensor_validation)
par(mar=c(2.5,10,1,1), cex.lab=1.5, cex.axis=1.5)
tiff('../graphs/0_boxplotStationType.tiff', height=4.8, width=4.5, units='in', res=600)
boxplot(all$AQValue ~ all$AirQualityStationType, col=gg_color_hue(3), 
        ylab='ambient NO2 concentrations (ug/m^3)')
points(x=factor(c('background','industrial','traffic')), 
       y=c(all %>% filter(AirQualityStationType=='background') %>% summarise(mean=mean(AQValue)),
           all %>% filter(AirQualityStationType=='industrial') %>% summarise(mean=mean(AQValue)),
           all %>% filter(AirQualityStationType=='traffic') %>% summarise(mean=mean(AQValue))),
       pch=1)
dev.off()

boxplot(all$industry_5000 ~ all$AirQualityStationType, col=gg_color_hue(3), 
        ylab='industry_5000')
boxplot(all$road_class_1_500 ~ all$AirQualityStationType, col=gg_color_hue(3), 
        ylab='road_class_1_500')
boxplot(all$road_class_M345_5000 ~ all$AirQualityStationType, col=gg_color_hue(3), 
        ylab='road_M345_5000')

#------------------ 1.1 Visualization: correlation --------------
tiff("../graphs/O_glue_corPlot_onlySensor.tiff", height=5, width=5, units='in', res=600)
corrplot(cor(data_onlySensor %>% select(-rmse_p, -rmse_b, -ID)), 
         type = "lower", method = "pie", tl.cex = 0.9, title='(b) calibrated by sensor',
         mar=c(0,0,2,0))
dev.off()

tiff("../graphs/O_glue_corplot_onlyTropomi.tiff", height=5, width=5, units='in', res=600)
corrplot(cor(data_onlyTropomi %>% select(-rmse_p, -rmse_b, -ID)), 
         type = "lower", method = "pie", tl.cex = 0.9, title='(c) calibrated by Tropomi',
         mar=c(0,0,2,0))
dev.off()


tiff("../graphs/O_glue_corplot_frontier.tiff", height=5, width=5, units='in', res=600)
corrplot(cor(data_frontier %>% select(-rmse_p, -rmse_b, -ID)), 
         type = "lower", method = "pie", tl.cex = 0.9, title='(a) calibrated by frontier',
         mar=c(0,0,2,0))
dev.off()



tiff("../graphs/O_glue_Mcorplot_onlysensor.tiff", height=8.5, width=10.5, units='in', res=600)
ggpairs(data_onlySensor %>% select(-rmse_p, -rmse_b, -ID), 
        title='(b) calibrated by sensor', 
        upper = 'blank', switch = 'both')+
    theme(strip.text = element_text(size=18), 
          axis.text.x = element_text(angle=90, size=15), 
          axis.text.y = element_text(size=13),
          title = element_text(size=22, face='bold'))
dev.off()


tiff("../graphs/O_glue_Mcorplot_onlyTropomi.tiff", height=8.5, width=10.5, units='in', res=600)
ggpairs(data_onlyTropomi %>% select(-rmse_p, -rmse_b, -ID), 
        title='(c) calibrated by Tropomi', 
        upper='blank', switch = 'both')+
    theme(strip.text = element_text(size=18), 
          axis.text.x = element_text(angle=90, size=15), 
          axis.text.y = element_text(size=13),
          title = element_text(size=22, face='bold'))
dev.off()

tiff("../graphs/O_glue_Mcorplot_frontier.tiff", height=8.5, width=10.5, units='in', res=600)
ggpairs(data_frontier %>% select(-rmse_p, -rmse_b, -ID), 
        title='(a) calibrated by frontier', 
        upper='blank',axisLabels = "show", switch = 'both')+
    theme(strip.text = element_text(size=18), 
          axis.text.x = element_text(angle=90, size=13), 
          axis.text.y = element_text(size=13),
          title = element_text(size=22, face='bold'))
dev.off()


#----------------- 1.2 Visualization: distribution --------------
data_combine <- rbind(data_onlySensor %>% select(a,b,d,c,h) %>% mutate(calibration='onlySensor'),
                      data_onlyTropomi %>% select(a,b,d,c,h) %>% mutate(calibration='onlyTropomi'),
                      data_frontier %>% select(a,b,d,c,h) %>% mutate(calibration='frontier'))

hplot_new <- ggplot(data=data_combine)
h1 <- hplot_new + geom_density(aes(x=a, stat(count/sum(count)), fill=calibration), alpha=0.4)+
    labs(y='density')
h2 <- hplot_new + geom_density(aes(x=b, stat(count/sum(count)), fill=calibration), alpha=0.4)+
    labs(y='density')
h3 <- hplot_new + geom_density(aes(x=d, stat(count/sum(count)), fill=calibration), alpha=0.4)+
    labs(y='density')
h4 <- hplot_new + geom_density(aes(x=c, stat(count/sum(count)), fill=calibration), alpha=0.4)+
    labs(y='density')
h5 <- hplot_new + geom_density(aes(x=h, stat(count/sum(count)), fill=calibration), alpha=0.4)+
    labs(y='density')

tiff("../graphs/glue_distriPlot.tiff", height=5, width=10, units='in', res=600)
grid.arrange(h1,h2,h3,h4,h5)
dev.off()

#---------95% interval---------
fallin95Interval <- function(i, realization, observation){
    r <- realization[[i]]
    obs <- observation[[i]]
    q1 <- apply(r, 2, quantile,probs=0.05)
    q2 <- apply(r, 2, quantile,probs=0.95)
    ifelse(q1<obs & q2>obs, 1, 0) %>% mean() *100
}
# fallin95Interval(4, onlySensor, observation)
sapply(1:length(observation), fallin95Interval, onlySensor, observation)
sapply(1:length(observation), fallin95Interval, onlyTropomi, observation)
sapply(1:length(observation), fallin95Interval, frontier, observation)


