library(jsonlite)
library(tidyverse)

#How many hundreds?
max_i <- 1400

url_template <- "https://www.sciencebase.gov/catalog/items?parentId=4f5543b2e4b018de15819c9d&max=100&format=csv&offset="

topo_dataset <- data.frame(
                    id = character(), 
                    title = character(), 
                    citation = character(), 
                    uri = character(), 
                    minx = numeric(), 
                    maxx = numeric(), 
                    miny = numeric(), 
                    maxy = numeric(),
                    stringsAsFactors=FALSE)

topo_tags <- data.frame(
                    id = character(), 
                    scheme = character(), 
                    name = character(),
                    stringsAsFactors=FALSE)

topo_dates <- data.frame(
                    id = character(), 
                    type = character(), 
                    datestring = character(),
                    label = character(),
                    stringsAsFactors=FALSE)

if (file.exists("topo_dataset.Rdata")){
  load("topo_dataset.Rdata")
}

if (file.exists("topo_tags.Rdata")){
  load("topo_tags.Rdata")
}

#for (i in seq(0, max_i)){
for (i in sample(max_i, replace = FALSE)){
  
  ii <- i * 100
  
  csv_file <- paste0(i, ".csv")
  download.file(url = paste0(url_template, ii), destfile = csv_file)
  data <- read.csv(csv_file, stringsAsFactors = FALSE)
  unlink(csv_file)
  
  if (dim(data)[1] == 0){
    next
  }
  
  for (j in seq(1, 100)){
    file_id <- data[j,]$id
    
    if (dim(filter(topo_dataset, id == file_id))[1] > 0){
      cat("\nFile exists, skipping...\n")
      next
    }
    
    if (is.na(data[j,]$URI)){
      next
    }
    
    json_file <- paste0(file_id, ".json")
    download.file(url = paste0(data[j,]$URI, "?format=json"), destfile = paste0(data[j,]$id, ".json"))
    json_data <- fromJSON(json_file)
    unlink(json_file)
    links_df <- data.frame(json_data$webLinks)
    geotiff <- filter(links_df, title == "GeoTIFF")$uri
    
    if (length(geotiff) == 0){
      topo_dataset[dim(topo_dataset)[1] + 1,] <- cbind(
        id = file_id,
        title = json_data$title,           
        citation = json_data$citation, 
        uri = NA, 
        minx = json_data$spatial$boundingBox$minX, 
        maxx = json_data$spatial$boundingBox$maxX, 
        miny = json_data$spatial$boundingBox$minY, 
        maxy = json_data$spatial$boundingBox$maxY)
      next
    }
      
    topo_dataset[dim(topo_dataset)[1] + 1,] <- cbind(
      id = json_data$id,
      title = json_data$title,           
      citation = json_data$citation, 
      uri = geotiff, 
      minx = json_data$spatial$boundingBox$minX, 
      maxx = json_data$spatial$boundingBox$maxX, 
      miny = json_data$spatial$boundingBox$minY, 
      maxy = json_data$spatial$boundingBox$maxY)
    
    tags_df <- cbind(id = json_data$id, data.frame(json_data$tags))
    
    topo_tags <- rbind(
                    topo_tags, 
                    tags_df
        )
    
    date_df <- cbind(id = json_data$id, data.frame(json_data$dates))
    
    topo_dates <- rbind(
      topo_dates, 
      date_df
    )
     
  }

  save(topo_dataset, file = "topo_dataset.Rdata", compress = TRUE)
  save(topo_tags, file = "topo_tags.Rdata", compress = TRUE)
  save(topo_dates, file = "topo_dates.Rdata", compress = TRUE)
  cat("\nWaiting 3 seconds...\n\n")
  Sys.sleep(3)
  
}

