keep_vars <- c("Min.1", "Min.0", "power_odds","cutoff_odds","cutoff_freq1","subfolder","keep_vars","remove_except", "lambda")
remove_except(keep_vars)
source("./functions/A0 Package Setup.R")
pkgload:::unload("tidytext")
source("./functions/00.2 functions_thilo.R")
source("./functions/00.3 functions_yu.R")
job <- read_rds("data/Intermediate/crs04_job_utf8_full.rds")
job_specific_suffix <- "_full_"
if(job == "gen") job_specific_suffix <- "_gen_full_"
load("data/intermediate/crs04_lang_utf8_full.rdata")


crs_path_dict <- paste0("./Data/intermediate/",subfolder,"/crs04.2_mydict_", lang, job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_corpus <- paste0("./Data/intermediate/crs04.1_crs0_", lang, job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_new_nwords <- paste0("./Data/intermediate/crs04.3_nwords0_", lang, job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_new_dtm <- paste0("./Data/intermediate/crs04.3_dtm_crs_0_", lang, job_specific_suffix, year(Sys.Date()), ".rds")

myDict <- read_rds(crs_path_dict)
corpus_crs_0 <- read_rds(crs_path_corpus)



start <- Sys.time()
# # inspect(corpus_crs_0)
nwords0 <- tidytext::tidy(corpus_crs_0) %>%
  select(text, document = id) %>%
  mutate(total = str_count(string = text, pattern = "\\S+") ) %>%
  select(-text)
write_rds(nwords0, file = crs_path_new_nwords)
print_time_diff(start)
# Time difference of 47.22929 secs


start <- Sys.time()
dtm_crs_0 <- DTM(corpus_crs_0, dict=myDict)
print_time_diff(start)
write_rds(dtm_crs_0, file = crs_path_new_dtm)
# Time difference of 424.2026 secs



