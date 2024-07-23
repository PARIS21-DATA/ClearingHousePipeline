keep_vars <- c("Min.1", "Min.0", "power_odds","cutoff_odds","cutoff_freq1","subfolder","keep_vars","remove_except")
remove_except(keep_vars)
source("./functions/A0 Package Setup.R")
source("./functions/00.2 functions_thilo.R")
source("./functions/00.3 functions_yu.R")

pkgload:::unload("tidytext") # the stemmer in tidy text might be problematic for our steps here. 

# Load the job data
job <- read_rds("data/Intermediate/crs04_job_utf8_full.rds")
job_specific_suffix <- "_full_"
if(job == "gen") job_specific_suffix <- "_gen_full_"

# Load language data
load("data/intermediate/crs04_lang_utf8_full.rdata")

crs_path_0 <- paste0("./Data/intermediate/crs04.0_crs0_", lang, job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_1 <- paste0("./Data/intermediate/crs04.0_crs1_", lang,  job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_new_1_rdata <- paste0("./Data/intermediate/crs04.1_crs1_", lang, job_specific_suffix, year(Sys.Date()), ".rdata")
crs_path_new_1_rds <- paste0("./Data/intermediate/crs04.1_crs1_", lang, job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_new_0_rdata <- paste0("./Data/intermediate/crs04.1_crs0_", lang, job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_new_0_rds <- paste0("./Data/intermediate/crs04.1_crs0_", lang,  job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_new_rdata <- paste0("./Data/intermediate/",subfolder,"/crs04.1_freq10_eligibleWords_", lang,  job_specific_suffix, year(Sys.Date()), ".rdata")

# Define paths for the time consuming files
corpus_file <- paste0("./Data/intermediate/", lang,  job_specific_suffix, year(Sys.Date()),"corpus_crs_0.rds")
dtm_file <- paste0("./Data/intermediate/", lang,  job_specific_suffix, year(Sys.Date()),"corpus_crs_0_simpleDTM")



df_crs_1 <- read_rds(crs_path_1)
df_crs_0 <- read_rds(crs_path_0)

start <- Sys.time()

# Set minimum frequency threshold
#Min.1 <- 0.1 ## only consider words that are in more than 10% of statistical projects
#Min.0 <- 0.1

# Preprocess the descriptions and create the document-term matrix (DTM) for df_crs_1
corpus_crs_1 <- preprocessingV(df_crs_1$description, language=language)
print_time_diff(start)

# dtm_crs_1 <- DTM(corpus_crs_1, Min=Min.1, Max=1)
dtm_crs_1 <- NA
print_time_diff(start)
corpus_crs_1_simpleDTM <- DTM(corpus_crs_1)
print_time_diff(start)

# Calculate word frequencies for df_crs_1
freq_all1 <- corpus_crs_1_simpleDTM %>% 
  tidytext::tidy() %>%
  group_by(term) %>%
  summarise(cnt = sum(count)) %>%
  ungroup() %>%
  mutate(total = sum(cnt)) %>%
  mutate(freq = cnt / total)
print_time_diff(start)

# Identify eligible words in df_crs_1 based on frequency
eligible_words_in_doc_1 <- corpus_crs_1_simpleDTM %>% 
  tidytext::tidy() %>%
  select(document, term) %>%
  group_by(term) %>% 
  summarise(cnt = n()) %>%
  arrange(desc(cnt)) %>%
  filter(cnt > (length(corpus_crs_1)/100)) %>% # filter by frequency
  .$term
print_time_diff(start)


# Save the processed data for df_crs_1
save(eligible_words_in_doc_1,
       corpus_crs_1,
       dtm_crs_1,
       corpus_crs_1_simpleDTM,
       freq_all1,
     file = crs_path_new_1_rdata)

write_rds(corpus_crs_1, file = crs_path_new_1_rds)

start <- Sys.time()
# Function to perform preprocessing if file does not exist
preprocess_and_save_corpus <- function(data_frame, language) {
  corpus <- preprocessingV(data_frame$description, language=language)
  saveRDS(corpus, corpus_file)
  return(corpus)
}

# Function to create and save DTM if file does not exist
create_and_save_DTM <- function(corpus) {
  dtm <- DTM(corpus)
  saveRDS(dtm, dtm_file)
  return(dtm)
}

# Load or generate corpus
if (file.exists(corpus_file)) {
  corpus_crs_0 <- readRDS(corpus_file)
  print("Loaded corpus from file.")
} else {
  corpus_crs_0 <- preprocess_and_save_corpus(df_crs_0, language)
  print("Created and saved new corpus to file.")
}
print_time_diff(start)

# Load or generate DTM
if (file.exists(dtm_file)) {
  corpus_crs_0_simpleDTM <- readRDS(dtm_file)
  print("Loaded DTM from file.")
} else {
  corpus_crs_0_simpleDTM <- create_and_save_DTM(corpus_crs_0)
  print("Created and saved new DTM to file.")
}
print_time_diff(start)

## not time consuming 
freq_all0 <- corpus_crs_0_simpleDTM %>% 
  tidytext::tidy() %>%
  group_by(term) %>%
  summarise(cnt = sum(count)) %>%
  ungroup() %>%
  mutate(total = sum(cnt)) %>%
  mutate(freq = cnt / total)
# beepr::beep(2)


## not time consuming
# Calculate odds ratios and arrange by descending order
freq_all_1_0 = right_join(freq_all0, freq_all1, by = "term") %>%
  mutate(odds = freq.x/freq.y) %>%
  arrange(desc(odds), desc(freq.y))

save(corpus_crs_0,
     corpus_crs_0_simpleDTM,
     freq_all0,
     freq_all_1_0, 
     file = crs_path_new_0_rdata)


save(freq_all_1_0,
     eligible_words_in_doc_1,
     dtm_crs_1,
     file = crs_path_new_rdata)

write_rds(corpus_crs_0, file = crs_path_new_0_rds)

print_time_diff(start)

beep()

