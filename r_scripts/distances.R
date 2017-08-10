
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	geo distance between successive attacks
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

rm(list = ls())

library(ggmap)
library(geosphere)
library(stats)
library(geonames)
library(TTR)

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	get the input data
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

setwd("/home/mcdevitt/_smu/_src/global_terrorism/data/")

infile <- "dates_locations.csv"
locations <- read.csv(infile,
					  stringsAsFactors = FALSE,
					  na.strings = "\"NULL\"")

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	add to data frame the location of the subsequent attack
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

locations$latitude.nxt <- c(locations$latitude[-1], NA)
locations$longitude.nxt <- c(locations$longitude[-1], NA)

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	arrange to calculate Haversine distance btwn subsequent events
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

locn1 <- data.frame("lat" = locations$latitude,
					"lon" = locations$longitude)

locn2 <- data.frame("lat" = locations$latitude.nxt,
					"lon" = locations$longitude.nxt)

mtrx_locn1 <- as.matrix(locn1)
mtrx_locn2 <- as.matrix(locn2)

delta_dist <- vector()

for (i in 1 : nrow(locn1))
{

	delta_dist[i] <- (distm (c(locn1$lon[i], locn1$lat[i]),
							 c(locn2$lon[i], locn2$lat[i] ),
							 fun = distHaversine)) / 1000

}

# ...	centroid of coordiantes
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	determine centroid of annual locations
# ...		- assume spherical earth
# ...		- x = R * cos(lat) * cos(lon)
# ...		- y = R * cos(lat) * sin(lon)
# ...		- z = R * sin(lat)
# ...		- 	where R is the approximate radius of earth (e.g. 6371KM)#
# ...		- The formula for back conversion:
# ...		- 		lat = asin(z / R)
# ...		- 		lon = atan2(y, x)
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

earth_rad <- 6371
subset <- data.frame()
year_centroid <- data.frame(year = integer(0), lat = numeric(0), lon = numeric(0),
							x = numeric(0), y = numeric(0), z = numeric(0))

for (iyy in 1970 : 2015)
{
	each_year <- NULL
	each_year <- subset(locations,
						iyear == iyy,
						select = c(latitude, longitude))
	
	each_year$lat_rad <- each_year$latitude * pi / 180
	each_year$lon_rad <- each_year$longitude * pi / 180
	
	each_year$x <- earth_rad * cos(each_year$lat_rad) * cos(each_year$lon_rad)
	each_year$y <- earth_rad * cos(each_year$lat_rad) * sin(each_year$lon_rad)
	each_year$z <- earth_rad * sin(each_year$lat_rad)
	each_year$r <- sqrt(each_year$x^2 + each_year$y^2 + each_year$z^2)
	
	x_sum <- mean(each_year$x, na.rm = TRUE)
	y_sum <- mean(each_year$y, na.rm = TRUE)
	z_sum <- mean(each_year$z, na.rm = TRUE)
	
	lat <- asin (z_sum / earth_rad) * 180 / pi
	lon <- atan2 (y_sum, x_sum) * 180 /pi
	
	if (!(is.nan(lat)) || !(is.nan(lon)))
	{
		year_centroid <- rbind (year_centroid,
								data.frame(iyy, lat, lon, x_sum, y_sum, z_sum))
	}
}

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	centroid moving average for smoothed line through points
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

year_centroid$x_3yr <- EMA(year_centroid[,4], n = 3)
year_centroid$y_3yr <- EMA(year_centroid[,5], n = 3)
year_centroid$z_3yr <- EMA(year_centroid[,6], n = 3)

year_centroid$lat_3yr <- asin (year_centroid$z_3yr / earth_rad) * 180 / pi
year_centroid$lon_3yr <- atan2 (year_centroid$y_3yr, year_centroid$x_3yr) * 180 /pi

#year_centroid$lat_3yr <- EMA(year_centroid$lat, n = 2)
#year_centroid$lon_3yr <- EMA(year_centroid$lon, n = 2)

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	plot lat and lon scatter plot
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

plot(lat ~ iyy, data = year_centroid,
	 col = "magenta",
	 pch = 2,
	 ylim = c(-80, 60))
points(lon ~ iyy, data = year_centroid, col = "black", pch = 5)
lines(lon_3yr ~ iyy, data = year_centroid, col = "magenta")
lines(lat_3yr ~ iyy, data = year_centroid, col = "red")

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	add annual centroid back to nominal table
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

locations$year_centroid_lat <- year_centroid[match(locations$iyear, year_centroid$iyy), 2]
locations$year_centroid_lon <- year_centroid[match(locations$iyear, year_centroid$iyy), 3]

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	dist of each event from annual centroid - not sure why to do this ?
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

for (i in 1 : nrow(locations))
{
	locations$delta_dist_year[i] <- (distm (c(locations$longitude[i], locations$latitude[i]),
							 c(locations$year_centroid_lon[i], locations$year_centroid_lat[i] ),
							 fun = distHaversine)) / 1000
}

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	plot trajectory on earth map - load some libraries
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

library(ggplot2)
library(ggmap)

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	create a data.frame with lat/lon points
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

lon_plot <- locations$year_centroid_lon
lat_plot <- locations$year_centroid_lat
df <- as.data.frame(cbind(lon_plot, lat_plot))

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	get the map
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

map_gt <- get_map(location = c(lon = mean(year_centroid$lon),
								   lat = mean(year_centroid$lat)),
					  zoom = 2,
                      maptype = "toner-lite",
				  color = "color",
					  scale = "auto")

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	plot the map with points & smoothed line
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

ggmap(map_gt) +
  geom_point(data = year_centroid,
  		   aes(x = lon, y = lat,
  		   fill = iyy, color = iyy),
  		   size = 3,
  		   shape = 21) +
  guides(fill = FALSE, alpha = FALSE, size = FALSE) +
	 geom_path(data = year_centroid,
  		   aes(x = lon_3yr, y = lat_3yr,
  		   color = iyy),
  		   size = 1,
	 	lineend = "round") + 
  scale_colour_gradientn(colours = rainbow(5),
  					  breaks = seq(2010, 1970, by = -10))


# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	events per year
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

events_per_year <- aggregate(x = locations$iyear,
		  by = list(locations$iyear),
		  FUN = length)

