# Preprocessing ambient NO2 cocentrations from the sensor data 
# 2019/10/24
# Original data: metadata.csv & data_annualAverage.csv
# ------------------------------------------------------------------------------------------------------
# The NO2 data, which was downloaded from EEA website of air quality statistics calculated by the EEA
# http://aidef.apps.eea.europa.eu/?source=%7B%22query%22%3A%7B%22bool%22%3A%7B%22must%22%3A%5B%7B%22term%22%3A%7B%22CountryOrTerritory%22%3A%22Netherlands%22%7D%7D%2C%7B%22term%22%3A%7B%22Pollutant%22%3A%22Nitrogen%20dioxide%20(air)%22%7D%7D%2C%7B%22term%22%3A%7B%22ReportingYear%22%3A%222017%22%7D%7D%2C%7B%22term%22%3A%7B%22AggregationType%22%3A%22Annual%20mean%20%2F%201%20calendar%20year%22%7D%7D%2C%7B%22query_string%22%3A%7B%22query%22%3A%22netherlands%20nitrogen%22%2C%22default_operator%22%3A%22OR%22%2C%22analyze_wildcard%22%3Atrue%7D%7D%5D%7D%7D%2C%22display_type%22%3A%22tabular%22%7D
# Accessed at 24/10/2019
# country of the Netherlands | year of 2017 | Nitrogen dioxide (air) 
# Annual mean / 1 calendar year 
# Clean and combine the annual mean NO2 concentrations (ug.m-3) with the metadata 
# Output the result data as NO2_data.csv
# ------------------------------------------------------------------------------------------------------
library(here)
library(dplyr)
library(raster)

# Input
meta <- read.csv("../data/raw_data/metadata.csv")
annualAvg <- read.csv('../data/raw_data/data_annualAverage.csv')
# Output
output_csv <- '../data/NO2_data.csv'

# Clean and combine the annual data and metadata
meta <- meta %>% filter(Countrycode=="NL")
meta <- meta %>% filter(AirPollutant=="NO2")
meta_new <- meta[!duplicated(meta$AirQualityStationNatCode),]
meta_new %>% names()
d=6

meta_clean <- meta_new %>% dplyr::select(AirQualityStationNatCode, Longitude, Latitude,  
                                         AirQualityStationType, AirQualityStationArea) %>% 
    mutate(Latitude=round(Latitude, digits = d), Longitude=round(Longitude, digits = d))
annualAvg_clean <- annualAvg %>% dplyr::select(SamplingPoint_Longitude, SamplingPoint_Latitude, 
                                               AQValue) %>% 
    rename(.,Longitude=SamplingPoint_Longitude, Latitude=SamplingPoint_Latitude) %>% 
    mutate(Latitude=round(Latitude, digits = d), Longitude=round(Longitude, digits = d))
joint <- dplyr::inner_join(meta_clean, annualAvg_clean, by=c("Longitude", "Latitude"))
# Note: The longitude and latitude are in the EPSG:4979 coordinate system.
write.csv(joint, output_csv, row.names = F)

