# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	establish working directories
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

rm(list = ls())

home_dir <- "~/_smu/_src/global_terrorism/"
data_dir <- "./data"

setwd(home_dir)


# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	read in base data
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

setwd(data_dir)

	start.time <- Sys.time()

	gt <- read.csv("GTJSON.csv",
				   sep = ";",
				   stringsAsFactors = FALSE,
				   header = TRUE)

	end.time <- Sys.time()
	time.taken <- end.time - start.time
	cat(time.taken)
	
setwd(home_dir)


# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	add date column (from year/month/day) --
# ...	---> when month is missing set to January
# ...	---> when day is missing set to 01
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

gt$imonth[gt$imonth == 0] <- 1
gt$iday  [gt$iday   == 0] <- 1

gt$date <- strptime(paste(gt$iyear, gt$imonth, gt$iday),
					 "%Y %m %d", tz = "GMT")

gt <- gt[with(gt, order(date)), ]

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	add column with time delta btwn each (sorted order) event
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

gt$time_delta <- (c(NA,gt$date[2:nrow(gt)] - gt$date[1:(nrow(gt)-1)])) / 86400


# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	unique city, state, country subset
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


city_state_country <- gt[,c("city", "provstate", "country_txt")]

unique_city_state_country <- unique(city_state_country)

locn <- paste0(
					unique_city_state_country$city,
					", ",
					unique_city_state_country$provstate,
					", ",
					unique_city_state_country$country_txt
				)

write.csv (locn, file = "geo_locations.csv", row.names = FALSE, col.names = c("Address"))

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	assign geo coordinates to each event location
# ...	https://stackoverflow.com/questions/13905098/how-to-get-the-
# ...		longitude-and-latitude-coordinates-from-a-city-name-and-country-i
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

library(RJSONIO)
setInternet(TRUE)
nrow <- nrow(gt)

indx <- 1
gt$lon[indx] <- 0
gt$lat[indx] <- 0

while (indx <= nrow)
{
	
	expr <- paste("http://nominatim.openstreetmap.org/search?city="
    , gt$city[indx]
    , "&countrycodes="
    , gt$country_txt[indx]
    , "&limit=9&format=json"
    , sep="")
	
  url <- expr
  
  x <- fromJSON(url)
  
  if(is.vector(x))
  {
    gt$lon[indx] <- x[[1]]$lon
    gt$lat[indx] <- x[[1]]$lat    
  }
  indx <- indx + 1
}


library(ggmap)






