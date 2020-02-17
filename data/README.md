# Data
This folder contains both raw data [(raw_data)][1] of both sensor data and TROPOMI data. 
To save the user's time or due to some data that is irreproducible, some intermediate data is already included and is shown in the table below:
| data               | script       |
|------------------- |------------|
|NO2_data.csv        |0_sensor_preprocess_data.R |
|data_laea_new_correctTropomi.csv|1_0_sensor_extract_TROPOMI_predictor.R|
|objF_stochastic12.csv|2_1_A_stochastic_result.R|
|txt files in GLUE/stochastic_01 & GLUE/stochastic_02|2_0_A_LURmodel_GLUE_stochastic_final.py|
|tropomiTrain_colrow.csv & tropomiValidate_colrow.csv|1_tropomi_0_row_col.R|

Because the script of producing tropomiTrainID.map & tropomiValidateID.map is lost, tropomiTrain_colrow.csv & tropomiValidate_colrow.csv are required and the script 1_tropomi_0_row_col.R cann't be run unless the tropomiTrainID.map & tropomiValidateID.map are downloaded from [Google Drive][2].


[1]:https://github.com/co822ee/LUR_optimization/tree/master/data/raw_data
[2]: