
	
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	tidy text data mining
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# ...	reference : http://tidytextmining.com/

rm(list=ls())

# ...	load library
library(ggmap)
library(dplyr)
library(tidytext)
library(ggplot2)
library(lubridate)
library(stringr)


	data(stop_words)
	stop_list <- c("null", "unknown", "news", "û", "press", "presse", "agence", "unk")
	stop_list <- c(stop_list, seq.int(1, 5000, 1))
	stop_list <- c(stop_list, "sunday", "monday", "tuesday", "wednesday",
				   				"thursday", "friday", "saturday")
	stop_list <- c(stop_list, "january", "february", "march", "april",
				   				"may", "june", "july", "august",
				   				"september", "october", "november",
				   				"december")
	stop_list <- c(stop_list, "01", "02", "08", "09")
	
	gt_stop_words <- data_frame (word = stop_list, lexicon = "GT_List")

# ...	get the input data

	setwd("/home/mcdevitt/_smu/_src/global_terrorism/data/")

	infile <- "gtd_summary_2017.07.20.csv"
	gt <- read.csv(infile,
				stringsAsFactors = FALSE,
			   	sep = ",",
				na.strings = "\"NULL\"")

# ...	select columns with summary details
	gt <- subset(gt, select=c(iyear, summary, motive, target1,
							  weapdetail))
	#  more columns : , , , motive, target1, weapdetail, scite1, scite2, scite3))

# ...	paste into 1 column & push to new data frame
		
	gt$txt <- paste(gt$summary, "|", gt$target1, "|", gt$motive,
					"|", gt$weapdetail)
	
# ...	remove all digits
	
	gt$txt <- gsub("\\d", "", gt$txt)
		
	gt_txt <- data.frame("year" = gt$iyear, "text" = gt$txt)
	
	rm(gt)

# ... select subset of years, 5 year increments, iteratively from 1970s --> 2015
	
	iyear_start <- 1970
	iyear_end <- 2015
	iyear_incr <- 5
	
	gt_words_lustrum_rows <- data.frame(row = seq(1:200))
	gt_words_lustrum_cols <- data.frame()
	
	for (iyy in seq(from = iyear_start, to = iyear_end, by = iyear_incr))
	{
		
		gt_txt_iyear <- gt_txt[gt_txt$year >= iyy & gt_txt$year < iyy + iyear_incr,]
		
# ...	put into tibble tidy data_frame
	
		nlines <- dim(gt_txt_iyear)[1]
		d_f_gt_txt <- data_frame(line = 1:nlines, text = as.character(gt_txt_iyear$text))
		
		rm(gt_txt_iyear)

# ...	split each line into individual words
		tidy_gt_text <- d_f_gt_txt %>% unnest_tokens(word, text)
		rm(d_f_gt_txt)

# ...	remove common (stop) words

		tidy_gt_text <- tidy_gt_text %>% anti_join(stop_words)

# ...	remove custom stop words
		tidy_gt_text <- tidy_gt_text %>% anti_join(gt_stop_words)

# ...	basic word frequency count
		word_count <- as.data.frame(tidy_gt_text %>% count(word, sort = TRUE))
		
		word_count$year <- iyy
		
		word_count$pct <- word_count$n / sum(word_count$n)
		
		gt_words_lustrum_cols <- rbind(gt_words_lustrum_cols, word_count)
		
		word_count$year <- NULL
		word_count <- word_count[1:200,]
		colnames(word_count) <- c(paste0("words_", iyy), paste0("n_", iyy))
		gt_words_lustrum_rows <- cbind(gt_words_lustrum_rows, word_count)
		
		rm(word_count)
	}
	
	write.csv (gt_words_lustrum_rows, file = "gt_words_lustrum.csv")
	
# ...	tf-idf analysis
	
	gt_words_lustrum_cols$log_pct <- log(gt_words_lustrum_cols$pct + 1)
	
	gt_words_lustrum_cols <- gt_words_lustrum_cols %>% bind_tf_idf(word, year, n)
	
	gt_words_lustrum_cols %>% arrange(desc(tf_idf))
	
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	plot log-pct per decade
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

	plot_gt_words <- gt_words_lustrum_cols %>%
	  arrange(desc(year)) %>%
	  mutate(word = factor(word, levels = rev(unique(word))))

	plot_gt_words %>% 
		  top_n(50) %>%
	  ggplot(aes(word, log_pct, fill = factor(year))) +
	  geom_col() +
	  labs(x = NULL, y = "log_percentage of words / decade") +
	  coord_flip()

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	plot term frequency - inverse document frequency per decade
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

	plot_gt_words.2 <- gt_words_lustrum_cols %>%
	  arrange(desc(year)) %>%
	  mutate(word = factor(word, levels = rev(unique(word))))

	plot_gt_words.2 %>% 
	  top_n(60) %>%
	  ggplot(aes(word, tf_idf, fill = factor(year))) +
	  geom_col() +
	  labs(x = NULL, y = "tf_idf") +
	  coord_flip()
	
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	plot term frequency - inverse document frequency per decade
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

	plot_gt_words.3 <- gt_words_lustrum_cols %>%
	  arrange(desc(year)) %>%
	  mutate(word = factor(word))

	plot_gt_words.2 %>% 
	  top_n(50) %>%
	  ggplot(aes(word, log_pct, fill = factor(year))) +
	  geom_col() +
	  labs(x = NULL, y = "log_pct") +
	  coord_flip()

	
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	off years as stop words for unique decade lexicon
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	
	gt_words_70 <- gt_words_lustrum_cols[gt_words_lustrum_cols$year == 1970,]
	
	stop_words_70 <- gt_words_lustrum_cols[gt_words_lustrum_cols$year != 1970,]
	stop_words_70 <- stop_words_70[ , c("word")]
	
	stop_list_70 <- c(stop_list, stop_words_70)
	gt_stop_words <- data_frame (word = stop_list_70, lexicon = "GT_List")
	
	# ...	remove custom stop words
	gt_words_70 <- gt_words_70 %>% anti_join(gt_stop_words)
	
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	new & unique words
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	
	df_new_words <- data.frame()
	
	for (iyy in seq(from = iyear_start, to = iyear_end, by = iyear_incr))
	{
		new_words <- gt_words_lustrum_cols[gt_words_lustrum_cols$year == iyy,]
	
		old_stop_words <- gt_words_lustrum_cols[gt_words_lustrum_cols$year < iyy,]
		old_stop_words <- old_stop_words[, c("word")]
	
		old_stop_list <- c(stop_list, old_stop_words)
		gt_stop_words <- data_frame (word = old_stop_list, lexicon = "GT_List")
	
	# ...	remove custom stop words
		new_words <- new_words %>% anti_join(gt_stop_words)
		
		new_words <- new_words[order(new_words$n, decreasing = TRUE),]
		
		df_new_words <- rbind(df_new_words, new_words[1:100,])
	}
	
	
