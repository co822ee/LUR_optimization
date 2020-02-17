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

Because the script of producing tropomiTrainID.map & tropomiValidateID.map is lost, tropomiTrain_colrow.csv & tropomiValidate_colrow.csv are required to run the subsequent scripts, but  tropomiTrainID.map & tropomiValidateID.map are still available, and they're in the zip file: [tropomiID_map.zip][2]

In addition, because we didn't set seed for generating parameter samples in  [2_0_A_LURmodel_GLUE_stochastic_final.py][3], it is also irreproducible, and therefore the corresponding results are provided in the folders of [GLUE/stochastic_01][4] & [GLUE/stochastic_02][5].



[1]:https://github.com/co822ee/LUR_optimization/tree/master/data/raw_data
[2]:https://github.com/co822ee/LUR_optimization/blob/master/data/TROPOMI_temis_laea/tropomiID_map.zip
[3]:https://github.com/co822ee/LUR_optimization/blob/master/lib/2_0_A_LURmodel_GLUE_stochastic_final.py
[4]:https://github.com/co822ee/LUR_optimization/tree/master/data/GLUE/stochastic_01
[5]:https://github.com/co822ee/LUR_optimization/tree/master/data/GLUE/stochastic_02