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

inputFolder = '../data/raw_data/predictor_map'
outputFolder = '../data/predictor_withoutMV'

setclone('../data/raw_data/predictor_map/industry_100.map')

fileName = os.listdir(inputFolder)

# Remove .aux.xml file names
for i in range(0,len(fileName)):
    fileName[i]=fileName[i].replace('.aux.xml','')
fileName = list(dict.fromkeys(fileName))       ## Remove duplicated file names


print('There are {} predictor maps.'.format(len(fileName)))
print('file name:', fileName)

# Replace mv with zero
for name in fileName:
    predMap = readmap(os.path.join(inputFolder, name))
    newMap = cover(predMap, scalar(0))
    report(newMap, os.path.join(outputFolder, name))


