# AUTHOR:     Charlotte Alexander
# COURSE:     MSA 8350/ LAW 7675
# PURPOSE:    Text comparison methods
# DATE:       February 18, 2021

# This code covers:
# Text similarity measures: e.g. generate a cosine similarity measure for Republicans' speeches versus Democrats'
# Term frequency - Inverse document frequency (TF-IDF): identify keywords that most effectively distinguish one subset of text from another, e.g. by speaker political party
# Keyness measures: same, but using chi-squared metric

# Load the relevant libraries
library(quanteda)
library(ggplot2)

# This code uses a set of pre-segmented speeches and speaker information 
# from the 114th Congress from the Stanford set, from two text files: 
# 114_SpeakerMap.txt and speeches_114.txt

# Take a look at the video and member list on Teams for more explanation.

# Our 2018-2020 (or 2017-2020 if you include it) CR text will have the same format 
# after you segment by speaker and merge in speaker covariates.

setwd("C:/Users/charl/Dropbox/Courses/LA2 S21/data/112-114_stanford_text_files")

# Read in the speaker map and text
cr_114speaker <- read.table("114_SpeakerMap.txt", header = TRUE, sep = "|")
cr_114txt <- read.table("speeches_114.txt", header = TRUE, sep = "|",
                        na.strings=".", quote="", fill = TRUE)

# Merge on speech_id
cr_114_merged <- merge(cr_114speaker, cr_114txt, by = "speech_id")

View(head(cr_114_merged))

# Create a corpus
cr_114corpus <- corpus(cr_114_merged, text = "speech")

# Create a dfm with some cleaning steps; group by party
cr_114dfm <- dfm(cr_114corpus, 
               groups = "party", 
               remove = stopwords("en"), 
               remove_punct = TRUE, 
               remove_numbers = TRUE,
               remove_symbols = TRUE)

########################### COMPARISON EXPLORATION ###########################

# A bit of exploration
# Plot most frequent words [top 10] by party
tstat_party <- textstat_frequency(cr_114dfm, n = 20, groups = "party")

tstat_party

# Generate the plot 
ggplot(data = tstat_party, aes(x = factor(nrow(tstat_party):1), y = frequency)) +
  geom_point() +
  facet_wrap(~ group, scales = "free") +
  coord_flip() +
  scale_x_discrete(breaks = nrow(tstat_party):1,
                   labels = tstat_party$feature) +
  labs(x = NULL, y = "Relative Frequency by Party")

# Generate a comparison word cloud
# Open a new plot window for better viewing
dev.new(width = 1000, height = 1000, unit = "px")

textplot_wordcloud(cr_114dfm, comparison = TRUE)

########################### TEXT SIMILARITY MEASURES ###########################

# Compute cosine similarity by party
# Closer to 1 = more similar
# https://quanteda.io/reference/textstat_simil.html

tstat_cosine <- textstat_simil(cr_114dfm, method = "cosine", margin = "documents")
tstat_cosine_df <- as.data.frame(tstat_cosine)
View(tstat_cosine_df)

####################################### TF-IDF #######################################

# Identify words by relative importance, party comparison 
# https://quanteda.io/reference/dfm_tfidf.html

# Values will be higher when the term appears frequently in a document (or party, in our case) 
# but infrequently across the all documents (or groups).

cr_114tfidf <- dfm_tfidf(cr_114dfm)

# Frequency
cr_114tfidf_freq <- textstat_frequency(cr_114tfidf, n = 10, groups = "party", force = TRUE)

# Plot
ggplot(data = cr_114tfidf_freq, aes(x = factor(nrow(cr_114tfidf_freq):1), y = frequency)) +
  geom_point() +
  facet_wrap(~ group, scales = "free") +
  coord_flip() +
  scale_x_discrete(breaks = nrow(cr_114tfidf_freq):1,
                   labels = cr_114tfidf_freq$feature) +
  labs(x = NULL, y = "Term Frequency-Inverse Document Frequency by Party")

####################################### KEYNESS #######################################

# Alternative method: keyness, computed by chi-square
# https://tutorials.quanteda.io/statistical-analysis/keyness/
# https://quanteda.io/reference/textstat_keyness.html

# Specify a target value from the groups: Republican
cr_114keyness <- textstat_keyness(cr_114dfm, target = "R")

# Plot: Republican versus Democrat + Independent
textplot_keyness(cr_114keyness, n = 20, show_reference = TRUE,
                 margin = 0.1, labelsize = 3, 
                 color = c("red", "blue")) + 
  ggtitle("Key Words in Republican and Democractic/Independent Speeches")

