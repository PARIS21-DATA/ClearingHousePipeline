# Create a document-term matrix (DTM)
dtm <- DocumentTermMatrix(Corpus(VectorSource(combined_df$cleaned_description)))

# Compute TF-IDF scores
tfidf <- weightTfIdf(dtm)

# Convert to tidy format
tfidf_tidy <- tidy(tfidf)

# Calculate z-scores for TF-IDF values
tfidf_tidy <- tfidf_tidy %>%
  group_by(term) %>%
  mutate(z_score = (tf_idf - mean(tf_idf)) / sd(tf_idf))

# Set cutoffs using z-scores
cutoff_z_score <- 1.96  # Corresponds to 95% confidence interval
selected_terms <- tfidf_tidy %>%
  filter(z_score > cutoff_z_score) %>%
  pull(term)