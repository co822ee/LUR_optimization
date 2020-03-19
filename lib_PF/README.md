
**1_PF_saveLURPrediction.py** runs simulations of the 48600 realizations (saved in ../data/objF_stochastic12.csv) and saves the LUR predictions at sensor locations as well as the predictions that aggregate over TROPOMI pixels. The predictions are saved as txt files in ../data_PF/PF_bothSensorAndTropomi/all. The **2_PF_predictionResult.R** and **3_PF_predictionResult_combineAllFile.R** combine and save the txt files as csv files in ../data_PF/PF_bothSensorAndTropomi/evaluation_allOutputData.  

Then the **4_PF_updateWeights.py** updates particle weights based on the observation errors and the predictions, which are saved as csv files from 3_PF_predictionResult_combineAllFile.R. In the python script, you can define the name of your observation error setting in line 21, and change the error of sensor data in line 22 and the error of satellite data in line 24. The script then generates a txt file coefList_PF_updated_**yourErrorSettingName**.txt in ../data_PF. 

After getting the updated parameter values from 4_PF_updateWeights.py, **5_analyze_PF_result_all_errorSettings.R** visualize the updated values from different observation error settings.


Because running 1_PF_saveLURPrediction.py is too time-consuming, the results of csv files from 3_PF_predictionResult_combineAllFile.R can be downloaded via [Google drive][1]. After downloading, please then save the csv files in ../data_PF/PF_bothSensorAndTropomi/evaluation_allOutputData. After putting the csv files in the right directory, 4_PF_updateWeights.py and 5_analyze_PF_result_all_errorSettings.R can be run subsequently. The other necessary files for running 4_PF_updateWeights.py and 5_analyze_PF_result_all_errorSettings.R without running the preprocessing script in ../[lib][2] can be downloaded [here][3] (Download the data folder and unzip in ../data). If you want to run 1_PF_saveLURPrediction.py, please note that the preprocessing scripts in ../[lib][2] should be run beforehand. 


[1]:https://drive.google.com/drive/folders/16BpKl7zazw1lc9XU6k-D8POHW6elFvrv?usp=sharing
[2]:https://github.com/co822ee/LUR_optimization/tree/master/lib
[3]:https://drive.google.com/drive/folders/1auFcYsEcW2n49ejPe5J5dJeR49sMlqWh?usp=sharing