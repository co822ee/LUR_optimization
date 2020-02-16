# Extract the column and row numbers of each pixel
# --------------------------------------------------------------
# input | tropomiTrainID.map      & tropomiValidateID.map
# output| tropomiTrain_colrow.csv & tropomiValidate_colrow.csv
# --------------------------------------------------------------
library(raster)
library(dplyr)
library(pbapply)


findRowCol <- function(id){
    if((id%%ncol(tropomiValidate))==0){
        row_id <- id/ncol(tropomiValidate)
        col_id <- ncol(tropomiValidate)
    }else{
        row_id <- id%/%ncol(tropomiValidate)+1
        col_id <- id%%ncol(tropomiValidate)
    }
    c(row_id, col_id) %>% as.matrix() %>% t()
}

tropomiTrain <- raster('../data/TROPOMI_temis_laea/tropomiTrainID.map')
tropomiValidate <- raster('../data/TROPOMI_temis_laea/tropomiValidateID.map')
tropomiTrain_m <- as.matrix(tropomiTrain)
tropomiValidate_m <- as.matrix(tropomiValidate)

id_25 <- matrix(1:(ncell(tropomiTrain)), ncol=ncol(tropomiTrain),
                nrow=nrow(tropomiTrain),byrow = T)

cellIDtrain <- id_25[which(tropomiTrain_m!=0)]       # length: 639
cellIDvalidate <- id_25[which(tropomiValidate_m!=0)] # length: 427

# The row and col index for the tropomi
c(cellIDtrain[1]%/%ncol(tropomiValidate)+1, cellIDtrain[1]%%ncol(tropomiValidate))
c(cellIDvalidate[16]%/%ncol(tropomiValidate)+1, cellIDvalidate[16]%%ncol(tropomiValidate))

rowColTrain <- pblapply(cellIDtrain, findRowCol)
rowColTrain <- do.call(rbind, rowColTrain)
rowColTrain <- rowColTrain %>% as.data.frame() %>% rename(row=V1,col=V2) %>%
    mutate(col=ifelse(col==0,ncol(tropomiValidate),col))
rowColTrain <- rowColTrain[order(rowColTrain$row),] %>% mutate(ID=1:nrow(rowColTrain))

rowColValidate <- pblapply(cellIDvalidate, findRowCol)
rowColValidate <- do.call(rbind, rowColValidate)
rowColValidate <- rowColValidate %>% as.data.frame() %>% rename(row=V1,col=V2) %>%
    mutate(col=ifelse(col==0,ncol(tropomiValidate),col))
rowColValidate <- rowColValidate[order(rowColValidate$row),] %>% mutate(ID=1:nrow(rowColValidate))

write.csv(rowColTrain, "../data/tropomiTrain_colrow.csv", row.names = F)
write.csv(rowColValidate, "../data/tropomiValidate_colrow.csv", row.names = F)
