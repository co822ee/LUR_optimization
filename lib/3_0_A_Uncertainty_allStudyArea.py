# -*- coding: utf-8 -*-
"""
Created on Mon Nov 18 09:39:37 2019
This script is for evaluating the uncertainty for the whole study area with 60% of training data (tropomi, sensor data) and 40% of validation data.
"""

import os
import numpy as np
import pandas

from pcraster import *
from pcraster.framework import *
import time
time_start = time.clock()

# Set the working directory as the path in which the script file is 
abspath = os.path.abspath('') ## String which contains absolute path to the script file
os.chdir(abspath)             ## Setting up working directory


scenarioInput = input('Which calibration setting do you wanna run? \n onlyTropomiTrainAll_500 \n onlySensorTrainAll_500 \n frontierTrainAll_500 \n')
scenario = str(scenarioInput)
location = 'all'

glueFilePath = '../data/GLUE'

print('scenario:',scenario)
# Create target Directory if don't exist
if not os.path.exists(os.path.join(glueFilePath, location+'_'+scenario)):
  os.mkdir(os.path.join(glueFilePath, location+'_'+scenario))

outputFilePath = os.path.join(glueFilePath, location+'_'+scenario)

objFile = os.path.join(glueFilePath, scenario +'.csv')
objList = pandas.read_csv(objFile, sep=',', dtype=np.float64)


class LURModel_validation(StaticModel, MonteCarloModel):
  def __init__(self, objList):
    StaticModel.__init__(self)
    MonteCarloModel.__init__(self)
    setclone('../data/predictor_normalize_area/cloneB.map')
    self.obj = objList
    
  def readmapbypath(self, filename):
    return readmap(os.path.join('../data/predictor_normalize_area',filename))

  def pcr_coord(self,xcoord, ycoord):
     """ this only works for known projection type and angle... """
     west = pcraster.clone().west()
     north = pcraster.clone().north()
     cellSize = pcraster.clone().cellSize()

     xCol = (xcoord - west) / cellSize
     yRow = (north - ycoord) / cellSize
     
     # The getCellValue() starts from 1, so 1 should be added to the col and row variables.
     col  = int(math.floor(xCol))+1
     row  = int(math.floor(yRow))+1

     return row, col
 
  def premcloop(self):
    # read the selected predictor variables
    coefsName = pandas.read_csv('../data/lur_lasso_norm_newData_1.csv', 
                                        delimiter=',')['predName']
        
    self.x1 = self.readmapbypath(coefsName[0]+'.map')
    self.x2 = self.readmapbypath(coefsName[1]+'.map')
    self.x3 = self.readmapbypath(coefsName[2]+'.map')
    
    self.tropomi = readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ngb.map')
    self.tropomi_ID = readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ID.map')
    
    self.tropomiTrainRowCol = pandas.read_csv('../data/tropomiTrain_colrow.csv')
    self.tropomiValidateRowCol = pandas.read_csv('../data/tropomiValidate_colrow.csv')
    
    self.sensorXY_train = pandas.read_csv('../data/sensorTrainData_all.csv')
    self.sensorXY_validate = pandas.read_csv('../data/sensorValidateData_all.csv')
    
    self.lur_tropomi_train_array = np.arange(len(self.tropomiTrainRowCol), dtype='float64')
    self.lur_tropomi_validate_array = np.arange(len(self.tropomiValidateRowCol), dtype='float64')
    
    self.sensor_train_array = np.arange(len(self.sensorXY_train), dtype='float64')    
    self.sensor_validate_array = np.arange(len(self.sensorXY_validate), dtype='float64')    
    

  def initial(self):
    nrOfSample = self.currentSampleNumber()
    a = self.obj['a'][nrOfSample-1]
    b = self.obj['b'][nrOfSample-1]
    d = self.obj['d'][nrOfSample-1]
    c = self.obj['c'][nrOfSample-1]
    h = self.obj['h'][nrOfSample-1]
    
    lur = c + a*self.x1 + b*self.x2 + d*self.x3
    lur_trop = lur/h
    lur_tropomi = areaaverage(lur, self.tropomi_ID)/h          # lur_tropomi in the unit of density column
    
#    self.report(lur, "lur")
    
    # Extract lur_tropomi values of each (training) tropomi block
    for i in range(len(self.tropomiTrainRowCol)):
      self.lur_tropomi_train_array[i] = getCellValue(lur_tropomi, 
                            int(self.tropomiTrainRowCol['row'][i]), int(self.tropomiTrainRowCol['col'][i]))
    np.savetxt(os.path.join(outputFilePath, 'lur_tropomi_train'+str(nrOfSample)+'.txt'),
                 self.lur_tropomi_train_array,delimiter=',')
      
    # Extract lur_tropomi values of each (validation) tropomi block
    for i in range(len(self.tropomiValidateRowCol)):
      self.lur_tropomi_validate_array[i] = getCellValue(lur_tropomi, 
                            int(self.tropomiValidateRowCol['row'][i]), int(self.tropomiValidateRowCol['col'][i]))
    np.savetxt(os.path.join(outputFilePath, 'lur_tropomi_validate'+str(nrOfSample)+'.txt'),
                 self.lur_tropomi_validate_array,delimiter=',')

    # Extract lur values at training monitoring stations
    for i in range(len(self.sensorXY_train)):
      rowCol = self.pcr_coord(self.sensorXY_train['Longitude.laea'][i], self.sensorXY_train['Latitude.laea'][i])
      self.sensor_train_array[i] = getCellValue(lur, rowCol[0], rowCol[1])
    np.savetxt(os.path.join(outputFilePath, 'lur_sensor_train'+str(nrOfSample)+'.txt'),
                 self.sensor_train_array,delimiter=',')
        
    # Extract lur values at training monitoring stations
    for i in range(len(self.sensorXY_validate)):
      rowCol = self.pcr_coord(self.sensorXY_validate['Longitude.laea'][i], self.sensorXY_validate['Latitude.laea'][i])
      self.sensor_validate_array[i] = getCellValue(lur, rowCol[0], rowCol[1])
    np.savetxt(os.path.join(outputFilePath,'lur_sensor_validation'+str(nrOfSample)+'.txt'),
                 self.sensor_validate_array,delimiter=',')

    
  def postmcloop(self):
     pass
#    names = ["lur"]
#    sampleNumbers = self.sampleNumbers()
#    # Becuase the lur map is a static map, a list containing one zero element should be provided.
#    timeSteps = [0]
#    print(sampleNumbers)    
#    mcaveragevariance(names, sampleNumbers, timeSteps)
#    percentiles=[0.1,0.4,0.7,0.9,0.95,975,0.99]
#    percentiles=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,975]
#    mcpercentiles(names,percentiles,sampleNumbers,timeSteps)
    

nrOfSamples = len(objList)
myModel = LURModel_validation(objList)
staticModel = StaticFramework(myModel)
mcModel = MonteCarloFramework(staticModel, nrOfSamples)
mcModel.run()

time_end = time.clock()
time_elapsed = (time_end - time_start)
print('{} runs in {:.0f} seconds'.format(nrOfSamples, time_elapsed))      # second
print('{} runs in {:.2f} minutes'.format(nrOfSamples, time_elapsed/60))   # minute
print('{} runs in {:.0f} hours'.format(nrOfSamples, time_elapsed/60/60))      # hours

