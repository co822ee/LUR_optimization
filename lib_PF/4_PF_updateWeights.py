import os
import numpy as np
import pandas
import csv
import math

from pcraster import *
from pcraster.framework import *

import time
time_start = time.clock()

tropomiArray_train = np.loadtxt('../data/tropomiInTropomiTBlock.txt')
sensorTrain = pandas.read_csv('../data/sensorTrainData_all.csv',delimiter=',')
meanSensor_train = sensorTrain['AQValue'].mean()
#----------------------------------------------------
#----------------------------------------------------
#          Generate variance of measurement error
#----------------------------------------------------
#----------------------------------------------------
errorSetting = ''          # Type in the name for your error setting
sensorErrVar_train = (0.15*meanSensor_train)**2
sensorErrVarArray_train = np.repeat(sensorErrVar_train, len(sensorTrain))
tropomiErrVarArray_train = (0.5+0.5*tropomiArray_train)**2

np.savetxt('../data_PF/sensorTrainErrVar_'+errorSetting+'.txt', sensorErrVarArray_train)
np.savetxt('../data_PF/tropomiTrainErrVar_'+errorSetting+'.txt', tropomiErrVarArray_train)

np.savetxt('../data_PF/observationTrainErrVar_'+errorSetting+'.txt', 
            np.concatenate((sensorErrVarArray_train, tropomiErrVarArray_train)))

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


  def premcloop(self):
    #------- Read observation values and variance of measurement errors (tropomi & sensor) ----------
    self.tropomiArray_train = np.loadtxt('../data/tropomiInTropomiTBlock.txt')          # 639 elements
    self.sensorArray_train = np.array(pandas.read_csv('../data/sensorTrainData_all.csv',delimiter=',')['AQValue'])         # 38 elements

    self.lur_tropomi_train = pandas.read_csv('../data_PF/PF_bothSensorAndTropomi/evaluation_allOutputData/all/lurTropomiBlocks_training_all.csv')
    self.sensor_train = pandas.read_csv('../data_PF/PF_bothSensorAndTropomi/evaluation_allOutputData/all/lurAtSensorLocations_training_all.csv')



  def initial(self):
     pass    
  def dynamic(self):
    pass

  def postmcloop(self):
    pass

  def suspend(self):
    pass

  def updateWeight(self):

    count=self.currentSampleNumber()
    print('sample number: ', count)

    # Load the variance of the observation errors (sensor & tropomi)
    varObsErr = np.loadtxt('../data_PF/observationTrainErrVar_'+errorSetting+'.txt')
    # Covariance matrix of the measurement errors
    covarObsErr = np.matrix(np.diag(varObsErr))
#    print('sample',self.count,'with covarObsErr', covarObsErr)
#    print('len(covarObsErr)=',len(covarObsErr))
    
    # Vector of the observations (np array)
    # Both sensor values and tropomi pixel values
    Hx = np.concatenate((self.sensorArray_train,self.tropomiArray_train))
    print(len(Hx))
    # Vector of the lur predictions 
    y = np.concatenate((self.sensor_train.iloc[count-1][:len(self.sensor_train.columns)-1],
                        self.lur_tropomi_train.iloc[count-1][:len(self.lur_tropomi_train.columns)-1]))
    print(len(y))

    # obs minus model state
    obsMinusModel=Hx-y
#    print('obsMinusModel')
#    print(obsMinusModel)
     
    # inverse covar matrix
    b = numpy.matrix(covarObsErr).I
    inverseCovar = np.array(b)
#    print('inverse covar matrix')
#    print(inverseCovar)
     
    # first term
    # np.dot: dot product of two arrays
    # .T: transposed array
    firstTerm = np.dot(obsMinusModel.T,inverseCovar)
#    print('first term:')
#    print(firstTerm)
    
    # total
    sumF = np.dot(firstTerm,obsMinusModel)/2.0
    weightFloatingPoint = math.exp(0-sumF)
#    print('sumF, weight:')
#    print('observations, model state, sumF, weight:')
#    print(Hx)
#    print(y)
#    print(sumF, ',', weightFloatingPoint)

    # This returns the weight of the MC sample to the PCRaster framework
    # Using these weights PCRaster will do the resampling
    return weightFloatingPoint
    
  def resume(self):
    pass
#    print('resume section\n')
    # Read the state variables before the first time step of a filter period
    # The updated variables are read from the state variable directory



# The amount of particles
sampleNumber = len(pandas.read_csv('../data_PF/PF_bothSensorAndTropomi/evaluation_allOutputData/all/lurTropomiBlocks_training_all.csv'))

# Running MC simulation
myModel = LURmodel()
dynamicModel = DynamicFramework(myModel, lastTimeStep=2, firstTimestep=1)
mcModel = MonteCarloFramework(dynamicModel, sampleNumber)
pfModel = SequentialImportanceResamplingFramework(mcModel)
pfModel.setFilterTimesteps([1])
pfModel.run()


# Print the simulation time
time_end = time.clock()
time_elapsed = (time_end - time_start)
print('{} runs in {:.0f} seconds'.format(sampleNumber, time_elapsed))      # second
print('{} runs in {:.2f} minutes'.format(sampleNumber, time_elapsed/60))   # minute
print('{} runs in {:.0f} hours'.format(sampleNumber, time_elapsed/60/60))      # hours

#--------------------------------
#--------------------------------
#   Write the updated coefficient values
#--------------------------------
#--------------------------------
update = pandas.read_csv("filterSIR_1.csv", delimiter=';')
coefs =pandas.read_csv('../data/objF_stochastic12.csv', delimiter=',')

g=open('../data_PF/coefList_PF_updated_'+errorSetting+'.txt', 'w')
g.write('index' + '\t' + 'a' + '\t' + 'b' + '\t' + 'd' + '\t' + 'c' + '\t' + 'h' + '\n')

#update.shape[0]  #nr of row
#update.shape[1]  #nr of column

# write the updated coefList_PF.txt
print('Writing the updated coefList_PF.txt')
for i in range(0,update.shape[0]):
 for j in range(0,update['resampled particles'][i]):
   g.write("{}".format(update["sample"][i]) + '\t' + "{:.8f}".format(coefs['a'][i]) + '\t' + "{:.8f}".format(coefs['b'][i]) +
           '\t' + "{:.8f}".format(coefs['d'][i]) + '\t' + "{:.4f}".format(coefs['c'][i]) + '\t' + "{:.4f}".format(coefs['h'][i]) + "\n")


g.close()
