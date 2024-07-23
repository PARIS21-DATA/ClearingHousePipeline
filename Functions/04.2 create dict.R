keep_vars <- c("Min.1", "Min.0", "power_odds","cutoff_odds","cutoff_freq1","subfolder","keep_vars","remove_except", "lambda")
remove_except(keep_vars)
source("./functions/A0 Package Setup.R")
source("./functions/00.2 functions_thilo.R")
source("./functions/00.3 functions_yu.R")
pkgload:::unload("tidytext") # the stemmer in tidy text might be problematic for our steps here. 
job <- read_rds("data/Intermediate/crs04_job_utf8_full.rds")
job_specific_suffix <- "_full_"
if(job == "gen") job_specific_suffix <- "_gen_full_"
load("data/intermediate/crs04_lang_utf8_full.rdata")

crs_path <- paste0("./Data/intermediate/",subfolder,"/crs04.1_freq10_eligibleWords_", lang, job_specific_suffix, year(Sys.Date()), ".rdata")
crs_path_new_rdata <- paste0("./Data/intermediate/crs04.2_dicts_", lang ,job_specific_suffix, year(Sys.Date()), ".rdata")
crs_path_new_rds <- paste0("./Data/intermediate/",subfolder,"/crs04.2_mydict_", lang, job_specific_suffix, year(Sys.Date()), ".rds")

load(crs_path)


# Define cutoff values for filtering terms
#cutoff_freq1 = 0.0005 # is there a median we can take?
#cutoff_odds = 10^(-1.5)


# Calculate median and interquartile range（IQR） for frequency
#median_freq <- median(freq_all_1_0$freq.y)
#iqr_freq <- IQR(freq_all_1_0$freq.y)

# Set cutoff using median and IQR
#cutoff_freq1 <- median_freq - 1.5 * iqr_freq
#cutoff_freq1 <- ifelse(cutoff_freq1 < 0, 0, cutoff_freq1) # Ensure cutoff is non-negative


# Filter terms based on frequency and odds
start <- Sys.time()
dict_tf_idf <- freq_all_1_0 %>% 
  filter(term %in% eligible_words_in_doc_1) %>% 
  filter(#freq.y > cutoff_freq1, # the tf-idf keywords will be limited by the frequencies
    odds < cutoff_odds) %>%
  # slice(1:100) %>% 
  .$term
print_time_diff(start)

# Further filter terms to single words
freq_all_1_0 %>%
  filter(term %in% dict_tf_idf) %>%
  mutate(terml =str_count(string = term, pattern = "\\S+") ) %>% 
  filter(terml==1) %>%
  data.frame() 
print_time_diff(start)



# Plot histogram of log odds for terms with frequency above the cutoff
#freq_all_1_0 %>%
  #filter(freq.y > cutoff_freq1) %>%
#  mutate(log_odds = log10(odds)) %>%
#  .$log_odds %>%
#  hist()

# Identify and print common words with odds greater than 10
common_words <- freq_all_1_0 %>% 
  filter(odds > 10) %>%
  pull(term)
print(common_words)
print_time_diff(start)

# Update dictionary
myDict <- dtm_crs_1$dimnames$Terms  # Initialize myDict with terms from dtm_crs_1
myDict <- unique(c(myDict, dict_tf_idf))  # Add terms from dict_tf_idf and ensure uniqueness
myDict <- myDict[!(myDict %in% common_words)]  # Remove terms that are in common_words
#myDict <- unique(dict_tf_idf)  # this line deactivate Min_1
myDict <- unique(myDict) # Ensure myDict contains only unique terms after removals, and this line will activate Min_1 

# Print filtered dictionary terms
freq_all_1_0 %>% 
  filter(term %in% myDict) %>%
  print

# Save the updated dictionary and other relevant dat
save(dict_tf_idf, 
     #common_words, 
     myDict, file = crs_path_new_rdata)

write_rds(myDict,file = crs_path_new_rds)
