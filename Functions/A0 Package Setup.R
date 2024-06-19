# Define a vector of required packages
packages <- c(
  "tidyverse",
  "readxl",
  "openxlsx",
  "reader",
  "zoo", 
  "countrycode", 
  "beepr", 
  "cld2", 
  "koRpus", 
  "SnowballC", 
  "tidytext", 
  "stringdist",
  "tm", 
  "data.table", 
  "kableExtra",
  "rmarkdown",
  "feather", # for quick save and read of files
  "digest", # hash value generator
  "stringi", # case-insensitive string matching
  "scales", # percentage format conversion
  "gridExtra", # charts side by side
  "grDevices", # create colours
  "arrow",
  "stopwords"
)

# Function to install packages if not already installed
install_if_missing <- function(pkg) {
  if (!pkg %in% installed.packages()[, "Package"]) {
    tryCatch({
      install.packages(pkg, repos = "https://cloud.r-project.org")
    }, warning = function(w) {
      message(sprintf("Warning for package '%s': %s", pkg, w$message))
    }, error = function(e) {
      message(sprintf("Error for package '%s': %s", pkg, e$message))
    })
  }
}

# Install missing packages
lapply(packages, install_if_missing)

# Check for any packages not installed and provide instructions
not_installed <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(not_installed) > 0) {
  message("The following packages could not be installed: ", paste(not_installed, collapse = ", "))
  message("Please check for alternative installation methods or compatibility issues.")
}

lapply(packages, library, character.only = TRUE)
rm(packages)
gc()


# Function to print time difference
print_time_diff <- function(start_time) {
  print(difftime(Sys.time(), start_time, units = "sec"))
}