# -*- coding: utf-8 -*-
"""
Created on Fri Oct 18 12:01:09 2019
Replace the mv in the predictor maps with zero

@author: Youchen Shen
"""
import os
from pcraster import *
# Set the working directory as the path in which the script file is 
abspath = os.path.abspath('') ## String which contains absolute path to the script file
os.chdir(abspath)             ## Setting up working directory

inputFolder = '../data/TROPOMI_temis_laea'
outputFolder = '../data/TROPOMI_temis_laea'

setclone('../data/predictor_normalize_area/industry_100.map')

train_scalar = readmap(os.path.join(inputFolder, 'scalar_train_25.map'))

tropomi_ID = readmap(os.path.join(inputFolder, 'r_yrmean_na_12p5_25_ID.map'))
tropomi = readmap(os.path.join(inputFolder, 'r_yrmean_na_12p5_25_ngb.map'))

tropomi_ID = ordinal(tropomi_ID)
train_boolean = boolean(train_scalar)
#validation_boolean = ifthenelse(train_boolean, boolean(0), boolean(1))

report(train_boolean, os.path.join(outputFolder, 'boolean_train_25_new_t.map'))


