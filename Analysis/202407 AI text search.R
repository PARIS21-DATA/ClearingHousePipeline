#### Prerequisite
## Before working with this script, make sure your dataset has the following columns: 
# title_id, projecttitle (char), language_title (char)
# these columns are generated in previous steps

## You also need the following functions under the Functions folder
# functions/A0 Package Setup.R
# functions/00.1a functions_stem_and_concat.R

## you also need to save your keywords list in the files below
# data/keywords/final/AI_en_final.txt
# data/keywords/final/AI_acronyms_en_final.txt

rm(list = ls())
gc()
Sys.sleep(10)
source("code/00. boot.R")
source("code/00.1a functions_stem_and_concat.R")

job_specific_suffix <- "_full_"
path_input_crs <- paste0("./Data/intermediate/crs02 new columns", job_specific_suffix, year(Sys.Date()), ".feather")
path_output_intermediate_crs <- paste0("./Data/intermediate/crs03_intermediate_", job_specific_suffix, year(Sys.Date()), ".feather")
start <- Sys.time()
df_crs_full <- read_feather(path_input_crs)
print("Load file:")
print_time_diff(start)
# Time difference of 24.98078 secs

df_crs_full <- df_crs_full %>%
  mutate(projecttitle_lower = tolower(projecttitle)) # %>%
  # mutate(title_id = as.numeric(as.factor(projecttitle_lower))) 


## convert project to lower cases to assist text search
df_crs_reduced <- df_crs_full %>%
  select(title_id, projecttitle_lower, language_title) %>%
  filter(!duplicated(title_id)) 
  
langs = c("en"
          # ,
          #  "fr"
          # , "es"
          # , "de"
          )
print_time_diff(start)
# Time difference of 56.87824 secs

start <- Sys.time()
list_df_crs <- list()
for (i in 1:length(langs)) {
  lang2analyse <- langs[i]
  ###### start of the analysis
  df_crs <- df_crs_reduced %>%
    filter(language_title == lang2analyse) %>% ##??? to solve later 
    select(-language_title)
  
  df_crs_backup <- df_crs
  
  # df_crs <- df_crs %>%
  #   select(title_id, projecttitle_lower) %>%
  #   filter(!duplicated(title_id)) 
  
  # beep(4)
  list_keywords <- readLines(paste0("data/keywords/final/ai_", lang2analyse, "_final.txt")
                             ,encoding = "UTF-8"
  )  %>%
    trimws()
  
  
  list_keywords_stem <- stem_and_concatenate(list_keywords, lang2analyse)
  
  print_time_diff(start)
  
  df_crs <- df_crs %>%
    # select(db_ref, projecttitle, scb) %>%
    # mutate(projecttitle = tolower(projecttitle)) %>%
    mutate(projecttitle_stem = stem_and_concatenate(projecttitle_lower, lang2analyse)) %>%
    mutate(ai_title = str_detect(projecttitle_stem, paste(list_keywords_stem, collapse = "|"))) 
  print_time_diff(start)
  
  ## detect acronyms, which don't need stemming
  list_acronyms <- readLines(paste0("data/keywords/final/AI_acronyms_", lang2analyse, "_final.txt"), encoding = "UTF-8")  %>%
    trimws()
  list_acronyms <- paste0(" ", list_acronyms, " ")
  
  
  df_crs <- df_crs %>%
    mutate(projecttitle_lower = paste0(" ", projecttitle_lower, " ")) %>%
    mutate(ai_title = str_detect(projecttitle_lower, paste(list_acronyms, collapse = "|"))  | ai_title) 
  
  df_crs <- df_crs %>%
    # mutate(text_detection_wo_mining = text_detection & !mining) %>%
    select(-projecttitle_lower, -projecttitle_stem)
  
  rm(df_crs_backup)
  
  
  list_df_crs[[i]] <- df_crs
  rm(df_crs)
}
print_time_diff(start)
df_crs <- bind_rows(list_df_crs)
rm(list_df_crs)
print_time_diff(start)
gc()
beep()
## joining the filtering results back with the full version of data
df_crs <- df_crs_full %>% 
  left_join(df_crs) %>%
  select(-projecttitle_lower)
beep()

df_crs %>% 
  write_feather(path_output_intermediate_crs)

names(df_crs)

gc()
