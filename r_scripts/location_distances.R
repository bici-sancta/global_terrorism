# ... -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	calculate geodesic distance with gdist() from Imap package
# ...	http://nagraj.net/notes/calculating-geographic-distance-with-r/
# ... -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# load Imap
library(Imap)

# ... -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ... -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

places_names <- c("Museum of Modern Art New York, NY",
                "Smithsonian Museum of American Art Washington, DC",
                "Brooklyn Museum Brooklyn, NY",
                "Walker Art Center Minneapolis, MN",
                "Fralin Museum of Art Charlottesville, VA")

# geocode place names
places_lat <- geocode(places_names, source="google")$lat
places_lon <- geocode(places_names, source="google")$lon


places_df <- data.frame(names = places_names,
                        lat = places_lat,
                        lon = places_lon)


# create an empty list
dist_list <- list()

# iterate through data frame placing calculated distance next to place place names
for (i in 1:nrow(places_df)) {
    
    dist_list[[i]] <- gdist(lon.1 = places_df$lon[i], 
                              lat.1 = places_df$lat[i], 
                              lon.2 = places_df$lon, 
                              lat.2 = places_df$lat, 
                              units="miles")
    
}

# view results as list
dist_list

# unlist results and convert to a "named" matrix format
dist_mat <- sapply(dist_list, unlist)

colnames(dist_mat) <- places_names

rownames(dist_mat) <- places_names

# view results as matrix
dist_mat