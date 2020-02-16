
lm_eqn <- function(df){
    m <- lm(obs ~ lur, df);
    eq1 <- substitute(italic(y) == a + b %.% italic(x), 
                      list(a = format(unname(coef(m)[1]), digits = 2),
                           b = format(unname(coef(m)[2]), digits = 2),
                           r2 = format(summary(m)$r.squared, digits = 3)))
    eq2 <- substitute(italic(R)^2~"="~r2, 
                      list(a = format(unname(coef(m)[1]), digits = 2),
                           b = format(unname(coef(m)[2]), digits = 2),
                           r2 = format(summary(m)$r.squared, digits = 3)))
    correlation <- substitute(italic(cor)~"="~Cor,
                              list(Cor=format(cor(x=df$lur, y=df$obs), digits = 2)))
    
    list(as.character(as.expression(eq1)),as.character(as.expression(eq2)), 
         as.character(as.expression(correlation)))
}

findXRange_scatterPlot <- function(ensPredictions, rangeVector){
    # I want to know the range of values for each realization
    tropomiComparisonRange <- apply(ensPredictions, 1, range)      
    xRange <- sapply(X = 1:nrow(tropomiComparisonRange), FUN = function(i,m){
        if(i==1) {return(min(m[i,rangeVector]))}
        if(i==2) {return(max(m[i,rangeVector]))}
    },m=tropomiComparisonRange)
    return(xRange)
}


ScatterPlotsWithDefinedSampleSize <- function(ensPredictions, observations, indexVector, 
                                              sensorList=list(T, sensor_data_all=NULL), 
                                              titleTexts=NULL, indexRangeVectorForPlotting=1){
    (as.numeric(ensPredictions[indexVector,])-observations)^2 %>% mean() %>% sqrt() %>% 
        print()
    xRange <- findXRange_scatterPlot(ensPredictions, indexRangeVectorForPlotting)
    yRange <- range(observations)
    # eqY <- yRange[2]+diff(yRange)*0.1
    # eqX <- 
    if(sensorList[[1]]){
        createDF_sensor <- function(index){
            data.frame(lur=as.numeric(ensPredictions[index,]), obs=observations, 
                       stationType=sensorList[[2]]$AirQualityStationType, realization=as.factor(index))
        }
        scatterplotDF_list <- lapply(indexVector, createDF_sensor)
        
        scatterplotDF <- do.call(rbind, scatterplotDF_list)
        p <- ggplot(data=scatterplotDF, aes(x=lur, y=obs))+
            geom_point(aes(col=stationType))+  #, shape=realization
            geom_smooth(method='lm', se=F, fullrange=TRUE, color='black')+
            geom_abline(intercept = 0, slope = 1, lty=2,lwd=1)+
            # xlim(c(0, xRange[2]))+ 
            # ylim(c(0, yRange[2]))+
            xlim(c(0, 52))+ 
            ylim(c(0, 52))+
            labs(title=titleTexts, x='predicted (ug/m^3)', y='observed \n (ug/m^3)')+
            theme(
                legend.background = element_rect(fill='transparent',color='black'),
                legend.justification=c(1,0), legend.position=c(1,0),
                legend.margin = margin(r=0.2, unit="cm"),
                legend.key = element_rect(colour = 'transparent', fill = 'transparent'),
                legend.title=element_blank(),
                strip.text = element_text(size=15), 
                axis.text.x = element_text(size=12), 
                axis.text.y = element_text(size=12),
                title = element_text(size=15)
                # legend.key=element_blank()   #legend.title=element_blank()
            )
        p1 <- p + annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[1]], 
                           size=5,
                           x = -Inf, y = Inf, hjust =-0.15, vjust = 1.2, parse = TRUE)+
            annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[2]], 
                     size=5,
                     x = -Inf, y = Inf, hjust = -0.15, vjust = 2.5, parse = TRUE)+
            annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[3]], 
                     size=5,
                     x = -Inf, y = Inf, hjust = -0.15, vjust = 6, parse = TRUE)
        
    }else{
        createDF_Tropomi <- function(index){
            data.frame(lur=as.numeric(ensPredictions[index,]), obs=observations, 
                       realization=as.factor(index))
        }
        scatterplotDF_list <- lapply(indexVector, createDF_Tropomi)
        scatterplotDF <- do.call(rbind, scatterplotDF_list)
        p <- ggplot(data=scatterplotDF, aes(x=lur, y=obs))+
            geom_point()+  #, shape=realization
            geom_smooth(method='lm', se=F, fullrange=TRUE, color='black')+
            # xlim(c(0, xRange[2]))+ 
            # ylim(c(0, yRange[2]))+
            xlim(c(0, 18))+ 
            ylim(c(0, 18))+
            geom_abline(intercept = 0, slope = 1,lty=2,lwd=1)+
            labs(title=titleTexts, x="predicted (1e15 molecules/cm^2)", y='observed \n (1e15 molecules/cm^2)')+
            theme(strip.text = element_text(size=15), 
                  axis.text.x = element_text(size=12), 
                  axis.text.y = element_text(size=12),
                  title = element_text(size=15))
        p1 <- p + annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[1]], 
                           size=5,
                           x = -Inf, y = Inf, hjust =-0.15, vjust = 1.2, parse = TRUE)+
            annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[2]], 
                     size=5,
                     x = -Inf, y = Inf, hjust = -0.15, vjust = 2.5, parse = TRUE)+
            annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[3]], 
                     size=5,
                     x = -Inf, y = Inf, hjust = -0.15, vjust = 6, parse = TRUE)
    }
    p2 <- p1
}

ScatterPlotsWithDefinedSampleSize_m <- function(ensPredictions, observations, 
                                                sensorList=list(T, sensor_data_all=NULL), 
                                                titleTexts=NULL, indexRangeVectorForPlotting=1){
    (as.numeric(ensPredictions)-observations)^2 %>% mean() %>% sqrt() %>% 
        print()
    xRange <- range(ensPredictions)
    yRange <- range(observations)
    # eqY <- yRange[2]+diff(yRange)*0.1
    # eqX <- 
    if(sensorList[[1]]){
        scatterplotDF <- data.frame(lur=as.numeric(ensPredictions), 
                                    obs=observations,
                                    stationType=sensorList[[2]]$AirQualityStationType)
        p <- ggplot(data=scatterplotDF, aes(x=lur, y=obs))+
            geom_point(aes(col=stationType))+  #, shape=realization
            geom_smooth(method='lm', se=F, fullrange=TRUE, color='black')+
            geom_abline(intercept = 0, slope = 1, lty=2,lwd=1)+
            xlim(c(0, 52))+ 
            ylim(c(0, 52))+
            # xlim(c(0, xRange[2]))+ 
            # ylim(c(0, yRange[2]))+
            labs(title=titleTexts, x='predicted (ug/m^3)', y='observed \n (ug/m^3)')+
            theme(
                legend.background = element_rect(fill='transparent',color='black'),
                legend.justification=c(1,0), legend.position=c(1,0),
                legend.margin = margin(r=0.2, unit="cm"),
                legend.key = element_rect(colour = 'transparent', fill = 'transparent'),
                legend.title=element_blank(),
                strip.text = element_text(size=15), 
                axis.text.x = element_text(size=12), 
                axis.text.y = element_text(size=12),
                title = element_text(size=15)
                # legend.key=element_blank()   #legend.title=element_blank()
            )
        p1 <- p + annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[1]], 
                           size=5,
                           x = -Inf, y = Inf, hjust =-0.15, vjust = 1.2, parse = TRUE)+
            annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[2]], 
                     size=5,
                     x = -Inf, y = Inf, hjust = -0.15, vjust = 2.5, parse = TRUE)+
            annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[3]], 
                     size=5,
                     x = -Inf, y = Inf, hjust = -0.15, vjust = 6, parse = TRUE)
        
    }else{
        
        scatterplotDF <- data.frame(lur=as.numeric(ensPredictions), 
                                    obs=observations)
        
        p <- ggplot(data=scatterplotDF, aes(x=lur, y=obs))+
            geom_point()+  #, shape=realization
            geom_smooth(method='lm', se=F, fullrange=TRUE, color='black')+
            xlim(c(0, 18))+ 
            ylim(c(0, 18))+
            # xlim(c(0, xRange[2]))+ 
            # ylim(c(0, yRange[2]))+
            geom_abline(intercept = 0, slope = 1,lty=2,lwd=1)+
            labs(title=titleTexts, x="predicted (1e15 molecules/cm^2)", y='observed \n (1e15 molecules/cm^2)')+
            theme(strip.text = element_text(size=15), 
                  axis.text.x = element_text(size=12), 
                  axis.text.y = element_text(size=12),
                  title = element_text(size=15))
        p1 <- p + annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[1]], 
                           size=5,
                           x = -Inf, y = Inf, hjust =-0.15, vjust = 1.2, parse = TRUE)+
            annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[2]], 
                     size=5,
                     x = -Inf, y = Inf, hjust = -0.15, vjust = 2.5, parse = TRUE)+
            annotate(geom = 'text', label = lm_eqn(scatterplotDF)[[3]], 
                     size=5,
                     x = -Inf, y = Inf, hjust = -0.15, vjust = 6, parse = TRUE)
    }
    p2 <- p1
}
