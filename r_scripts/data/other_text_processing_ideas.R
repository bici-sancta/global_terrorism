

# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ...	time based mapping
# ...	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

	gt_words_lustrum_cols$timestamp <- ymd(paste0(gt_words_lustrum_cols$year, "-01-01"))
	
	words_by_time <- gt_words_lustrum_cols %>%
	  mutate(time_floor = floor_date(timestamp, unit = "10 years")) %>%
	  count(time_floor, word) %>%
	  ungroup() %>%
	  group_by(time_floor) %>%
	  mutate(time_total = sum(nn)) %>%
	  group_by(word) %>%
	  mutate(word_total = sum(nn)) %>%
	  ungroup() %>%
	  rename(count = nn) %>%
	  filter(word_total > 100)

	words_by_time
	
	
# ...	log-odds ratios
	
library(tidyr)
library(readr)
library(dplyr)

gt_words_lustrum_cols$year <- as.factor(gt_words_lustrum_cols$year)

gt_words_col <- gt_words_lustrum_cols %>% 
  select(year, word, pct) %>% 
  spread(year, pct) %>%
  arrange("1970", "1980", "1990", "2000", "2010")
