source("./functions/00.2 functions_thilo.R")
source("./functions/00.3 functions_yu.R")
job <- read_rds("data/Intermediate/crs04_job_utf8_full.rds")
job_specific_suffix <- "_full_"
crs_path <- paste0("./Data/intermediate/crs03",
                   job_specific_suffix, year(Sys.Date()), ".feather")


# Load the job data
if(job == "gen") job_specific_suffix <- "_gen_full_"
load("data/intermediate/crs04_lang_utf8_full.rdata")


# Define file paths
crs_path_new_1 <- paste0("./Data/intermediate/crs04.0_crs1_", lang,job_specific_suffix, year(Sys.Date()),  ".rds")
crs_path_new_0 <- paste0("./Data/intermediate/crs04.0_crs0_", lang,job_specific_suffix, year(Sys.Date()), ".rds")


start <- Sys.time()

df_crs <- read_feather(crs_path)

#drop duplicated df_crs (updated on Jun 28)
df_crs <- df_crs[!duplicated(df_crs$desc_2mine_id), ]

print_time_diff(start)


# Filter and select data based on job type
if(job == "gen") {
  df_crs_1 <- df_crs %>% 
    filter( gen_markers_title
            , language_desc==lang
    ) %>% 
    filter(!duplicated(desc_2mine_id)) %>%
    select(description = desc_2mine, desc_2mine_id)
  
  df_crs_0 <- df_crs %>%
    filter(!gen_markers_title
            , language_desc==lang
    ) %>% 
    filter(!duplicated(desc_2mine_id)) %>%
    select(description = desc_2mine, desc_2mine_id)
  print_time_diff(start)
} else {
  
  df_crs_1 <- df_crs %>%
    filter( stat_title_ppcode
            , language_desc==lang
    ) %>% 
    filter(!duplicated(desc_2mine_id)) %>%
    select(description = desc_2mine, desc_2mine_id)
  
  df_crs_0 <- df_crs %>%
    filter( !stat_title_ppcode
            , language_desc==lang
    ) %>% 
    filter(!duplicated(desc_2mine_id)) %>%
    select(description = desc_2mine, desc_2mine_id)
  print_time_diff(start)
  
}

write_rds(df_crs_0, file = crs_path_new_0)
write_rds(df_crs_1, file = crs_path_new_1)

