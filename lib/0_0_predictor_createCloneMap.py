# -*- coding: utf-8 -*-
"""
Created on Fri Oct 18 16:57:16 2019
Create clone maps indicating the mv with FASLE/0

@author: Youchen Shen
"""
import os
from pcraster import *

# Set the working directory as the path in which the script file is 
abspath = os.path.abspath('') ## String which contains absolute path to the script file
os.chdir(abspath)             ## Setting up working directory

predictor_map=readmap(os.path.join('../data/raw_data/predictor_map/industry_100.map'))
# Replace the mv values with boolean 0 and the remaining pixels have a value of boolean 1. 
predictor_mapNoMV = cover(predictor_map, scalar(0))
mvBoolean = predictor_map==predictor_mapNoMV
mvBoolenaCover = cover(mvBoolean, boolean(0))
#aguila(mvBoolean)
#aguila(mvBoolenaCover)
mvScalar = ifthenelse(mvBoolenaCover, scalar(1), scalar(0))
#aguila(mvScalar)

report(mvBoolenaCover,os.path.join('../data/predictor_normalize_area/cloneB.map'))
report(mvScalar,os.path.join('../data/predictor_normalize_area/cloneS.map'))
