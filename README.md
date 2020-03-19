# Optimize LUR
Land-use regression (LUR) for modelling nitrogen dioxide (NO2) was optimized through assimilating both ground-based observations (point data) and satellite observations (block data). The ground-based sensor data was collected from the [air quality e-reporting database website][1], provided by the European Environment Agency (EEA). The TROPOMI VCDs were used and downloaded from the [Tropospheric Emission Monitoring Internet Service (TEMIS) website][2], hosted by the Royal Netherlands Meteorological Institute (KNMI, Koninklijk Nederlands Meteorologisch Instituut).

## lib & data
The [lib][3] folder contains the scripts for preprocessing, applying the Generalized Likelihood Uncertainty Estimation (GLUE), analyzing the uncertainty, and visualizing the results:

0. Preprocessing
1. Preprocessing & GLUE
2. GLUE
3. Uncertainty analysis

Due to various reasons, all the necessary preprocessed data created by the scripts is provided in the [data][4] folder. The clone map of the study area and the TROPOMI ID map can be found in [data.zip][5]. To run the scripts, except from the ones below, successfully, the data.zip need to be unzipped in the data directory.

| script     | reason      |
|--------------|-----------|
|0_0_predictor_createCloneMap.py| large size of the predictor maps|
|0_0_predictor_remove_mv.py| large size of the predictor maps|
|0_1_predictor_merge_road345.R| large size of the predictor maps|
|0_2_predictor_normalize.R| large size of the predictor maps|
|1_0_sensor_extract_TROPOMI_predictor.R|large size of the predictor maps|
|2_0_A_LURmodel_GLUE_stochastic_final.R|irreproducible because of the seeds|
|3_0_A_Uncertainty_allStudyArea.py|the processing time(the script still can be run with the data provided here.) |

If you're interested in accessing the raw raster maps of the predictor variables, they are available via the [Google Drive][6]. The size of the unzipped files are over 60GB.


### Acknowledgement
This research is my thesis at Utrecht University. I would like to first thank my supervisors, [Prof. dr. Derek Karssenberg][7] and [Dr. Meng Lu][8]. Every meeting with them gave me a different perspective towards the research and encouraged me to think more thoroughly about the research questions. The programming bugs I encountered during the process were fixed after discussing with Derek and Meng. They both provided critical feedbacks to improve the content of the thesis. I would like to thank [Dr. Oliver Schmitz][9] as well for providing the raster maps of the predictors and giving the technical support for modelling in the PCRaster framework. 

[1]:https://www.eea.europa.eu/data-and-maps/data/aqereporting-8#tab-figures-produced
[2]:http://www.temis.nl/
[3]:https://github.com/co822ee/LUR_optimization/tree/master/lib
[4]:https://github.com/co822ee/LUR_optimization/tree/master/data
[5]:https://github.com/co822ee/LUR_optimization/tree/master/data.zip
[6]:https://drive.google.com/drive/folders/1q4fKUZEa1srSaxFzVPwig5Q-pCs_U6Xy?usp=sharing
[7]:https://www.uu.nl/staff/DJKarssenberg
[8]:https://www.uu.nl/staff/mlu
[9]:https://www.uu.nl/staff/OSchmitz/Research%20output
