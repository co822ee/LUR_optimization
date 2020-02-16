# 2019/10/25

library(gtools)
library(pbapply)
library(raster)
library(dplyr)

data_all <- read.csv('../data/data_laea_new_correctTropomi.csv')

#------ sample the training data----------
set.seed(50)
fraction <- 1.0        
y_est <- "AQValue"
# set.seed(42)
training <- data_all %>% mutate(ID=1:nrow(data_all)) %>% 
  sample_frac(fraction)
training <- training[order(training$ID),]
test <- (data_all %>% mutate(ID=1:nrow(data_all)))[-training$ID,]
training_x <- training %>% dplyr::select(matches("industry|road"))
test_x <- test %>% dplyr::select(matches("industry|road"))
training_y <- training %>% dplyr::select(y_est)
test_y <- test %>% dplyr::select(y_est)


#----------lasso regression-------------
set.seed(42)
fit <- glmnet::glmnet(as.matrix(training_x), training_y[,1],
                      lower.limits = 0,      #there is no sink for NO2 in the variables.
                      # type.measure = "mse",
                      alpha=1, family="gaussian", nlambda=100)
set.seed(42)
fit.cv <- glmnet::cv.glmnet(as.matrix(training_x), training_y[,1],
                            type.measure = "mse",
                            lower.limits = 0,
                            alpha=1, family="gaussian", nlambda=100) 

plot(fit, xvar="lambda", label=TRUE)

par(mar=c(2,2,1,8))
plot(fit, xvar="dev", label=TRUE)
vnat <- coef(fit)
vnat <- vnat[-1,ncol(vnat)]
axis(4, at=vnat, labels = names(vnat), line=-.5,las=1,tick=FALSE, cex.axis=0.8)

plot(fit.cv)
# how the lambda decreases the number of selected variables
# and the explained deviation
print(fit)

# result of deviation, df, and lambda
lassoResult <- data.frame(df=fit$df, dev=fit$dev.ratio, lambda=fit$lambda)
targetDF <- (lassoResult %>% filter(df==3))

set.seed(42)
best_lam <- targetDF[which.min(targetDF$lambda),]$lambda
userLasso <- glmnet::glmnet(as.matrix(training_x), training_y[,1],
                            lower.limits = 0,      #there is no sink for NO2 in the variables.
                            # type.measure = "mse",
                            alpha=1, family="gaussian", lambda = best_lam)
predName <- coef(userLasso)[-1,][which(coef(userLasso)[-1]!=0)] %>% names()
predCoef <- coef(userLasso)[-1][which(coef(userLasso)[-1]!=0)]
lur <- data.frame(predName=factor(predName, levels = predName), predCoef=predCoef)
intercept <- coef(userLasso)[1]

write.csv(lur, '../data/lur_lasso_norm_newData_1.csv', row.names = F)
write.csv(intercept, '../data/intercept_lasso_norm_newData_1.csv', row.names = F)
