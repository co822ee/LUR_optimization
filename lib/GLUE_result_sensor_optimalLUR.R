library(dplyr)
library(ggplot2)

lur_tropomi_t <- read.csv('../data/GLUE/evaluation_allOutputData/all_onlySensorTrainAll_500_lurTropomiBlocks_training.csv',
                          header=T)
lur_tropomi_v <- read.csv('../data/GLUE/evaluation_allOutputData/all_onlySensorTrainAll_500_lurTropomiBlocks_validation.csv',
                          header=T)
tropomi_t <- read.table('../data/tropomiInTropomiTBlock.txt')[,1]
tropomi_v <- read.table('../data/tropomiInTropomiVBlock.txt')[,1]

objF <- read.csv('../data/GLUE/onlySensorTrainAll_500.csv')
lur_tropomi <- cbind(lur_tropomi_t, lur_tropomi_v)  #calibrated by onlySensor 
                                                    #but in a unit of VCD
h <- objF$h
lur_tropomi_ground <- sweep(lur_tropomi, 1, h, `*`)


tropomi <- c(tropomi_t, tropomi_v)           # TROPOMI VCDs
lur_tropomi_g_median <- apply(lur_tropomi_ground, 2, median)
                                             # optimal averaged ground-level 
                                             # predictions from onlySensor  
df <- data.frame(lur=lur_tropomi_g_median, tropomi=tropomi)
lm_eqn <- function(df, intercept=T){
  if(intercept){
    m <- lm(lur ~ tropomi, df);
    eq <- substitute(italic(y) == b~"+"~a %.% italic(x)*","~~italic(R)^2~"="~r2, 
                     list(a = format(unname(coef(m)[2]), digits = 2),
                          b = format(unname(coef(m)[1]), digits = 2),
                          r2 = format(summary(m)$adj.r.squared, digits = 2)))
    return(as.character(as.expression(eq)))
  }else{
    m <- lm(lur ~ tropomi-1, df);
    eq <- substitute(italic(y) == a %.% italic(x)*","~~italic(R)^2~"="~r2, 
                     list(a = format(unname(coef(m)[1]), digits = 2),
                          # b = format(unname(coef(m)[2]), digits = 2),
                          r2 = format(summary(m)$adj.r.squared, digits = 2)))
    return(as.character(as.expression(eq)))
  }
  
  
}
ggplot(df, aes(x=tropomi, y=lur))+
  geom_point()+
  geom_smooth(formula = y~x-1, 
              method='lm', fullrange=TRUE, col='red', se=F)+
  geom_smooth(formula = y~x, 
              method='lm', fullrange=TRUE, col='black', se=F)+
  xlab(paste0("tropospheric column density \n", 
              "(1e15 molecules/cm2)"))+
  ylab(paste0("surface NO2 concentration", "\n (ug.m-3)"))+
  annotate(geom = 'text', label = lm_eqn(df, F), 
           size=6, col='red',
           x = -Inf, y = Inf, hjust = -0.06, vjust = 2.2, parse = TRUE)+
  annotate(geom = 'text', label = lm_eqn(df), 
           size=6, col='black',
           x = -Inf, y = Inf, hjust = -0.06, vjust = 1.2, parse = TRUE)+
  
  xlim(c(0,11))+
  ylim(c(0, 40))+
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 16),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 16))

ggsave('../graphs/correlation_onlySensor_VCD_groundconc.tiff', height=5, width=6.5, units='in', dpi=600)


