
import os
import numpy as np
import pandas
import csv
import math

from pcraster import *
from pcraster.framework import *

import time
time_start = time.clock()


#----------------------------------------------------
#----------------------------------------------------
#----------------------------------------------------
scenario = '../data_PF/PF_bothSensorAndTropomi'
print('scenario:',scenario)
# Create target Directory if don't exist
if not os.path.exists('../data_PF'):
  os.mkdir('../data_PF')
if not os.path.exists(scenario):
  os.mkdir(scenario)

start = int(input('What is the ID of the parameter combinations you want to start?\n'))
end = int(input('What is the ID of the parameter combinations you want to end?\n'))

#--------------------------------
#--------------------------------
#   PCRaster Framework
#--------------------------------
#--------------------------------

class LURmodel(DynamicModel, MonteCarloModel, ParticleFilterModel):
  def __init__(self):
    DynamicModel.__init__(self)
    MonteCarloModel.__init__(self)
    ParticleFilterModel.__init__(self)
    setclone(os.path.join('../data/predictor_normalize_area/cloneB.map'))

  def readmapbypath(self, filename):
    return readmap(os.path.join('../data/predictor_normalize_area/',filename))

  def generateNameTxt(self, filename, sampleNumber):
    return scenario+'/'+filename+"_" + str(sampleNumber) +".txt"

  def checkTxt(self, index):
    return os.path.isfile(scenario + "/" + 'lur_tropomi_train' + "_{}.txt".format(index))&os.path.isfile(
            scenario + "/" + 'lur_sensor_train' + "_{}.txt".format(index))&os.path.isfile(
            scenario + "/" + 'lur_tropomi_validate' + "_{}.txt".format(index))&os.path.isfile(
            scenario + "/" + 'lur_sensor_validate' + "_{}.txt".format(index))
    
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
    #---------- Read the predictor variable maps------------
    # The selected predictor variables' name
    coefsName = pandas.read_csv(os.path.join('../data/lur_lasso_norm_newData_1.csv'), 
                                     delimiter=',')['predName']
    # Read the selected predictor variables
    self.x1 = self.readmapbypath(coefsName[0]+'.map')
    self.x2 = self.readmapbypath(coefsName[1]+'.map')
    self.x3 = self.readmapbypath(coefsName[2]+'.map')
    # Read the simulated realizations of samples
    parameterValues = pandas.read_csv('../data/objF_stochastic12.csv', delimiter=',')
    self.aList = parameterValues['a']
    self.bList = parameterValues['b']
    self.cList = parameterValues['c']
    self.dList = parameterValues['d']
    self.hList = parameterValues['h']

    # Read the tropomi ID map
    self.tropomi_ID = nominal(readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ID.map'))


    #------- Read observation values and variance of measurement errors (tropomi & sensor) ----------
    self.tropomiTrainRowCol = pandas.read_csv('../data/tropomiTrain_colrow.csv')
    self.tropomiValidateRowCol = pandas.read_csv('../data/tropomiValidate_colrow.csv')
    
    self.sensorXY_train = pandas.read_csv('../data/sensorTrainData_all.csv')
    self.sensorXY_validate = pandas.read_csv('../data/sensorValidateData_all.csv')
    
    self.lur_tropomi_train_array = np.arange(len(self.tropomiTrainRowCol), dtype='float64')
    self.lur_tropomi_validate_array = np.arange(len(self.tropomiValidateRowCol), dtype='float64')
    
    self.sensor_train_array = np.arange(len(self.sensorXY_train), dtype='float64')    
    self.sensor_validate_array = np.arange(len(self.sensorXY_validate), dtype='float64')   
    
    self.count = start



  def initial(self):
    if self.checkTxt(self.count):
      self.count = self.count + 1
      print('\nTxt files of the sample {} already exist!'.format(self.count))
      pass
    else:
      print('\nRunning the initial for sample: ', self.count)
    # Knowing the simulation time every 50 simulations
      if self.currentSampleNumber()%50 == 0:
          print('{} runs in {:.2f} mins ({:.2f} hours)'.format(self.currentSampleNumber(), (time.clock()-time_start)/60, (time.clock()-time_start)/60/60))
    
    #---------- coefficient values -------------
      a = self.aList[self.count-1]
      b = self.bList[self.count-1]
      c = self.cList[self.count-1]
      d = self.dList[self.count-1]
      h = self.hList[self.count-1]
 
      #--------- LUR ------------
      lur = c + a*self.x1 + b*self.x2 + d*self.x3
      lur_tropomi = areaaverage(lur,self.tropomi_ID)/h
    
      #---------- Extract lur predictions (training) ----------  
      for i in range(0,len(self.lur_tropomi_train_array)):
#        print('i=',i)
        self.lur_tropomi_train_array[i] = getCellValue(lur_tropomi, 
                              int(self.tropomiTrainRowCol['row'][i]), 
                              int(self.tropomiTrainRowCol['col'][i]))
      
        if i < len(self.sensor_train_array):
          rowCol = self.pcr_coord(self.sensorXY_train['Longitude.laea'][i], 
                                  self.sensorXY_train['Latitude.laea'][i])
          self.sensor_train_array[i] = getCellValue(lur, rowCol[0], rowCol[1])
      
      np.savetxt(self.generateNameTxt('lur_tropomi_train',self.count), 
                 self.lur_tropomi_train_array,delimiter=',', fmt='%.6f')
      np.savetxt(self.generateNameTxt('lur_sensor_train',self.count), 
                 self.sensor_train_array,delimiter=',', fmt='%.6f')
      
      #---------- Extract lur predictions (validation) ----------  
      for i in range(0,len(self.lur_tropomi_validate_array)):
#      print('i=',i)
        self.lur_tropomi_validate_array[i] = getCellValue(lur_tropomi, 
                              int(self.tropomiValidateRowCol['row'][i]), 
                              int(self.tropomiValidateRowCol['col'][i]))
      
        if i < len(self.sensor_validate_array):
          rowCol = self.pcr_coord(self.sensorXY_validate['Longitude.laea'][i], 
                                  self.sensorXY_validate['Latitude.laea'][i])
          self.sensor_validate_array[i] = getCellValue(lur, rowCol[0], rowCol[1])
    
      np.savetxt(self.generateNameTxt('lur_tropomi_validate',self.count), 
                 self.lur_tropomi_validate_array,delimiter=',', fmt='%.6f')
      np.savetxt(self.generateNameTxt('lur_sensor_validate',self.count), 
                 self.sensor_validate_array,delimiter=',', fmt='%.6f') 
      
      self.count = self.count + 1


  def postmcloop(self):
    pass



# The amount of particles
sampleNumber=end-start+1

# Running MC simulation
myModel = LURmodel()
staticModel = StaticFramework(myModel)
mcModel = MonteCarloFramework(staticModel, sampleNumber)
mcModel.run()


# Print the simulation time
time_end = time.clock()
time_elapsed = (time_end - time_start)
print('{} runs in {:.0f} seconds'.format(sampleNumber, time_elapsed))      # second
print('{} runs in {:.2f} minutes'.format(sampleNumber, time_elapsed/60))   # minute
print('{} runs in {:.0f} hours'.format(sampleNumber, time_elapsed/60/60))      # hours

