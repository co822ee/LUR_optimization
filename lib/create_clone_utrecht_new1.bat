cd ..\data\predictor_normalize_area
mapattr -s -R 20 -C 20 -B -P yb2t -x -41380 -y 7041 -l 25.0008 clone_utrecht_new1.map
resample --clone clone_utrecht_new1.map road_class_1_500.map road_class_1_500_utrecht_new1.map
resample --clone clone_utrecht_new1.map road_class_M345_5000.map road_class_M345_5000_utrecht_new1.map 
resample --clone clone_utrecht_new1.map industry_5000.map industry_5000_utrecht_new1.map 

cd ..\TROPOMI_temis_laea
mapattr -s -R 20 -C 20 -B -P yb2t -x -41380 -y 7041 -l 25.0008 clone_utrecht_new1.map
resample --clone clone_utrecht_new1.map r_yrmean_na_12p5_25_ID.map r_yrmean_na_12p5_25_ID_utrecht_new1.map
resample --clone clone_utrecht_new1.map r_yrmean_na_12p5_25_ngb.map r_yrmean_na_12p5_25_ngb_utrecht_new1.map
pause