## ??? This is used before but should I correct after changing 00.4? 
# source("Code/00.4 refining keywords.R")
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

crs_path_dict <- paste0("./Data/intermediate/",subfolder,"/crs04.2_mydict_", lang,  job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_corpus1 <- paste0("./Data/intermediate/crs04.1_crs1_", lang,  job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_nwords0 <- paste0("./Data/intermediate/crs04.3_nwords0_", lang,job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_dtm0 <- paste0("./Data/intermediate/crs04.3_dtm_crs_0_", lang,  job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_crs0 <- paste0("./Data/intermediate/crs04.0_crs0_", lang , job_specific_suffix, year(Sys.Date()), ".rds")
crs_path_new <- paste0("./Data/intermediate/",subfolder,"/crs04.4_positive_id_", lang, job_specific_suffix, year(Sys.Date()), ".rds")

myDict <- read_rds(crs_path_dict)
#myDict <- myDict[myDict != "decent work"]
#myDict <- myDict[myDict != "decent"]
#myDict <- myDict[myDict != "work"]
# Identify items containing "decent" or "advocacy"
contains_decent_or_advocaci_or_outcom_effect <- grepl("decent", myDict, ignore.case = TRUE) | 
  grepl("advocaci", myDict, ignore.case = TRUE) |
  grepl("outcom effect", myDict, ignore.case = TRUE) 

# Print the items that will be dropped
dropped_items <- myDict[contains_decent_or_advocaci_or_outcom_effect]
print(dropped_items)

# Remove items containing "decent" or "advocacy"
myDict <- myDict[!contains_decent_or_advocaci_or_outcom_effect]


# Wait for user input to continue
#readline(prompt="Press Enter to continue...")
# Start browser for interactive debugging
#browser()

corpus_crs_1 <- read_rds(crs_path_corpus1)
nwords0 <- read_rds(crs_path_nwords0)
dtm_crs_0 <- read_rds(crs_path_dtm0)
df_crs_0 <- read_rds(crs_path_crs0)

start <- Sys.time()
freq <- DTM(corpus_crs_1, dict =myDict) %>%
  tidytext::tidy() %>%
  group_by(document) %>%
  summarise(count = sum(count))
print_time_diff(start)
# Time difference of 10.85936 secs

nwords1 <- tidytext::tidy(corpus_crs_1) %>%
  select(text, document = id) %>%
  mutate(total = str_count(string = text, pattern = "\\S+") ) %>%
  select(-text)
print_time_diff(start)

nwords1 <- nwords1 %>%
  left_join(freq) %>%
  filter(total != 0) %>%
  mutate(count = ifelse(is.na(count), 0, count)) %>%
  mutate(percentage = count/total) 
beep()

threshold <- nwords1 %>%
  filter(count > 0) %>%
  .$percentage %>%
  mean

print(paste("Threshold:", threshold))
print("mean:")
mean(nwords1$percentage, na.rm = T) %>% print()
print("median:")
median(nwords1$percentage, na.rm = T) %>% print()


list_identified <- tidytext::tidy(dtm_crs_0) %>%
  filter(term %in% myDict) %>% 
  group_by(document) %>%
  summarise(count = sum(count)) %>%
  inner_join(nwords0) %>%
  filter(total > 0) %>% 
  mutate(percentage  = count/total) %>%
  filter(percentage > threshold) %>%
  arrange(percentage) %>% #  sort the results by the percentage
  .$document %>%
  as.numeric
print_time_diff(start)

positive_desc_id <- df_crs_0 %>%
  mutate(document = 1:nrow(df_crs_0)) %>%
  filter(document %in% list_identified) %>%
  arrange(match(document, list_identified)) %>% # ensure the order is preserved as in list_identified
  .$desc_2mine_id 
beep()

#df_crs_0 %>% filter(desc_2mine_id %in% positive_desc_id) %>% .$description %>% head(20) %>%  print 
# a = df_crs_0 %>% 
#   select(text_id, description) %>% 
#   filter(text_id %in% positive_text_id)
# 
# b = df_crs_0 %>% 
#   select(text_id, description) %>% 
#   filter(text_id %in% positive_text_id1)
# 
# c = full_join(a, b, by = "text_id") %>%
#   filter(is.na(description.x)|is.na(description.y))
# c$description.x

write_rds(positive_desc_id, file = crs_path_new)

print_time_diff(start)
# rm(list = ls())
gc()
# time spent for 1/40 of projects: 1.416996 mins