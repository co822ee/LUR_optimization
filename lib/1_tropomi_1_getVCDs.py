# -*- coding: utf-8 -*-
"""
Created on Mon Nov 18 15:55:48 2019
Extract the TROPOMI VCDs from every pixel

@author: Youchen Shen
"""
import numpy as np
import pandas
from pcraster import *
from pcraster.framework import *

# Set the working directory as the path in which the script file is 
abspath = os.path.abspath('') ## String which contains absolute path to the script file
os.chdir(abspath)             ## Setting up working directory

setclone(os.path.join('../data/predictor_withoutMV/cloneB.map'))
tropomi = readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ngb.map')
tropomi_colRow_train = pandas.read_csv('../data/tropomiTrain_colrow.csv')
tropomi_colRow_validate = pandas.read_csv('../data/tropomiValidate_colrow.csv')

tropomi_train_array = np.arange(len(tropomi_colRow_train), dtype='float64')
tropomi_validate_array = np.arange(len(tropomi_colRow_validate), dtype='float64')

tropomiID_train_array = np.arange(len(tropomi_colRow_train), dtype='int32')
tropomiID_validate_array = np.arange(len(tropomi_colRow_validate), dtype='int32')
tropomi_ID = readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ID.map')

# get VCDs 
for i in range(len(tropomi_colRow_train)):
  row = int(tropomi_colRow_train['row'][i])
  col = int(tropomi_colRow_train['col'][i])
  tropomi_train_array[i] = getCellValue(tropomi, row, col)
  tropomiID_train_array[i] = getCellValue(tropomi_ID, row, col)
  
for i in range(len(tropomi_colRow_validate)):
  row = int(tropomi_colRow_validate['row'][i])
  col = int(tropomi_colRow_validate['col'][i])
  tropomi_validate_array[i] = getCellValue(tropomi, row, col)
  tropomiID_validate_array[i] = getCellValue(tropomi_ID, row, col)
    
np.savetxt('../data/tropomiInTropomiTBlock.txt',tropomi_train_array,delimiter=',')
np.savetxt('../data/tropomiInTropomiVBlock.txt',tropomi_validate_array,delimiter=',')


np.savetxt('../data/tropomiID_TropomiTrain.txt',tropomiID_train_array,delimiter=',')
np.savetxt('../data/tropomiID_TropomiValidate.txt',tropomiID_validate_array,delimiter=',')


