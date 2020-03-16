
**1_PF_saveLURPrediction.py** runs simulations of the 48600 realizations (saved in ../data/objF_stochastic12.csv) and saves the LUR predictions at sensor locations as well as the predictions that aggregate over TROPOMI pixels. The predictions will be saved as txt files in ../data_PF/PF_bothSensorAndTropomi. The **2_PF_predictionResult.R** will then combine and save the txt files as csv files in ../data_PF/PF_bothSensorAndTropomi/evaluation_allOutputData.    
Because the tiime it takes to run 1_PF_saveLURPrediction.py is too long, the results of csv files from 2_PF_predictionResult.R can be downloaded via [Google drive][1]. After downloading, please then save the csv files in ../data_PF/PF_bothSensorAndTropomi/evaluation_allOutputData.



[1]:https://drive.google.com/drive/folders/16BpKl7zazw1lc9XU6k-D8POHW6elFvrv?usp=sharing