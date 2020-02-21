library(ggplot2)
library(ggforce)
library(dplyr)
library(gridExtra)


objF <- read.csv('../data/objF_stochastic12.csv', header=T)
names(objF)


convObj <- read.csv('../data/GLUE/frontierTrainAll_500.csv', header = T)
onlySensor <- read.csv('../data/GLUE/onlySensorTrainAll_500.csv', header=T)
onlyTropomi <- read.csv('../data/GLUE/onlyTropomiTrainAll_500.csv', header = T)


all <- ggplot(data=objF, aes(x=rmse_p,y=rmse_b)) +
  geom_point()  

f <- all + 
  theme_bw()+
  geom_point(data=convObj, aes(x=rmse_p,y=rmse_b), color='red')+
  
  # geom_point(data=as.data.frame(objF[which.min(objF$rmse_b),]),
  #            aes(x=rmse_p, y=rmse_b), color='red',shape=1,stroke=2,size=2)+
  # geom_point(data=as.data.frame(objF[which.min(objF$rmse_p),]),
  #            aes(x=rmse_p, y=rmse_b), color='red',shape=1,stroke=2,size=2)+
  labs(x="", y="", title='(a) Both sensor and \n    TROPOMI data (frontier)')+
  facet_zoom(x = rmse_p<8, y= rmse_b<8, zoom.size=0.5, horizontal = F)+
  theme(axis.text = element_text(size=18),
        axis.title = element_text(size=22),
        title = element_text(size=20, face='bold'),
        plot.margin = unit(c(0.01,0.2,0,0.01), "in"))
  # geom_point(data=as.data.frame(target[which.min(target$rmse_b),]),
  #            aes(x=rmse_p, y=rmse_b), color='blue',shape=1,stroke=2,size=2)+
  # geom_point(data=as.data.frame(target[which.min(target$rmse_p),]),
  #            aes(x=rmse_p, y=rmse_b), color='blue',shape=1,stroke=2,size=2)

s <- all + 
  theme_bw()+
  geom_point(data=onlySensor, aes(x=rmse_p,y=rmse_b), color='red')+
  labs(x="", y="RMSE of block data (ug/m^3)", title='(b) Sensor data')+
  theme(axis.text = element_text(size=18),
        axis.title = element_text(size=22),
        title = element_text(size=20, face='bold'),
        plot.margin = unit(c(0.01,0.2,0,0.01), "in"))
t <- all + 
  theme_bw()+
  geom_point(data=onlyTropomi, aes(x=rmse_p,y=rmse_b), color='red')+
  labs(x="RMSE of point data (ug/m^3)", y="", title='(c) TROPOMI data')+
  theme(axis.text = element_text(size=18),
        axis.title = element_text(size=22),
        title = element_text(size=20, face='bold'),
        plot.margin = unit(c(0.01,0.2,0.1,0.01), "in"))

tiff("../graphs/glue_scatterplot_ObjF_all.tiff", height=13.5, width=5, units='in', res=600)
grid.arrange(f,s,t, heights=c(0.5, 0.25, 0.25))
dev.off()
