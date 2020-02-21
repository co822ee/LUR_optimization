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
    setclone('../data/predictor_normalize_area/clone_utrecht_new.map')
    self.obj = objList
    
  def readmapbypath(self, filename):
    return readmap(os.path.join('../data/predictor_normalize_area',filename))


 
  def premcloop(self):
    # read the selected predictor variables
    coefsName = pandas.read_csv('../data/lur_lasso_norm_newData_1.csv', 
                                        delimiter=',')['predName']
        
    self.x1 = self.readmapbypath(coefsName[0]+'_utrecht_new.map')
    self.x2 = self.readmapbypath(coefsName[1]+'_utrecht_new.map')
    self.x3 = self.readmapbypath(coefsName[2]+'_utrecht_new.map')
    
    self.tropomi = readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ngb_utrecht_new.map')
    self.tropomi_ID = nominal(readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ID_utrecht_new.map'))
    

  def initial(self):
    nrOfSample = self.currentSampleNumber()
    a = self.obj['a'][nrOfSample-1]
    b = self.obj['b'][nrOfSample-1]
    d = self.obj['d'][nrOfSample-1]
    c = self.obj['c'][nrOfSample-1]
    h = self.obj['h'][nrOfSample-1]
    
    lur = c + a*self.x1 + b*self.x2 + d*self.x3
    lur_tropomi = areaaverage(lur, self.tropomi_ID)/h          # lur_tropomi in the unit of density column
    
    self.report(lur, "lur")
    self.report(lur_tropomi, "lurT")
    
    
    
  def postmcloop(self):
     
    names = ["lur"]
    sampleNumbers = self.sampleNumbers()
    # Becuase the lur map is a static map, a list containing one zero element should be provided.
    timeSteps = [0]
    print(sampleNumbers)    
    mcaveragevariance(names, sampleNumbers, timeSteps)
#    percentiles=[0.1,0.9,0.95,975,0.99]
#    percentiles=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,975]
#    mcpercentiles(names, percentiles, sampleNumbers, timeSteps)
    

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

