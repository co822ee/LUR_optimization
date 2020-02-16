# Optimize LUR
Land-use regression (LUR) for modelling nitrogen dioxide (NO2) is optimized through assimilating both ground-based observations (point data) and satellite observations (block data). The ground-based sensor data was collected from the [air quality e-reporting database website][1]. The TROPOMI VCDs were used and downloaded from the [Tropospheric Emission Monitoring Internet Service (TEMIS) website][2].

The [lib][3] folder contains the scripts for preprocessing, applying the Generalized Likelihood Uncertainty Estimation (GLUE), analyzing the uncertainty, and visualizing the results:

0. Preprocessing
1. Preprocessing & GLUE
2. GLUE
3. Uncertainty analysis


[1]:https://www.eea.europa.eu/data-and-maps/data/aqereporting-8#tab-figures-produced
[2]:http://www.temis.nl/
[3]:https://github.com/co822ee/LUR_optimization/tree/master/lib
