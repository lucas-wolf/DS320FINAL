library(readxl)
library(data.table)
library(dplyr)

#bring in data
Crop_Data <- read_excel("CropData_2010_2021.xlsx")
precipitation <- read_excel("precipitation.xlsx")
precip_anomaly <- read.csv("global-precipitation-anomaly.csv")

#select top 10 crops
selected_crops <- c('Tomatoes', 'Cucumbers and gherkins', 'Sugar cane', 'Cabbages', 'Carrots and turnips', 
                    'Chillies and peppers, green (Capsicum spp. and Pimenta spp.)', 'Potatoes', 
                    'Onions and shallots, dry (excluding dehydrated)', 'Eggplants (aubergines)', 'Watermelons')

#reduce data to top 10 crops
Crop_Data <- as.data.frame(Crop_Data)
Crop_Data <- Crop_Data[Crop_Data$Item %in% selected_crops, ]

#select necessary columns
columns <-c("Area","Item","Year","Unit","Value")
Crop_Data <- Crop_Data[, columns]


#begin normalizing data

#find range
range <- max(precip_anomaly$Global.precipitation.anomaly) - min(precip_anomaly$Global.precipitation.anomaly)

#scale data by dividing it by range
precip_anomaly$normalized.anomaly <- precip_anomaly$Global.precipitation.anomaly / range
precip_anomaly <- subset(precip_anomaly, Year > 1999)
precip_anomaly <- precip_anomaly[, c("Year" ,"normalized.anomaly")]

#add 1 so that we can simply multiply it throughout our precipitation data
precip_anomaly$normalized.anomaly <- precip_anomaly$normalized.anomaly + 1

#subset to the data that needs to be scaled
precipitation_subset <- precipitation[, as.character(seq(2000,2019))]


precip_anomaly$Year <- as.character(precip_anomaly$Year)

precip_anomaly_t <- t(precip_anomaly[, 2])

# Set first column as column names
colnames(precip_anomaly_t) <- precip_anomaly[, 1]

# precipitation_subset[1] <-precipitation_subset[1] * precip_anomaly_t[1]

for (x in 1:20){
  precipitation_subset[x] <-precipitation_subset[x] * precip_anomaly_t[x]
}

precipitation_final <- cbind(precipitation[1],precipitation[2],precipitation[3],precipitation[4],precipitation_subset,precipitation[25])

