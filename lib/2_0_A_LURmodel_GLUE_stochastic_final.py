# -*- coding: utf-8 -*-
"""
This script is to generate the parameter values from the uniform distributions, 
to calculate the RMSE between the TROPOMI pixel values and the corresponding average LUR predictions.
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

outputFolder = '../data/GLUE'

#--------------------------------
#--------------------------------
#   PCRaster framework
#--------------------------------
#--------------------------------

class LURmodel(StaticModel, MonteCarloModel):
  def __init__(self):
    StaticModel.__init__(self)
    MonteCarloModel.__init__(self)
    
    setclone('../data/predictor_normalize_area/cloneB.map')

  def readmapbypath(self, filename):
    return readmap(os.path.join('../data/predictor_normalize_area',filename))

  def premcloop(self):
    # The coefficient
    coefsName = pandas.read_csv('../data/lur_lasso_norm_newData_1.csv', 
                                     delimiter=',')['predName']
    
    # read the selected predictor variables
    self.x1 = self.readmapbypath(coefsName[0]+'.map')
    self.x2 = self.readmapbypath(coefsName[1]+'.map')
    self.x3 = self.readmapbypath(coefsName[2]+'.map')
    
    # read the tropomi ID map
    self.tropomi_ID = readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ID.map')
    # read the tropomi data (tropospheric column density)
    self.tropomi = readmap('../data/TROPOMI_temis_laea/r_yrmean_na_12p5_25_ngb.map')
    # read the boolean map, which indicates the training pixels in lur resolution
    self.train_boolean = readmap('../data/TROPOMI_temis_laea/boolean_train_25_new.map')
    
    
    # Create id for lur pixels
    u = uniqueid(boolean(1))              # uniqueid creates id value for each Boolean TRUE cell
    # Find the max id of lur in each tropomi pixel
    a = areamaximum(u, self.tropomi_ID)  
    # Create a boolean which returns true in the last lur pixels in each tropomi pixel
    self.locs = pcreq(u,a) # this creates a true in one cell for each tropomi block
    # Indentify the training pixels in tropomi
    self.locs_new = ifthenelse(self.train_boolean & self.locs, self.locs, boolean(0))
    # The number of the tropomi pixels
    self.nrOfTropomiPixels = maptotal(ifthenelse(self.locs_new, scalar(1), scalar(0)))
    
    self.tropomi_ID_new = ifthen(self.train_boolean, self.tropomi_ID)
    
    
  def initial(self):
    # Identify the sample number to extract the coefficient values from the self.coefs (coef_list.txt)
    currentSample= self.currentSampleNumber()
    print('running the Monte Carlo for sample: ', currentSample)
    if currentSample%50 == 0:
        print('{} runs in {:.2f} mins ({:.2f} hours)'.format(currentSample, (time.clock()-time_start)/60, (time.clock()-time_start)/60/60))
    
    # Parameter coefficients
    a = 0.00005 + mapuniform()*(0.001-0.00005)      # x1 coefficients  (0.00005, 0.001)
    b = 0.01 + mapuniform()*(1.2-0.01)              # x2  (0.01, 1.2)
    d = 0.001 + mapuniform()*(0.1-0.001)            # x3   (0.001,0.1)
    c = 12 + mapuniform()*(20-12)                   # intercep (12, 20)
    h = 1.5 + mapuniform()*(3.0-1.5)                # column-to-surface ratio (1.5, 3.0)
    
    # LUR
    lur = c + a*self.x1 + b*self.x2 + d*self.x3
    
    # average the lur pixel values over tropomi pixel
    lur_tropomi = areaaverage(ifthen(self.train_boolean, lur), self.tropomi_ID_new)
    lur_tropomi_locs = ifthen(self.locs_new, lur_tropomi)
    
    dev_2 = ( self.tropomi * h - lur_tropomi_locs )**2
    objF = ( maptotal(dev_2) / self.nrOfTropomiPixels )**(0.5)    

    f.write('{:.8f}'.format(getCellValue(a,1,1)) + '\t' + '{:.8f}'.format(getCellValue(b,1,1)) + '\t' 
            + '{:.8f}'.format(getCellValue(d,1,1)) + '\t' + '{:.4f}'.format(getCellValue(c,1,1)) + '\t' 
            + '{:.4f}'.format(getCellValue(h,1,1)) + '\t'
            + '{:.4f}'.format(getCellValue(objF, 1, 1)))
    f.write('\n')
    if currentSample== sampleNumber:
      f.close()

  def postmcloop(self):
    pass
  
#--------------------------------
#--------------------------------
#--------------------------------
#--------------------------------

# Define the index for the result txt file
objIndex = input("What is the index for your objList txt file?\n")
objList = 'objF_b_stochastic_'+objIndex+'.txt'

f=open(os.path.join(outputFolder, objList), 'w')
f.write('a' + '\t' + 'b' + '\t' + 'd' + '\t' + 'c' + '\t' + 'h' + '\t' + 'rmse' + '\n')

# Determine the number of samples to run
sampleNumber = int(input("How many sample numbers do you want to run?\n"))

# Run MC simulation
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
print(objList+" were created!\n")
