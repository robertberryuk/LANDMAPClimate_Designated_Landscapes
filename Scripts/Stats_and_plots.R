#> This script is used to calculate the statistics as set out in the NRW ITQ for "LANDMAP, landscape and a changing climate in the Designated Landscapes, Wales"

# Compute statitics for:

# 1. LMP14	LANDMAP 14 landscape categories 
# % and km2 for each category

# 2. LMP14<1m 
# LANDMAP landscape categories highlighting landscapes less than 1m in contour height
# % and km2 for each category and subcategory (no double counting)

# 3. LMP14 flood risk
# LANDMAP landscape categories highlighting landscapes currently at risk of flooding (coastal and fluvial)
# % and km2 for each category and subcategory (no double counting)


# 4. LMP14 boundaries	LANDMAP landscape categories and boundary type.
# % and km2 for each category


# 5. LMP14 evaluation	LANDMAP landscape categories and overall evaluation
# % and km2 for each category


#> 1. LIBRARIES-----------------------------------------------------------------------------------------------------------------------------

library(tidyverse)
library(sf)
library(here)
library(ggthemes)
library(dplyr)
library(reshape2)
library(janitor) # for adding a "Total" row to the bottom of exported data frames
library(beepr)



#> 2. LOAD DATA----------------------------------------------------------------------------------------------------------------------------

# LANDMAP polygons (with LMP14)
LMP <- st_read(here("In", "LANDMAP_VS_ClimateOnly.shp"))
# Set CRS to British National Grid
LMP <- st_transform(LMP, crs = 27700)

# Designated landscapes polygons
Des <- st_read(here("In", "Areas_Merged.shp"))
Des <- st_transform(Des, crs = 27700)


#> Import LMP14 colour lookup table
colours_LMP14 <- read_csv(here("In", "Lookup_LMP14_Colours.csv"))

# Create a list of designated areas to control loops
Area_List <- c("Anglesey AONB", "Brecon Beacons National Park", "Clwydian Range and Dee Valley AONB", "Gower AONB", "Llyn AONB", "Pembrokeshire Coast National Park", "Snowdonia National Park", "Wye Valley AONB (Wales)")

#> 3. SPATIAL INTERSECTION----------------------------------------------------------------------------------------------------------------- 

# Intersect layers
int <- st_intersection(Des, LMP)

# Calculate areas
int$Area_km2 <- st_area(int) / 1000000
int$Area_km2 <- round(int$Area_km2 , digits = 2)
# Change area units to numeric
int$Area_km2 <- as.numeric(int$Area_km2)

# Remove unwanted columns
int <- int %>% 
  select(NAME_NEW, LMP14_D_S, Area_km2, )

# Change NAME_NEW to DESIGNATED LANDSCAPE
colnames(int)[which(names(int) == "NAME_NEW")] <- "Designated_Landscape"

# Create a duplicate of int - geometry will be maintained in this layer (for subsequent intersections)
int.geom <- int

# Remove geometry for faster processing
st_geometry(int) <- NULL




#> 4. STATS: LMP14 General----------------------------------------------------------------------------------------------------------------

# Area KM2 counts
# LMP 14 - General
stat_LMP14 <- int %>% 
  group_by(Designated_Landscape, LMP14_D_S) %>% 
  summarise(Km2 = sum(Area_km2)) %>% 
  arrange(desc(Km2))

# Spread the table
spread_stat_LMP14 <- stat_LMP14 %>% 
  pivot_wider(names_from = LMP14_D_S, values_from = Km2)
#> Change NAs to zero
spread_stat_LMP14[is.na(spread_stat_LMP14)] <- 0

# Arrange columns alphabetically
spread_stat_LMP14 <- spread_stat_LMP14[,c(names(spread_stat_LMP14)[1],sort(names(spread_stat_LMP14)[2:15]))] 
  
# Arrange rows alphabetciallyt by area name
spread_stat_LMP14 <- spread_stat_LMP14 %>% 
  arrange(Designated_Landscape)

# Add total LMP14 Km2 column (for percentage calc)
spread_stat_LMP14$Total_Km2 <- rowSums(spread_stat_LMP14[2:15])

# Export km2 table as CSV
write_csv(spread_stat_LMP14, here("Out", "Raw_Tables", "1_LMP14_All_Areas", "1_LMP14_Designated_Landscapes_Area_Km2.csv"))


# Percentage table
# Calculate percentages
spread_stat_LMP14_PC <- spread_stat_LMP14 %>% 
  select(-Total_Km2)
spread_stat_LMP14_PC[2:15] <- round(spread_stat_LMP14[2:15] /rowSums(spread_stat_LMP14[2:15]) * 100, digits = 2)
# 
# # add % totals column
# spread_stat_LMP14_PC$`% Total` <- rowSums(spread_stat_LMP14_PC[2:15])

# Export table as CSV
write_csv(spread_stat_LMP14_PC, here("Out", "Raw_Tables", "1_LMP14_All_Areas", "1_LMP14_Designated_Landscapes_Area_Percent.csv"))


# Add TOTALs rows to the bottom of each Km2 and % tables row summing the columns, at the bottom of each table

# km table
# Reimport exported tables to add "Total" rows to the bottom of each
df.km <- read_csv(here("Out", "Raw_Tables", "1_LMP14_All_Areas", "1_LMP14_Designated_Landscapes_Area_Km2.csv"))
df.km <- df.km %>% 
  janitor::adorn_totals("row")
# Export updated km2 table with 'Total' column as CSV
write_csv(df.km, here("Out", "Raw_Tables", "1_LMP14_All_Areas", "1_LMP14_Designated_Landscapes_Area_Km2.csv"))






  
#> 5. STATS: LMP14 =<1m ----------------------------------------------------------------------------------------------------------------

# Assumes code above already run and objects loaded into environment, therefore only need to add additonal datasets

# Add +1m sea level data
Sea.1m <- st_read(here("In", "1mSeaLevel.shp"))
Sea.1m <- st_transform(Sea.1m, crs = 27700)

# Intersect sea level data with LMP14 int.geom
int.SeaLevel <- st_intersection(int.geom, Sea.1m)

# Calculate areas
int.SeaLevel$Area_km2 <- st_area(int.SeaLevel) / 1000000
int.SeaLevel$Area_km2 <- round(int.SeaLevel$Area_km2 , digits = 2)
# Change area units to numeric
int.SeaLevel$Area_km2 <- as.numeric(int.SeaLevel$Area_km2)

# Remove unwanted columns
int.SeaLevel <- int.SeaLevel %>% 
  select(Designated_Landscape, LMP14_D_S, Area_km2)

# Remove geometry
st_geometry(int.SeaLevel) <- NULL

# Area KM2 counts
# LMP 14 - General
stat_LMP14.Sea.1m <- int.SeaLevel %>% 
  group_by(Designated_Landscape, LMP14_D_S) %>% 
  summarise(Km2 = sum(Area_km2)) %>% 
  arrange(desc(Km2))

# Spread the table
spread_stat_LMP14.Sea.1m <- stat_LMP14.Sea.1m %>% 
  pivot_wider(names_from = LMP14_D_S, values_from = Km2)
#> Change NAs to zero
spread_stat_LMP14.Sea.1m[is.na(spread_stat_LMP14.Sea.1m)] <- 0

# Add column for missing LMP14 type not selected in the intersection (i.e. 'upland rock')
spread_stat_LMP14.Sea.1m$`Upland (rock)` <- 0

# Ungroup
spread_stat_LMP14.Sea.1m <- spread_stat_LMP14.Sea.1m %>% 
  ungroup()

# No data selected in +1m for Brecon Beancons or Clwydian - so need to add these rows with "0" values in all fields
spread_stat_LMP14.Sea.1m <- add_row(spread_stat_LMP14.Sea.1m, Designated_Landscape = "Brecon Beacons National Park")
spread_stat_LMP14.Sea.1m <- add_row(spread_stat_LMP14.Sea.1m, Designated_Landscape = "Clwydian Range and Dee Valley AONB")

# Change NAs to (near) zeros - avoids Nan when doign perecentage calcs later
spread_stat_LMP14.Sea.1m[is.na(spread_stat_LMP14.Sea.1m)] <-0

# Arrange columns alphabetically
spread_stat_LMP14.Sea.1m <- spread_stat_LMP14.Sea.1m[,c(names(spread_stat_LMP14.Sea.1m)[1],sort(names(spread_stat_LMP14.Sea.1m)[2:15]))] 

# Arrange rows alphabetically by area name
spread_stat_LMP14.Sea.1m <- spread_stat_LMP14.Sea.1m %>% 
  arrange(Designated_Landscape)

# Add total LMP14 Km2 column (for percentage calc)
spread_stat_LMP14.Sea.1m$Total_Km2 <- rowSums(spread_stat_LMP14.Sea.1m[2:15])

# Export table as CSV
write_csv(spread_stat_LMP14.Sea.1m, here("Out", "Raw_Tables", "2_LMP14_Sea+1m_All_Areas", "2_LMP14_Designated_Landscapes_Sea.1m_Area_Km2.csv"))

# Percentage table
spread_stat_LMP14_PC_Sea.1m <- spread_stat_LMP14.Sea.1m
# Remove totals columns (using the totals column from LMP14_Area_Km2 for area calculations)
spread_stat_LMP14_PC_Sea.1m <- spread_stat_LMP14_PC_Sea.1m %>% 
  select(-Total_Km2)

# Round numbers and calculate percentages
spread_stat_LMP14_PC_Sea.1m[2:15] <- round(spread_stat_LMP14_PC_Sea.1m[2:15] / spread_stat_LMP14$Total_Km2  * 100, digits = 2)

# add % totals column
spread_stat_LMP14_PC_Sea.1m$`% Total` <- rowSums(spread_stat_LMP14_PC_Sea.1m[2:15])

# 
# # Remove NANs
# spread_stat_LMP14_PC_Sea.1m$`Coastal edge`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Coastal edge`)]<-0
# spread_stat_LMP14_PC_Sea.1m$`Developed (amenity)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Developed (amenity)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Developed (communities)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Developed (communities)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Developed (industry)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Developed (industry)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Lowland (wooded & wetland)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Lowland (wooded & wetland)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Lowland valleys (hedgerow)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Lowland valleys (hedgerow)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Lowland valleys (open)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Lowland valleys (open)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Upland (grassland)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Upland (grassland)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Upland (moorland)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Upland (moorland)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Upland (rock)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Upland (rock)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Upland (wooded hills)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Upland (wooded hills)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Upland (wooded)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Upland (wooded)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Water (inland)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Water (inland)`)] <-0
# spread_stat_LMP14_PC_Sea.1m$`Water (sea)`[is.nan(spread_stat_LMP14_PC_Sea.1m$`Water (sea)`)] <-0


# Export table as CSV
write_csv(spread_stat_LMP14_PC_Sea.1m, here("Out", "Raw_Tables", "2_LMP14_Sea+1m_All_Areas", "2_LMP14_Designated_Landscapes_Sea.1m_Percent.csv"))


# Add TOTALs rows to the bottom of Km2 and % table rows summing the numerical km2 columns

# km table
# Reimport exported tables to add "Total" rows to the bottom of each
df.km <- read_csv(here("Out", "Raw_Tables", "2_LMP14_Sea+1m_All_Areas", "2_LMP14_Designated_Landscapes_Sea.1m_Area_Km2.csv"))
df.km <- df.km %>% 
  janitor::adorn_totals("row")
# Export updated km2 table with 'Total' column as CSV
write_csv(df.km, here("Out", "Raw_Tables", "2_LMP14_Sea+1m_All_Areas", "2_LMP14_Designated_Landscapes_Sea.1m_Area_Km2.csv"))





#> 6. STATS: LMP14 FloodZone 3 ----------------------------------------------------------------------------------------------------------------

# Add Flood Zone 3 data
Flood3<- st_read(here("In", "FloodZone3.shp"))
Flood3 <- st_transform(Flood3, crs = 27700)

# Intersect sea level data with LMP14 int.geom
int.Flood3 <- st_intersection(int.geom, Flood3)

# Calculate areas
int.Flood3$Area_km2 <- st_area(int.Flood3) / 1000000
int.Flood3$Area_km2 <- round(int.Flood3$Area_km2 , digits = 2)
# Change area units to numeric
int.Flood3$Area_km2 <- as.numeric(int.Flood3$Area_km2)

# Remove unwanted columns
int.Flood3 <- int.Flood3 %>% 
  select(Designated_Landscape, LMP14_D_S, Area_km2)

# Remove geometry
st_geometry(int.Flood3) <- NULL

# Area KM2 counts
# LMP 14 - General
stat_LMP14.Flood3 <- int.Flood3 %>% 
  group_by(Designated_Landscape, LMP14_D_S) %>% 
  summarise(Km2 = sum(Area_km2)) %>% 
  arrange(desc(Km2))

# Spread the table
spread_stat_LMP14.Flood3 <- stat_LMP14.Flood3 %>% 
  pivot_wider(names_from = LMP14_D_S, values_from = Km2)
#> Change NAs to zero
spread_stat_LMP14.Flood3[is.na(spread_stat_LMP14.Flood3)] <- 0

# Arrange columns alphabetically
spread_stat_LMP14.Flood3 <- spread_stat_LMP14.Flood3[,c(names(spread_stat_LMP14.Flood3)[1],sort(names(spread_stat_LMP14.Flood3)[2:15]))] 

# Arrange rows alphabetically by area name
spread_stat_LMP14.Flood3 <- spread_stat_LMP14.Flood3 %>% 
  arrange(Designated_Landscape)

# Add total area flooded
spread_stat_LMP14.Flood3$Total_Km2 <- rowSums(spread_stat_LMP14.Flood3[2:15])

# Export table as CSV
write_csv(spread_stat_LMP14.Flood3, here("Out", "Raw_Tables", "3_LMP14_Floodzone3_All_Areas", "3_LMP14_Designated_Landscapes_FloodZone3_Area_Km2.csv"))

# Remove totals columns (using the totals column from LMP14_Area_Km2 for area calculations)
spread_stat_LMP14.Flood3<- spread_stat_LMP14.Flood3 %>% 
  select(-Total_Km2)

# Percentage table
spread_stat_LMP14_PC_Flood3 <- spread_stat_LMP14.Flood3

# Round numbers and calculate percentages
spread_stat_LMP14_PC_Flood3[2:15] <- round(spread_stat_LMP14_PC_Flood3[2:15] / spread_stat_LMP14$Total_Km2  * 100, digits = 2)

# add % totals column
spread_stat_LMP14_PC_Flood3$`% Total` <- rowSums(spread_stat_LMP14_PC_Flood3[2:15])

# Export table as CSV
write_csv(spread_stat_LMP14_PC_Flood3, here("Out", "Raw_Tables", "3_LMP14_Floodzone3_All_Areas", "3_LMP14_Designated_Landscapes_FloodZone3_Percent.csv"))


# Add TOTALs rows to the bottom of Km2 and % table rows summing the numerical km2 columns

# km table
# Reimport exported tables to add "Total" rows to the bottom of each
df.km <- read_csv(here("Out", "Raw_Tables", "3_LMP14_Floodzone3_All_Areas", "3_LMP14_Designated_Landscapes_FloodZone3_Area_Km2.csv"))
df.km <- df.km %>% 
  janitor::adorn_totals("row")
# Export updated km2 table with 'Total' column as CSV
write_csv(df.km, here("Out", "Raw_Tables", "3_LMP14_Floodzone3_All_Areas", "3_LMP14_Designated_Landscapes_FloodZone3_Area_Km2.csv"))





#> 7. STATS: LMP14 FloodZone 2 ----------------------------------------------------------------------------------------------------------------

# Add Flood Zone 2 data
Flood2<- st_read(here("In", "FloodZone2.shp"))
Flood2 <- st_transform(Flood2, crs = 27700)

# Intersect sea level data with LMP14 int.geom
int.Flood2 <- st_intersection(int.geom, Flood2)

# Calculate areas
int.Flood2$Area_km2 <- st_area(int.Flood2) / 1000000
int.Flood2$Area_km2 <- round(int.Flood2$Area_km2 , digits = 2)
# Change area units to numeric
int.Flood2$Area_km2 <- as.numeric(int.Flood2$Area_km2)

# Remove unwanted columns
int.Flood2 <- int.Flood2 %>% 
  select(Designated_Landscape, LMP14_D_S, Area_km2)

# Remove geometry
st_geometry(int.Flood2) <- NULL

# Area KM2 counts
# LMP 14 - General
stat_LMP14.Flood2 <- int.Flood2 %>% 
  group_by(Designated_Landscape, LMP14_D_S) %>% 
  summarise(Km2 = sum(Area_km2)) %>% 
  arrange(desc(Km2))

# Spread the table
spread_stat_LMP14.Flood2 <- stat_LMP14.Flood2 %>% 
  pivot_wider(names_from = LMP14_D_S, values_from = Km2)
#> Change NAs to zero
spread_stat_LMP14.Flood2[is.na(spread_stat_LMP14.Flood2)] <- 0

# Arrange columns alphabetically
spread_stat_LMP14.Flood2 <- spread_stat_LMP14.Flood2[,c(names(spread_stat_LMP14.Flood2)[1],sort(names(spread_stat_LMP14.Flood2)[2:15]))] 

# Arrange rows alphabetically by area name
spread_stat_LMP14.Flood2 <- spread_stat_LMP14.Flood2 %>% 
  arrange(Designated_Landscape)

# Add total area flooded
spread_stat_LMP14.Flood2$Total_Km2 <- rowSums(spread_stat_LMP14.Flood2[2:15])

# Export table as CSV
write_csv(spread_stat_LMP14.Flood2, here("Out", "Raw_Tables", "4_LMP14_Floodzone2_All_Areas", "4_LMP14_Designated_Landscapes_Area_Km2_Flood2.csv"))

# Remove totals columns (using the totals column from LMP14_Area_Km2 for area calculations)
spread_stat_LMP14.Flood2 <- spread_stat_LMP14.Flood2 %>% 
  select(-Total_Km2)

# Percentage table
spread_stat_LMP14_PC_Flood2 <- spread_stat_LMP14.Flood2

# Round numbers and calculate percentages
spread_stat_LMP14_PC_Flood2[2:15] <- round(spread_stat_LMP14_PC_Flood2[2:15] / spread_stat_LMP14$Total_Km2  * 100, digits = 2)

# add % totals column
spread_stat_LMP14_PC_Flood2$`% Total` <- rowSums(spread_stat_LMP14_PC_Flood2[2:15])

# Export table as CSV
write_csv(spread_stat_LMP14_PC_Flood2, here("Out", "Raw_Tables", "4_LMP14_Floodzone2_All_Areas", "4_LMP14_Designated_Landscapes_Area_Percent_Flood2.csv"))

# Add TOTALs rows to the bottom of Km2 and % table rows summing the numerical km2 columns

# km table
# Reimport exported tables to add "Total" rows to the bottom of each
df.km <- read_csv(here("Out", "Raw_Tables", "4_LMP14_Floodzone2_All_Areas", "4_LMP14_Designated_Landscapes_Area_Km2_Flood2.csv"))
df.km <- df.km %>% 
  janitor::adorn_totals("row")
# Export updated km2 table with 'Total' column as CSV
write_csv(df.km, here("Out", "Raw_Tables", "4_LMP14_Floodzone2_All_Areas", "4_LMP14_Designated_Landscapes_Area_Km2_Flood2.csv"))



#> 8. STATS + PLOTS: LMP14 Boundary Type ----------------------------------------------------------------------------------------------------------------

# Import full LANDMAP data
LANDMAP <- st_read(here("In", "LANDMAP_All.shp"))
LANDMAP <- st_transform(LANDMAP, crs = 27700)

# Intersect layers
int.LANDMAP <- st_intersection(Des, LANDMAP)

# Calculate areas
int.LANDMAP$Area_km2 <- st_area(int.LANDMAP) / 1000000
int.LANDMAP$Area_km2 <- round(int.LANDMAP$Area_km2, digits = 2)
# Change area units to numeric
int.LANDMAP$Area_km2 <- as.numeric(int.LANDMAP$Area_km2)

# Remove geometry for faster processing
st_geometry(int.LANDMAP) <- NULL

# Change NAME_NEW to DESIGNATED LANDSCAPE
colnames(int.LANDMAP)[which(names(int.LANDMAP) == "NAME_NEW")] <- "Designated_Landscape"

# Remove unwanted columns
LANDMAP.VS_7 <- int.LANDMAP %>% 
  select(Designated_Landscape, LMP14_D_S, VS_7, Area_km2)

#_______________________________________________________________________________________________________________________


# Loop to export table for each designated landscape

for (i in 1:length(Area_List)){

# Area KM2 counts
# LMP 14 
stat_LMP14.VS7_Bound <- LANDMAP.VS_7 %>% 
  filter(Designated_Landscape == Area_List[i])

# Group and summarise
stat_LMP14.VS7_Bound <- stat_LMP14.VS7_Bound %>% 
  select(-Designated_Landscape) %>% 
  group_by(LMP14_D_S, VS_7) %>% 
  summarise(km2 = sum(Area_km2))

# change VS_7  from charcter to factor
stat_LMP14.VS7_Bound$VS_7 <- as.character(stat_LMP14.VS7_Bound$VS_7)


# Spread
spread_stat_LMP14.VS7_Bound <- stat_LMP14.VS7_Bound %>% 
  pivot_wider(names_from = VS_7, values_from = km2)

# Change NA column to "No Data"
colnames(spread_stat_LMP14.VS7_Bound )[which(names(spread_stat_LMP14.VS7_Bound ) == "NA")] <- "No Data"

# https://stackoverflow.com/questions/9236992/r-find-missing-columns-add-to-data-frame-if-missing/30468945
# Generate list of call possible columns
unique.bounds <-as.character(unique(LANDMAP$VS_7))
# Change NA to No Data
unique.bounds <- replace(unique.bounds, is.na(unique.bounds), "No Data")
# Find missing columns
Missing.cols <- setdiff(unique.bounds, names(spread_stat_LMP14.VS7_Bound))
# Add missing columns
spread_stat_LMP14.VS7_Bound[Missing.cols] <- 0

# Columns in alphabetical order
spread_stat_LMP14.VS7_Bound <- spread_stat_LMP14.VS7_Bound[,order(colnames(spread_stat_LMP14.VS7_Bound))]

# Move column LMP14_D_S to first position
spread_stat_LMP14.VS7_Bound <- spread_stat_LMP14.VS7_Bound %>%
  select(LMP14_D_S, everything()) %>% 
  ungroup()

# Find missing rows (LMP_14_D_S)
unique.LMP14 <- as.character(unique(LANDMAP$LMP14_D_S))
Missing.rows <- setdiff(unique.LMP14, spread_stat_LMP14.VS7_Bound$LMP14_D_S)
Missing.rows

# Use a loop to add missing rows
for (j in 1:length(Missing.rows)){

  spread_stat_LMP14.VS7_Bound <- add_row(spread_stat_LMP14.VS7_Bound, LMP14_D_S=Missing.rows[j])
}

# Arrange rows alphabetically by area name
spread_stat_LMP14.VS7_Bound <- spread_stat_LMP14.VS7_Bound %>% 
  arrange(LMP14_D_S)

#> Change NAs to zero
spread_stat_LMP14.VS7_Bound[is.na(spread_stat_LMP14.VS7_Bound)] <- 0

# Get number ofcolumns
colNo <- ncol(spread_stat_LMP14.VS7_Bound)

# Add total area of boundary
spread_stat_LMP14.VS7_Bound$Total_Km2 <- rowSums(spread_stat_LMP14.VS7_Bound[2:colNo])

# Export table as CSV
write_csv(spread_stat_LMP14.VS7_Bound, here("Out", "Raw_Tables", "5_LMP14_VS7_Boundaries_By_Area", paste0("5_LMP14_Boundaries_", Area_List[i], "_Areakm2.csv")))

# Remove totals columns (using the totals column from LMP14_Area_Km2 for area calculations)
spread_stat_LMP14.VS7_Bound <- spread_stat_LMP14.VS7_Bound %>% 
  select(-Total_Km2)

# Percentage table
spread_stat_LMP14_PC_VS7_Bound <- spread_stat_LMP14.VS7_Bound

# Get number ofcolumns
colNo <- ncol(spread_stat_LMP14.VS7_Bound)

Area_LMP14 <- spread_stat_LMP14 %>% 
  filter(Designated_Landscape == Area_List[i])
Area_LMP14 <- Area_LMP14$Total_Km2

spread_stat_LMP14_PC_VS7_Bound[2:colNo] <- round(spread_stat_LMP14_PC_VS7_Bound[2:colNo] / Area_LMP14 * 100, digits = 2)

# # Remove NANs from percentage table
# spread_stat_LMP14_PC_VS7_Bound$`Clawdd/Hedgebanks`[is.nan(spread_stat_LMP14_PC_VS7_Bound$`Clawdd/Hedgebanks`)]<-0
# spread_stat_LMP14_PC_VS7_Bound$Fences[is.nan(spread_stat_LMP14_PC_VS7_Bound$Fences)]<-0
# spread_stat_LMP14_PC_VS7_Bound$`Fences With Trees`[is.nan(spread_stat_LMP14_PC_VS7_Bound$`Fences With Trees`)]<-0
# spread_stat_LMP14_PC_VS7_Bound$`Hedge With Trees`[is.nan(spread_stat_LMP14_PC_VS7_Bound$`Hedge With Trees`)]<-0
# spread_stat_LMP14_PC_VS7_Bound$`Managed Hedge`[is.nan(spread_stat_LMP14_PC_VS7_Bound$`Managed Hedge`)]<-0
# spread_stat_LMP14_PC_VS7_Bound$Mixture[is.nan(spread_stat_LMP14_PC_VS7_Bound$Mixture)]<-0
# spread_stat_LMP14_PC_VS7_Bound$`No Data`[is.nan(spread_stat_LMP14_PC_VS7_Bound$`No Data`)]<-0
# spread_stat_LMP14_PC_VS7_Bound$None[is.nan(spread_stat_LMP14_PC_VS7_Bound$None)]<-0
# spread_stat_LMP14_PC_VS7_Bound$`Overgrown Hedges`[is.nan(spread_stat_LMP14_PC_VS7_Bound$`Overgrown Hedges`)]<-0
# spread_stat_LMP14_PC_VS7_Bound$`Slate Fences`[is.nan(spread_stat_LMP14_PC_VS7_Bound$`Slate Fences`)]<-0
# spread_stat_LMP14_PC_VS7_Bound$`Stone Walls`[is.nan(spread_stat_LMP14_PC_VS7_Bound$`Stone Walls`)]<-0

# add % totals column
spread_stat_LMP14_PC_VS7_Bound$`% Total` <- rowSums(spread_stat_LMP14_PC_VS7_Bound[2:colNo])

# Export table as CSV
write_csv(spread_stat_LMP14_PC_VS7_Bound, here("Out", "Raw_Tables", "5_LMP14_VS7_Boundaries_By_Area", paste0("5_LMP14_Boundaries_", Area_List[i], "_Percent.csv")))

# km table
# Reimport exported tables to add "Total" rows to the bottom of each
df.km <- read_csv(here("Out", "Raw_Tables", "5_LMP14_VS7_Boundaries_By_Area", paste0("5_LMP14_Boundaries_", Area_List[i], "_Areakm2.csv")))
df.km <- df.km %>% 
  janitor::adorn_totals("row")
# Export updated km2 table with 'Total' column as CSV
write_csv(df.km, here("Out", "Raw_Tables", "5_LMP14_VS7_Boundaries_By_Area", paste0("5_LMP14_Boundaries_", Area_List[i], "_Areakm2.csv")))


# PLOT
# Generate plot while target dataframe is active in the loop

# Create new data frame for plotting
df_plot <- spread_stat_LMP14.VS7_Bound
# Melt
df_plot <- melt(df_plot)

#> Plot data
p <- ggplot(df_plot, aes(x = forcats::fct_rev(LMP14_D_S), y = value, fill = forcats::fct_rev(variable))) +
  geom_bar(stat = "identity") +
  theme_bw() +
  labs(x = "LMP14 Landscape Type", y = "Area (km2)") +
  # theme(axis.text.x=element_text(angle=90,hjust=1)) +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 16, b = 0, l = 0))) +
  theme(axis.title.x = element_text(margin = margin(t = 12, r = 0, b = 0, l = 0))) +
  theme(legend.title = element_blank()) +
  theme(legend.text=element_text(size=8)) +
  theme(legend.position = "top") +
  scale_fill_manual(labels = c("Clawdd/Hedgebanks", "Fences", "Fences With Trees", "Hedge With Trees", "Managed Hedge", "Mixture", "No Data", "None", "Overgrown Hedges", "Slate Fences", "Stone Walls"), values = rev(c("#FF7F00", "#A4D5A1", "#59F10D", "#FDAC86", "#AB745A", "#9190d6", "#000000", "#d61790", "#714d3c", "#e31a1c", "#1417d6")), breaks = c("Clawdd/Hedgebanks", "Fences", "Fences With Trees", "Hedge With Trees", "Managed Hedge", "Mixture", "No Data", "None", "Overgrown Hedges", "Slate Fences", "Stone Walls")) +
  # scale_fill_manual(labels = c("  FloodZone 3   ", "  Non-FloodZone 3  "), values = c("lightgreen", "#e31a1c"), breaks = c("Flood", "Area_Km2")) +
  coord_flip() 
#> Show plot
p
#> Export the plot
ggsave(here("Out", "Plots", "5_LMP14_Boundaries", file=paste0("LMP_14_VS27_Boundaries_", Area_List[i], ".png")), width = 7, height = 5)

}






#> 9. STATS + PLOTS : LMP14 Overall Evaluation  ----------------------------------------------------------------------------------------------------------------


# Get data from int.LANDMAP (created in Section 8)
# Remove unwanted columns
LANDMAP.VS_26 <- int.LANDMAP %>% 
  select(Designated_Landscape, LMP14_D_S, VS_26, Area_km2)

# Loop to export table for each designated landscape

for (i in 1:length(Area_List)){
  
  ## TEST OUT OF LOOP FIRST
  
  # Area KM2 counts
  # LMP 14 
  stat_LMP14.VS26_Eval <- LANDMAP.VS_26 %>% 
    filter(Designated_Landscape ==  Area_List[i])
  
  # change VS_26  to character
  stat_LMP14.VS26_Eval$VS_26 <- as.character(stat_LMP14.VS26_Eval$VS_26)
  
  # Change any NA values in column VS_26 to "No Data"
  stat_LMP14.VS26_Eval$VS_26[is.na(stat_LMP14.VS26_Eval$VS_26)] <- "No Data"
  # Group and summarise
  stat_LMP14.VS26_Eval <- stat_LMP14.VS26_Eval %>% 
    select(-Designated_Landscape) %>% 
    group_by(LMP14_D_S, VS_26) %>% 
    summarise(km2 = sum(Area_km2))
  
  # Spread
  spread_stat_LMP14.VS26_Eval <- stat_LMP14.VS26_Eval %>% 
    pivot_wider(names_from = VS_26, values_from = km2)
  
  # # Change NA column to "No Data"
  # colnames(spread_stat_LMP14.VS26_Eval )[which(names(spread_stat_LMP14.VS26_Eval ) == "NA")] <- "No Data"
  
  # https://stackoverflow.com/questions/9236992/r-find-missing-columns-add-to-data-frame-if-missing/30468945
  # Generate list of call possible columns
  unique.Evals <-as.character(unique(LANDMAP$VS_26))
  # Change NA to No Data
  unique.Evals <- replace(unique.Evals, is.na(unique.Evals), "No Data")
  # Find missing columns
  Missing.cols <- setdiff(unique.Evals, names(spread_stat_LMP14.VS26_Eval))
  # Add missing columns
  spread_stat_LMP14.VS26_Eval[Missing.cols] <- 0
  
  # Columns in specific order
  spread_stat_LMP14.VS26_Eval <- spread_stat_LMP14.VS26_Eval[c("LMP14_D_S", "Outstanding", "High", "Moderate", "Low", "No Data")]
  
  # Move column LMP14_D_S to first position
  spread_stat_LMP14.VS26_Eval <- spread_stat_LMP14.VS26_Eval %>%
    select(LMP14_D_S, everything()) %>%
    ungroup()

  # Find missing rows (LMP_14_D_S)
  unique.LMP14 <- as.character(unique(LANDMAP$LMP14_D_S))
  Missing.rows <- setdiff(unique.LMP14, spread_stat_LMP14.VS26_Eval$LMP14_D_S)
  Missing.rows
  
  # Use a loop to add missing rows
  for (j in 1:length(Missing.rows)){
    
    spread_stat_LMP14.VS26_Eval <- add_row(spread_stat_LMP14.VS26_Eval, LMP14_D_S=Missing.rows[j])
    
  }
  
  
  # Arrange rows alphabetically by area name
  spread_stat_LMP14.VS26_Eval <- spread_stat_LMP14.VS26_Eval %>% 
    arrange(LMP14_D_S)
  
  #> Change NAs to zero
  spread_stat_LMP14.VS26_Eval[is.na(spread_stat_LMP14.VS26_Eval)] <- 0
  
  # Get number ofcolumns
  colNo <- ncol(spread_stat_LMP14.VS26_Eval)
  
  # Add total area of Evalary
  spread_stat_LMP14.VS26_Eval$Total_Km2 <- rowSums(spread_stat_LMP14.VS26_Eval[2:colNo])
  
  # Export table as CSV
  write_csv(spread_stat_LMP14.VS26_Eval, here("Out", "Raw_Tables", "6_LMP14_VS26_Overall_Evaluation_By_Area", paste0("6_LMP14_VS26_Evaluation_",  Area_List[i], "_Areakm2.csv")))
  
  
  # Remove totals columns (using the totals column from LMP14_Area_Km2 for area calculations)
  spread_stat_LMP14.VS26_Eval <- spread_stat_LMP14.VS26_Eval %>% 
    select(-Total_Km2)
  
  # Percentage table
  spread_stat_LMP14_PC_VS26_Eval <- spread_stat_LMP14.VS26_Eval
  
  # Get number ofcolumns
  colNo <- ncol(spread_stat_LMP14.VS26_Eval)
  
  Area_LMP14 <- spread_stat_LMP14 %>% 
    filter(Designated_Landscape == Area_List[i])
  Area_LMP14 <- Area_LMP14$Total_Km2
  
  spread_stat_LMP14_PC_VS26_Eval[2:colNo] <- round(spread_stat_LMP14_PC_VS26_Eval[2:colNo] / Area_LMP14 * 100, digits = 2)
  
  # # Remove NANs from percentage table
  # spread_stat_LMP14_PC_VS26_Eval$`Clawdd/Hedgebanks`[is.nan(spread_stat_LMP14_PC_VS26_Eval$`Clawdd/Hedgebanks`)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$Fences[is.nan(spread_stat_LMP14_PC_VS26_Eval$Fences)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$`Fences With Trees`[is.nan(spread_stat_LMP14_PC_VS26_Eval$`Fences With Trees`)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$`Hedge With Trees`[is.nan(spread_stat_LMP14_PC_VS26_Eval$`Hedge With Trees`)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$`Managed Hedge`[is.nan(spread_stat_LMP14_PC_VS26_Eval$`Managed Hedge`)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$Mixture[is.nan(spread_stat_LMP14_PC_VS26_Eval$Mixture)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$`No Data`[is.nan(spread_stat_LMP14_PC_VS26_Eval$`No Data`)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$None[is.nan(spread_stat_LMP14_PC_VS26_Eval$None)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$`Overgrown Hedges`[is.nan(spread_stat_LMP14_PC_VS26_Eval$`Overgrown Hedges`)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$`Slate Fences`[is.nan(spread_stat_LMP14_PC_VS26_Eval$`Slate Fences`)]<-0
  # spread_stat_LMP14_PC_VS26_Eval$`Stone Walls`[is.nan(spread_stat_LMP14_PC_VS26_Eval$`Stone Walls`)]<-0
  
  # add % totals column
  spread_stat_LMP14_PC_VS26_Eval$`% Total` <- rowSums(spread_stat_LMP14_PC_VS26_Eval[2:colNo])
  
  # Export table as CSV
  write_csv(spread_stat_LMP14_PC_VS26_Eval, here("Out", "Raw_Tables", "6_LMP14_VS26_Overall_Evaluation_By_Area", paste0("6_LMP14_VS26_Evaluation_",  Area_List[i], "_Percent.csv")))
  
  
  
  # km table
  # Reimport exported tables to add "Total" rows to the bottom of each
  df.km <- read_csv(here("Out", "Raw_Tables", "6_LMP14_VS26_Overall_Evaluation_By_Area", paste0("6_LMP14_VS26_Evaluation_",  Area_List[i], "_Areakm2.csv")))
  df.km <- df.km %>% 
    janitor::adorn_totals("row")
  # Export updated km2 table with 'Total' column as CSV
  write_csv(df.km, here("Out", "Raw_Tables", "6_LMP14_VS26_Overall_Evaluation_By_Area", paste0("6_LMP14_VS26_Evaluation_",  Area_List[i], "_Areakm2.csv")))
  

  
  # PLOT
  # Generate plot while target dataframe is active in the loop
  
  # Create new data frame for plotting
  df_plot <- spread_stat_LMP14.VS26_Eval
  # Melt
  df_plot <- melt(df_plot)
  
  #> Plot data
  p <- ggplot(df_plot, aes(x = forcats::fct_rev(LMP14_D_S), y = value, fill = forcats::fct_rev(variable))) +
    geom_bar(stat = "identity") +
    theme_bw() +
    labs(x = "LMP14 Landscape Type", y = "Area (km2)") +
    # theme(axis.text.x=element_text(angle=90,hjust=1)) +
    theme(axis.title.y = element_text(margin = margin(t = 0, r = 16, b = 0, l = 0))) +
    theme(axis.title.x = element_text(margin = margin(t = 12, r = 0, b = 0, l = 0))) +
    theme(legend.title = element_blank()) +
    theme(legend.text=element_text(size=8)) +
    theme(legend.position = "top") +
    scale_fill_manual(labels = c("Outstanding", "High", "Moderate", "Low", "No Data"), values = rev(c("#ce1256", "#df65b0", "#d7b5d8", "#f1eef6", "#2d46d2")), breaks = c("Outstanding", "High", "Moderate", "Low", "No Data")) +
    coord_flip() 
  #> Show plot
  p
  #> Export the plot
  ggsave(here("Out", "Plots", "6_LMP14_Overall_Evaluation", file=paste0("LMP_14_VS26_Overall_Evaluation_", Area_List[i], ".png")), width = 7, height = 5)
  

}




# PREVIOUS TABLES (FOR AREA - NOT FOR LANDSCAPE TYPE PER AREA)
# # Remove unwanted columns from int.LANDMAP
# LANDMAP.VS_26 <- int.LANDMAP %>% 
#   select(Designated_Landscape, VS_26, Area_km2)
# 
# # Area KM2 counts
# # LMP 14 
# stat_LMP14.VS26_Bound <- LANDMAP.VS_26  %>% 
#   group_by(Designated_Landscape, VS_26) %>% 
#   summarise(Km2 = sum(Area_km2)) %>% 
#   arrange(desc(Km2))
# 
# # Spread the table
# spread_stat_LMP14.VS26_Bound <- stat_LMP14.VS26_Bound %>% 
#   pivot_wider(names_from = VS_26, values_from = Km2)
# #> Change NAs to zero
# spread_stat_LMP14.VS26_Bound[is.na(spread_stat_LMP14.VS26_Bound)] <- 0
# 
# # Arrange columns in order for presentation
# spread_stat_LMP14.VS26_Bound <- spread_stat_LMP14.VS26_Bound %>% 
#   select(Designated_Landscape, Outstanding, High, Moderate, Low, `NA`)
# # Change NA column to "No Data"
# colnames(spread_stat_LMP14.VS26_Bound)[which(names(spread_stat_LMP14.VS26_Bound) == "NA")] <- "No Data"
# 
# # Arrange rows alphabetically by area name
# spread_stat_LMP14.VS26_Bound <- spread_stat_LMP14.VS26_Bound %>% 
#   arrange(Designated_Landscape)
# 
# 
# # Export table as CSV
# write_csv(spread_stat_LMP14.VS26_Bound, here("Out", "Raw_Tables", "6_LMP14_Designated_Landscapes_Area_Km2_VS26_Bound.csv"))
# 
# # Percentage table
# spread_stat_LMP14_PC_VS26_Bound <- spread_stat_LMP14.VS26_Bound
# spread_stat_LMP14_PC_VS26_Bound[2:5] <- round(spread_stat_LMP14_PC_VS26_Bound[2:5] / rowSums(spread_stat_LMP14_PC_VS26_Bound[2:5]) * 100, digits = 2)
# 
# # Export table as CSV
# write_csv(spread_stat_LMP14_PC_VS26_Bound, here("Out", "Raw_Tables", "6_LMP14_Designated_Landscapes_Area_Percent_VS26_Bound.csv"))
# 




#> 10. PLOTS: LMP14 General by landscape  -------------------------------------------------------------------------------------------------------

# Create and export LMP14 plots for all areas using a loop

for (i in 1:length(Area_List)) {
                
df_plot <- spread_stat_LMP14_PC %>%
  dplyr::filter(Designated_Landscape == paste0(Area_List[i]))
# Melt data for chart
df_plot <- melt(df_plot, id=c("Designated_Landscape"))
# Change column names
colnames(df_plot)[which(names(df_plot) == "variable")] <- "LMP14_D_S"
colnames(df_plot)[which(names(df_plot) == "value")] <- "Area_pcent"
# Drop Designated_Landscapes column
df_plot <- df_plot %>% 
  select(-Designated_Landscape)
#> Merge LMP14 map colours to dataframe
df_plot <- merge(df_plot, colours_LMP14, by = "LMP14_D_S", all.x = TRUE)

#> Plot data
p <- ggplot(data = df_plot, aes(x = forcats::fct_rev(LMP14_D_S), Area_pcent, y=Area_pcent, fill=LMP14_D_S)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  labs(x = "LMP14 Landscape Type", y = "% Total Land Area") +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 16, b = 0, l = 0))) +
  theme(axis.title.x = element_text(margin = margin(t = 12, r = 0, b = 0, l = 0))) +
  scale_fill_manual(values = df_plot$Colour_LMP14) +
  theme(legend.position="none") +
  coord_flip() 
#> Show plot
p
#> Export the plot
ggsave(here("Out", "Plots", "1_LMP14", file=paste0("LMP_14_", Area_List[i], ".png")), width = 7, height = 5)

}


#> 11. PLOTS: LMP14 =<1m  -------------------------------------------------------------------------------------------------------


for (i in 1:length(Area_List)) {

df_plot <- spread_stat_LMP14.Sea.1m %>%
  dplyr::filter(Designated_Landscape == paste0(Area_List[i]))
# Melt data for chart
df_plot <- melt(df_plot, id=c("Designated_Landscape"))
# Change column names
colnames(df_plot)[which(names(df_plot) == "variable")] <- "LMP14_D_S"
colnames(df_plot)[which(names(df_plot) == "value")] <- "Flood"
# Drop Designated_Landscapes column
df_plot <- df_plot %>% 
  select(-Designated_Landscape)
# Create new column to hold total km2 value for each LMP14 landscape
# First duplicate spread_stat_LM14
LMP14_Areas <- spread_stat_LMP14
# # Calculate total areas
# LMP14_Areas$Total_Km2 <- rowSums(LMP14_Areas[2:15])
# Drop cols
# LMP14_Areas <- LMP14_Areas %>% 
#   select(Designated_Landscape, Area_km2)
# Select active area
LMP14_Areas <- LMP14_Areas %>%
  dplyr::filter(Designated_Landscape == paste0(Area_List[i]))
# Pivot longer
LMP14_Areas <- LMP14_Areas %>% 
  pivot_longer(-Designated_Landscape, names_to = "LMP14_D_S", values_to = "Area_Km2") %>% 
  ungroup()
# Drop Designated_Landscape col
LMP14_Areas <- LMP14_Areas %>% 
  select(-Designated_Landscape)
# Merge with df_plot
df_plot <- merge(df_plot, LMP14_Areas, by.x = "LMP14_D_S")
# Melt into longer format for drawing stacked bar chart
df_plot <- melt(df_plot)

#> Plot data
p <- ggplot(df_plot, aes(x = forcats::fct_rev(LMP14_D_S), y = value, fill = forcats::fct_rev(variable))) +
  geom_bar(stat = "identity") +
  theme_bw() +
  labs(x = "LMP14 Landscape Type", y = "Area (km2)") +
  # theme(axis.text.x=element_text(angle=90,hjust=1)) +
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 16, b = 0, l = 0))) +
  theme(axis.title.x = element_text(margin = margin(t = 12, r = 0, b = 0, l = 0))) +
  theme(legend.title = element_blank()) +
  theme(legend.position = "top") +
  scale_fill_manual(labels = c("  Up to 1m ASL   ", "  > 1m ASL "), values = c("lightgreen", "#e31a1c"), breaks = c("Flood", "Area_Km2")) +
  coord_flip() 
#> Show plot
p
#> Export the plot
ggsave(here("Out", "Plots", "2_LMP14_1mSea", file=paste0("LMP_14_Sea1m_", Area_List[i], ".png")), width = 7, height = 5)

}





#> 12. PLOTS: Floodzone 3  -------------------------------------------------------------------------------------------------------


for (i in 1:length(Area_List)) {
  
  df_plot <- spread_stat_LMP14.Flood3 %>%
    dplyr::filter(Designated_Landscape == paste0(Area_List[i]))
  # Melt data for chart
  df_plot <- melt(df_plot, id=c("Designated_Landscape"))
  # Change column names
  colnames(df_plot)[which(names(df_plot) == "variable")] <- "LMP14_D_S"
  colnames(df_plot)[which(names(df_plot) == "value")] <- "Flood"
  # Drop Designated_Landscapes column
  df_plot <- df_plot %>% 
    select(-Designated_Landscape)
  # Create new column to hold total km2 value for each LMP14 landscape
  # First duplicate spread_stat_LM14
  LMP14_Areas <- spread_stat_LMP14
  # # Calculate total areas
  # LMP14_Areas$Total_Km2 <- rowSums(LMP14_Areas[2:15])
  # Drop cols
  # LMP14_Areas <- LMP14_Areas %>% 
  #   select(Designated_Landscape, Area_km2)
  # Select active area
  LMP14_Areas <- LMP14_Areas %>%
    dplyr::filter(Designated_Landscape == paste0(Area_List[i]))
  # Pivot longer
  LMP14_Areas <- LMP14_Areas %>% 
    pivot_longer(-Designated_Landscape, names_to = "LMP14_D_S", values_to = "Area_Km2") %>% 
    ungroup()
  # Drop Designated_Landscape col
  LMP14_Areas <- LMP14_Areas %>% 
    select(-Designated_Landscape)
  # Merge with df_plot
  df_plot <- merge(df_plot, LMP14_Areas, by.x = "LMP14_D_S")
  # Melt into longer format for drawing stacked bar chart
  df_plot <- melt(df_plot)
  
  #> Plot data
  p <- ggplot(df_plot, aes(x = forcats::fct_rev(LMP14_D_S), y = value, fill = forcats::fct_rev(variable))) +
    geom_bar(stat = "identity") +
    theme_bw() +
    labs(x = "LMP14 Landscape Type", y = "Area (km2)") +
    # theme(axis.text.x=element_text(angle=90,hjust=1)) +
    theme(axis.title.y = element_text(margin = margin(t = 0, r = 16, b = 0, l = 0))) +
    theme(axis.title.x = element_text(margin = margin(t = 12, r = 0, b = 0, l = 0))) +
    theme(legend.title = element_blank()) +
    theme(legend.position = "top") +
    scale_fill_manual(labels = c("  FloodZone 3   ", "  Non-FloodZone 3  "), values = c("lightgreen", "#e31a1c"), breaks = c("Flood", "Area_Km2")) +
    coord_flip() 
  #> Show plot
  p
  #> Export the plot
  ggsave(here("Out", "Plots", "3_LMP14_Flood3", file=paste0("LMP_14_FloodZone3_", Area_List[i], ".png")), width = 7, height = 5)
  
}




#> 13. PLOTS: Floodzone 2  -------------------------------------------------------------------------------------------------------


for (i in 1:length(Area_List)) {
  
  df_plot <- spread_stat_LMP14.Flood2 %>%
    dplyr::filter(Designated_Landscape == paste0(Area_List[i]))
  # Melt data for chart
  df_plot <- melt(df_plot, id=c("Designated_Landscape"))
  # Change column names
  colnames(df_plot)[which(names(df_plot) == "variable")] <- "LMP14_D_S"
  colnames(df_plot)[which(names(df_plot) == "value")] <- "Flood"
  # Drop Designated_Landscapes column
  df_plot <- df_plot %>% 
    select(-Designated_Landscape)
  # Create new column to hold total km2 value for each LMP14 landscape
  # First duplicate spread_stat_LM14
  LMP14_Areas <- spread_stat_LMP14
  # # Calculate total areas
  # LMP14_Areas$Total_Km2 <- rowSums(LMP14_Areas[2:15])
  # Drop cols
  # LMP14_Areas <- LMP14_Areas %>% 
  #   select(Designated_Landscape, Area_km2)
  # Select active area
  LMP14_Areas <- LMP14_Areas %>%
    dplyr::filter(Designated_Landscape == paste0(Area_List[i]))
  # Pivot longer
  LMP14_Areas <- LMP14_Areas %>% 
    pivot_longer(-Designated_Landscape, names_to = "LMP14_D_S", values_to = "Area_Km2") %>% 
    ungroup()
  # Drop Designated_Landscape col
  LMP14_Areas <- LMP14_Areas %>% 
    select(-Designated_Landscape)
  # Merge with df_plot
  df_plot <- merge(df_plot, LMP14_Areas, by.x = "LMP14_D_S")
  # Melt into longer format for drawing stacked bar chart
  df_plot <- melt(df_plot)
  
  #> Plot data
  p <- ggplot(df_plot, aes(x = forcats::fct_rev(LMP14_D_S), y = value, fill = forcats::fct_rev(variable))) +
    geom_bar(stat = "identity") +
    theme_bw() +
    labs(x = "LMP14 Landscape Type", y = "Area (km2)") +
    # theme(axis.text.x=element_text(angle=90,hjust=1)) +
    theme(axis.title.y = element_text(margin = margin(t = 0, r = 16, b = 0, l = 0))) +
    theme(axis.title.x = element_text(margin = margin(t = 12, r = 0, b = 0, l = 0))) +
    theme(legend.title = element_blank()) +
    theme(legend.position = "top") +
    scale_fill_manual(labels = c("  FloodZone 2   ", "  Non-FloodZone 2  "), values = c("lightgreen", "#e31a1c"), breaks = c("Flood", "Area_Km2")) +
    coord_flip() 
  #> Show plot
  p
  #> Export the plot
  ggsave(here("Out", "Plots", "4_LMP14_Flood2", file=paste0("LMP_14_FloodZone2_", Area_List[i], ".png")), width = 7, height = 5)
  
}


beepr::beep()





