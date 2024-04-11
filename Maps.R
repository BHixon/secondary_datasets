#Code for Creating the Maps needed for the SDOH Project
#Authored by: Brian Hixon
#Started on 4/4/2024

library(devtools)
library(remotes)
#Uncomment and run the package installation, if you don't have it
#install_github("arilamstein/choroplethrZip@v1.3.0")
library(choroplethrZip)
library(choroplethr)
library(mapproj)
library(ggplot2)
library("leaflet")
library("geojson")
library("geojsonio")
library("tigris")
library("tidyverse")
library("haven")
library("dplyr")
library("sp")
library("leaflet.extras")
library(tidycensus)
library(stringr)
library(sf)

#Map of ACS variables, in this case median household income
library(acs)
#api.key.install("6d16867f1602d03cdc32e678755a6ef9f7e830f9")

data(df_pop_zip)
data(df_zip_demographics)

#co_zip<- subset(df_zip_demographics, region %in% c("80237", "80236", "80239", "80238", "80243", "80246", "80247", 
#                                                  "80249", "80010", "80261", "80263", "80266", "80271", "80291", 
#                                                  "80123", "80202", "80201", "80204", "80203", "80206", "80205", 
#                                                  "80208", "80207", "80210", "80209", "80212", "80211", "80217", 
#                                                  "80216", "80219", "80218", "80221", "80220", "80223", "80222", 
#                                                  "80224", "80227", "80231", "80230", "80235", "80304", "80503", 
#                                                  "80302", "80301", "80310", "80309", "80303", "80305"))

#rename a variable with a different name
df_zip_demographics$value = df_zip_demographics$per_capita_income

#Create a list of site FIPS codes to align with the ZCTA
kpco_fips = c(08001, 08003, 08005, 08007, 08009, 08011, 08013, 08014, 08015, 
              08017, 08019, 08021, 08023, 08025, 08027, 08029, 08031, 08035, 
              08037, 08039, 08041, 08043, 08045, 08047, 08049, 08051, 08053, 
              08055, 08057, 08059, 08061, 08063, 08065, 08067, 08069, 08071, 
              08073, 08075, 08077, 08079, 08081, 08083, 08085, 08087, 08089, 
              08091, 08093, 08095, 08097, 08099, 08101, 08103, 08105, 08107, 
              08109, 08111, 08113, 08115, 08117, 08119, 08121, 08123, 08125)

#Find unique codes only
#kpco_fips <-unique(kpco_fips1)

kphi_fips = c(15001, 15003, 15005, 15007, 15009)

hfhs_fips = c(26001, 26003, 26005, 26007, 26009, 26011, 26013, 26015, 26017, 
              26019, 26021, 26023, 26025, 26027, 26029, 26031, 26033, 26035, 
              26037, 26039, 26041, 26043, 26045, 26047, 26049, 26051, 26053, 
              26055, 26057, 26059, 26061, 26063, 26065, 26067, 26069, 26071, 
              26073, 26075, 26077, 26079, 26081, 26083, 26085, 26087, 26089, 
              26091, 26093, 26095, 26097, 26099, 26101, 26103, 26105, 26107, 
              26109, 26111, 26113, 26115, 26117, 26119, 26121, 26123, 26125, 
              26127, 26129, 26131, 26133, 26135, 26137, 26139, 26141, 26143, 
              26145, 26147, 26149, 26151, 26153, 26155, 26157, 26159, 26161, 
              26163, 26165)

mcri_fips = c(55001, 55003, 55005, 55007, 55009, 55011, 55013, 55015, 55017, 
              55019, 55021, 55023, 55025, 55027, 55029, 55031, 55033, 55035, 
              55037, 55039, 55041, 55043, 55045, 55047, 55049, 55051, 55053, 
              55055, 55057, 55059, 55061, 55063, 55065, 55067, 55069, 55071, 
              55073, 55075, 55077, 55078, 55079, 55081, 55083, 55085, 55087, 
              55089, 55091, 55093, 55095, 55097, 55099, 55101, 55103, 55105, 
              55107, 55109, 55111, 55113, 55115, 55117, 55119, 55121, 55123, 
              55125, 55127, 55129, 55131, 55133, 55135, 55137, 55139, 55141)

#pull up the map of zip code regions
data(zip.map)

#FIPS CODE YOU FOOL
#Fips codes table  2013 5-year American Community Survey (ACS)  
zip_choropleth(df_zip_demographics, state_zoom = "colorado", county_zoom =kpco_fips,
               title="Per Capita Income of Colorado State by ZCTA") + coord_map()

zip_choropleth(df_zip_demographics, state_zoom = "hawaii", county_zoom =kphi_fips,
               title="Per Capita Income of Hawaii State by ZCTA") + coord_map()

zip_choropleth(df_zip_demographics, state_zoom = "michigan", county_zoom =hfhs_fips,
               title="Per Capita Income of Michigan State by ZCTA") + coord_map()

zip_choropleth(df_zip_demographics, state_zoom = "wisonsin", county_zoom =mcri_fips,
               title="Per Capita Income of Wisconsin State by ZCTA") + coord_map()

my_data<-read_sas('//kpco-ihr-1.ihr.or.kp.org/Analytic_Projects_2016/2018_Ritzwoller_PROSPR_EX/Study Projects/20240312_Hixon_SDOH/data/final_set.sas7bdat')
# cache zip boundaries that are download via tigris package
options(tigris_use_cache = TRUE)

# get zip boundaries that start with 80
char_zips <- zctas(cb = TRUE, starts_with = "80")

# all colnames to lowercase 
colnames(my_data) <- tolower(colnames(my_data))

# join zip boundaries and rate data 
char_zips <- geo_join(char_zips, 
                      all_rates, 
                      by_sp = "GEOID10", 
                      by_df = "zip",
                      how = "left")

colo_pop <- get_acs(geography = "tract", 
                     variables = "B01003_001", 
                     state = "CO",
                     geometry = TRUE) 

hi_pop<- get_acs(geography = "tract", 
                 variables = "B01003_001", 
                 state = "HI",
                 geometry = TRUE) 

wi_pop<- get_acs(geography = "tract", 
                 variables = "B01003_001", 
                 state = "WI",
                 geometry = TRUE) 

mi_pop<- get_acs(geography = "tract", 
                 variables = "B01003_001", 
                 state = "MI",
                 geometry = TRUE) 

pa_pop<- get_acs(geography = "tract", 
                 variables = "B01003_001", 
                 state = "PA",
                 geometry = TRUE) 

combineddataset = rbind(colo_pop, hi_pop, mi_pop, wi_pop, pa_pop)

full_dataset<-left_join(my_data, combineddataset, by = join_by(geocode == GEOID))


pal <- colorQuantile(palette = "viridis", domain = colo_pop$estimate, n = 10)
test<-colo_pop %>%st_transform(crs = "+init=epsg:4326")

colo_pop %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(popup = ~ str_extract(NAME, "^([^,]*)"),
              stroke = FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color = ~ pal(estimate)) %>%
  addLegend("bottomright", 
            pal = pal, 
            values = ~ estimate,
            title = "Population percentiles",
            opacity = 1)




#############################################################
################ SVI ########################################
# get zip boundaries that start with 80

# all colnames to lowercase 
colnames(my_data) <- tolower(colnames(my_data))
char_zips <- zctas(cb = TRUE, starts_with = "80", year=2020)


full_dataset <- geo_join(combineddataset, 
                         my_data, 
                         by_sp = "GEOID", 
                         by_df = "geocode",
                         how = "inner")


# create color palette 
pal1 <- colorNumeric(
  palette = "Reds",
  domain = full_dataset$svi_quintile)

# create labels for zipcodes
labels1 <- 
  paste0(
    "GEOCODE: ",
    full_dataset$geocode, "<br/>",
    "SVI: ",
    full_dataset$svi_quintile) %>%
  lapply(htmltools::HTML)

mapsvi<-leaflet(full_dataset) %>%
  # add base map
  
  addProviderTiles("CartoDB") %>% 
  
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal1(svi_quintile),
              group="SVI",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels1) %>%
  
  addLegend(pal = pal1, 
            values = ~svi_quintile, 
            opacity = 0.7, 
            group="SVI",
            title = htmltools::HTML("SVI Quintile"),
            position = "bottomleft")

#############################################################
################ NDI ########################################
# create color palette 
pal2 <- colorNumeric(
  palette = "Greens",
  domain = full_dataset$ndi)

# create labels for zipcodes
labels2 <- 
  paste0(
    "GEOCODE: ",
    full_dataset$geocode, "<br/>",
    "NDI: ",
    full_dataset$ndi) %>%
  lapply(htmltools::HTML)

mapndi<-leaflet(full_dataset) %>%
  # add base map
  
  addProviderTiles("CartoDB") %>% 
  
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal2(ndi),
              group="NDI",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels2) %>%
  
  addLegend(pal = pal2, 
            values = ~ndi, 
            opacity = 0.7, 
            group="NDI",
            title = htmltools::HTML("NDI Quintile"),
            position = "bottomleft")

#############################################################
################ YOST #######################################
# create color palette 
pal3 <- colorNumeric(
  palette = "Blues",
  domain = full_dataset$yost_state_quintile)

# create labels for zipcodes
labels3 <- 
  paste0(
    "GEOCODE: ",
    full_dataset$geocode, "<br/>",
    "SVI: ",
    full_dataset$yost_state_quintile) %>%
  lapply(htmltools::HTML)

mapyost<-leaflet(full_dataset) %>%
  # add base map
  
  addProviderTiles("CartoDB") %>% 
  
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal3(yost_state_quintile),
              group="Yost",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels3) %>%
  
  addLegend(pal = pal3, 
            values = ~yost_state_quintile, 
            opacity = 0.7, 
            group="Yost",
            title = htmltools::HTML("Yost Quintile"),
            position = "bottomleft")



#############################################################
################ Education ##################################
# create color palette 

pal4 <- colorQuantile(palette = "viridis", domain = colo_pop$assoc_college_plus, n = 5)

# create labels for zipcodes
labels4 <- 
  paste0(
    "GEOCODE: ",
    full_dataset$geocode, "<br/>",
    "Education: ",
    full_dataset$assoc_college_plus) %>%
  lapply(htmltools::HTML)

mapedu<-leaflet(full_dataset) %>%
  # add base map
  
  addProviderTiles("CartoDB") %>% 
  
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal4(assoc_college_plus),
              group="Education",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels4) %>%
  
  addLegend(pal = pal4, 
            values = ~assoc_college_plus, 
            opacity = 0.7, 
            group="Education",
            title = htmltools::HTML("Education Quintile"),
            position = "bottomleft")
mapedu

#############################################################
################ Income #####################################
# create color palette 
pal5 <- colorQuantile(palette = "viridis", domain = colo_pop$medhousincome, n = 5)

# create labels for zipcodes
labels3 <- 
  paste0(
    "GEOCODE: ",
    full_dataset$geocode, "<br/>",
    "Income: ",
    full_dataset$medhousincome) %>%
  lapply(htmltools::HTML)

mapinc<-leaflet(full_dataset) %>%
  # add base map
  
  addProviderTiles("CartoDB") %>% 
  
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal5(medhousincome),
              group="Yost",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels5) %>%
  
  addLegend(pal = pal5, 
            values = ~medhousincome, 
            opacity = 0.7, 
            group="Income",
            title = htmltools::HTML("Income Quintile"),
            position = "bottomleft")

