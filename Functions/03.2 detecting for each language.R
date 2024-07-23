 # Start processing
df_crs <- df_crs_reduced %>%
  filter(language_title == lang2analyse) %>%
  select(-language_title)

# Select specific columns and remove duplicates based on title_id
df_crs <- df_crs %>%
  select(title_id, projecttitle_lower) %>%
  filter(!duplicated(title_id))

df_crs_backup <- df_crs

list_keywords <- readLines(paste0("data/keywords/final/statistics_reduced_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>%
  trimws()

list_keywords_gender <- readLines(paste0("data/keywords/final/gender_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>%
  trimws()

list_blacklist <- readLines(paste0("data/keywords/final/demining_small_arms_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>%
  trimws()

list_keywords_stem <- stem_and_concatenate(list_keywords, lang2analyse)
list_keywords_gender_stem <- stem_and_concatenate(list_keywords_gender, lang2analyse)
list_blacklist <- stem_and_concatenate(list_blacklist, lang2analyse)

df_crs <- df_crs %>%
  mutate(projecttitle_stem = stem_and_concatenate(projecttitle_lower, lang2analyse)) %>%
  mutate(stat_title = str_detect(projecttitle_stem, paste(list_keywords_stem, collapse = "|"))) %>%
  mutate(gen_title = str_detect(projecttitle_stem, paste(list_keywords_gender_stem, collapse = "|"))) %>%
  mutate(mining_title = str_detect(projecttitle_stem, paste(list_blacklist, collapse = "|")))

list_acronyms <- readLines(paste0("data/keywords/final/statistics_reduced_acronyms_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>%
  trimws()
list_acronyms <- paste0(" ", list_acronyms, " ")

list_acronyms_gender <- readLines(paste0("data/keywords/final/gender_acronym_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>%
  trimws()
list_acronyms_gender <- paste0(" ", list_acronyms_gender, " ")

df_crs <- df_crs %>%
  mutate(projecttitle_lower = paste0(" ", projecttitle_lower, " ")) %>%
  mutate(stat_title = str_detect(projecttitle_lower, paste(list_acronyms, collapse = "|")) | stat_title) %>%
  mutate(gen_title = str_detect(projecttitle_lower, paste(list_acronyms_gender, collapse = "|")) | gen_title)

# Load keywords and process them
list_keywords <- readLines(paste0("data/keywords/final/statistics_reduced_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>% trimws()
list_keywords_gender <- readLines(paste0("data/keywords/final/gender_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>% trimws()
list_blacklist <- readLines(paste0("data/keywords/final/demining_small_arms_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>% trimws()

# Apply stemming and concatenation
list_keywords_stem <- stem_and_concatenate(list_keywords, lang2analyse)
list_keywords_gender_stem <- stem_and_concatenate(list_keywords_gender, lang2analyse)
list_blacklist <- stem_and_concatenate(list_blacklist, lang2analyse)
print_time_diff(start)

# Detect keywords and update columns accordingly
df_crs <- df_crs %>%
  mutate(projecttitle_stem = stem_and_concatenate(projecttitle_lower, lang2analyse)) %>%
  mutate(stat_title = str_detect(projecttitle_stem, paste(list_keywords_stem, collapse = "|"))) %>%
  mutate(gen_title = str_detect(projecttitle_stem, paste(list_keywords_gender_stem, collapse = "|"))) %>%
  mutate(mining_title = str_detect(projecttitle_stem, paste(list_blacklist, collapse = "|")))

# Detect acronyms and update columns accordingly
list_acronyms <- readLines(paste0("data/keywords/final/statistics_reduced_acronyms_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>% trimws() %>% paste0(" ", ., " ")
list_acronyms_gender <- readLines(paste0("data/keywords/final/gender_acronym_", lang2analyse, "_final.txt"), encoding = "UTF-8") %>% trimws() %>% paste0(" ", ., " ")

df_crs <- df_crs %>%
  mutate(projecttitle_lower = paste0(" ", projecttitle_lower, " ")) %>%
  mutate(stat_title = str_detect(projecttitle_lower, paste(list_acronyms, collapse = "|")) | stat_title) %>%
  mutate(gen_title = str_detect(projecttitle_lower, paste(list_acronyms_gender, collapse = "|")) | gen_title) %>%
  select(-projecttitle_lower, -projecttitle_stem)

rm(df_crs_backup)
