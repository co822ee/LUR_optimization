@echo off

for %%i in (*.grd) do gdal_translate -ot Float32 -of PCRaster -mo PCRASTER_VALUESCALE=VS_SCALAR %%i %%i.map


