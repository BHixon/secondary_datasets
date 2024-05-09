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


my_data<-read_sas('//kpco-ihr-1.ihr.or.kp.org/Analytic_Projects_2016/2018_Ritzwoller_PROSPR_EX/Study Projects/20240312_Hixon_SDOH/data/geos_only_all.sas7bdat')
# cache zip boundaries that are download via tigris package
# all colnames to lowercase 
# all colnames to lowercase 
char_zips <- zctas(cb = TRUE, starts_with = "80", year=2010)
options(tigris_use_cache = TRUE)

char_zips <- char_zips  %>% 
  mutate(lon = map_dbl(geometry, ~st_point_on_surface(.x)[[1]]),
         lat = map_dbl(geometry, ~st_point_on_surface(.x)[[2]]))

full_dataset<-inner_join(char_zips, my_data, by = join_by(ZCTA5 == ZIP))

# create color pa
pal1 <- colorNumeric(
  palette = "plasma",
  domain = full_dataset$svi_quintile)

# create labels for zipcodes
labels1 <- 
  paste0(
    "Zip Code: ",
    full_dataset$ZCTA5, "<br/>",
    "Quintile: ",
    full_dataset$svi_quintile,
    " Denominator: ",full_dataset$count) %>%
  lapply(htmltools::HTML)

# create color pa
pal2 <- colorNumeric(
  palette = "plasma",
  domain = full_dataset$NDI)

# create labels for zipcodes
labels2 <- 
  paste0(
    "Zip Code: ",
    full_dataset$ZCTA5, "<br/>",
    "Quintile: ",
    full_dataset$NDI,
    " Denominator: ",full_dataset$count) %>%
  lapply(htmltools::HTML)

# create color pa
pal3 <- colorNumeric(
  palette = "plasma",
  domain = full_dataset$Yost_State_Quintile)

# create labels for zipcodes
labels3 <- 
  paste0(
    "Zip Code: ",
    full_dataset$ZCTA5, "<br/>",
    "Quintile: ",
    full_dataset$Yost_State_Quintile,
    " Denominator: ",full_dataset$count) %>%
  lapply(htmltools::HTML)

# create color pa
pal4 <- colorQuantile(palette = "plasma", domain = full_dataset$assoc_college_plus, n = 5)

# create labels for zipcodes
labels4 <- 
  paste0(
    "Zip Code: ",
    full_dataset$ZCTA5, "<br/>",
    "Quintile: ",
    full_dataset$assoc_college_plus,
    " Denominator: ",full_dataset$count) %>%
  lapply(htmltools::HTML)

# create color pa
pal5 <- colorQuantile(palette = "plasma", domain = full_dataset$MEDHOUSINCOME, n = 5)


# create labels for zipcodes
labels5 <- 
  paste0(
    "Zip Code: ",
    full_dataset$ZCTA5, "<br/>",
    "Quintile: ",
    full_dataset$MEDHOUSINCOME,
    " Denominator: ",full_dataset$count) %>%
  lapply(htmltools::HTML)

svi<-leaflet(full_dataset) %>%
  # add base map
  
  addProviderTiles("CartoDB") %>% 
  setView( lng = -104.991531
           , lat = 39.742043
           , zoom = 11 ) %>%
  setMaxBounds( lng1 = -102.000
                , lat1 = 37.00
                , lng2 = -109.000
                , lat2 = 41.00 ) %>%
  
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal1(svi_quintile),
              group="svi",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels1) %>%

  addLegend(pal = pal1, 
            values = ~svi_quintile, 
            opacity = 0.7, 
            group="svi",
            title = htmltools::HTML("SVI"),
            position = "bottomleft") 
svi
####################################################################################  
ndi<-leaflet(full_dataset) %>%
  # add base map
  
  addProviderTiles("CartoDB") %>% 
  setView( lng = -104.991531
           , lat = 39.742043
           , zoom = 11 ) %>%
  setMaxBounds( lng1 = -102.000
                , lat1 = 37.00
                , lng2 = -109.000
                , lat2 = 41.00 ) %>%
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal2(NDI),
              group="ndi",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels2) %>%
  
  addLegend(pal = pal2, 
            values = ~NDI, 
            opacity = 0.7, 
            group="ndi",
            title = htmltools::HTML("NDI"),
            position = "bottomleft") 

ndi
  ####################################################################################  
yost<-leaflet(full_dataset) %>%
  # add base map
  
  addProviderTiles("CartoDB") %>% 
  setView( lng = -104.991531
           , lat = 39.742043
           , zoom = 11 ) %>%
  setMaxBounds( lng1 = -102.000
                , lat1 = 37.00
                , lng2 = -109.000
                , lat2 = 41.00 ) %>%
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal3(Yost_State_Quintile),
              group="yost",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels3) %>%
  
  addLegend(pal = pal3, 
            values = ~Yost_State_Quintile, 
            opacity = 0.7, 
            group="yost",
            title = htmltools::HTML("YOST"),
            position = "bottomleft") 
yost
  ####################################################################################    
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
            title = htmltools::HTML("Associates Degree or Higher"),
            position = "bottomleft") %>% 
  ####################################################################################    
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~pal5(MEDHOUSINCOME),
              group="Income",
              highlightOptions = highlightOptions(color = "green", weight = 2,
                                                  bringToFront = TRUE),label = labels5) %>%
  
  addLegend(pal = pal5, 
            values = ~MEDHOUSINCOME, 
            opacity = 0.7, 
            group="Income",
            title = htmltools::HTML("Median Household Income"),
            position = "bottomleft") %>%
  ####################################################################################    

  # Layers control 
  addLayersControl(baseGroups = c("svi", "ndi", 
                                  "yost", "Education", 
                                  "Income"),

                   options = layersControlOptions(collapsed = TRUE))%>% 
  
  hideGroup(c( "svi", "ndi", 
               "yost", "Education", 
               "Income"))  %>% 
  
  hideGroup(c( "svi", "ndi", 
               "yost", "Education", 
               "Income"))  


sdohmap %>% clearGroup("zones") %>% removeControl("zonesLegend")
####################################################################################  
sdohmap