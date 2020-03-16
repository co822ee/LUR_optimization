library(gridExtra)
library(pbapply)
library(dplyr)
library(ggplot2)
library(tidyr)
scenario <- '../data_PF/'
updatedpf_dir <- list.files(pattern='coefList_PF_updated', 
                            path=scenario) %>% 
    paste0(scenario, .)
updatedpf <- lapply(updatedpf_dir, read.table, header=T)

titleName <- gsub(paste0(scenario, 'coefList_PF_updated_'), 
                  '', updatedpf_dir) %>% gsub('.txt', '', .)

updated_parameter <- do.call(rbind, updatedpf)
updated_parameter <- updated_parameter %>% 
    mutate(setting=rep(titleName, each=nrow(updatedpf[[1]])))


frontier <- read.csv('../data/GLUE/frontierTrainAll_500.csv')
onlySensor <- read.csv('../data/GLUE/onlySensorTrainAll_500.csv')
onlyTropomi <- read.csv('../data/GLUE/onlyTropomiTrainAll_500.csv')
glue <- rbind(frontier, onlySensor, onlyTropomi) %>% 
    mutate(setting=rep(c('glue_frontier','glue_onlySensor','glue_onlyTropomi'),
                       each=nrow(frontier))) %>% select(-rmse_p,-rmse_b) %>% 
    rename(index='ID')

glue_all <- glue %>% gather(key='parameter',value='value',
                            a, b, d, c, h)
targetPlot_all <- updated_parameter %>% gather(key='parameter', value='value',
                                        a, b, d, c, h)
#--------------------Analyze------------------------------------
allPlot <- rbind(glue_all, targetPlot_all)
ggplot(allPlot)+
    geom_histogram(aes(x=value), bins=25)+ #binwidth=0.00001
    # facet_wrap(setting~parameter, ncol=5, scales = 'free_y',)
    facet_grid(setting~parameter, scales = 'free')+
    theme(strip.text = element_text(size = 9),
          axis.title = element_text(size = 19),
          axis.text = element_text(size = 16),
          axis.text.x = element_text(size = 12, angle = 20))
ggsave('graphs/PF_hist_all_glue.tiff', width = 13, height = 14, units = 'in', dpi = 600)
