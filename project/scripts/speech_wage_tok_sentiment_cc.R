################################################################################
# Clear Namespace & Plots
################################################################################
rm(list=ls())


################################################################################
# Import Packages
################################################################################
library(readtext)
library(quanteda)
library(text2vec)
library(sentimentr)
library(tidytext)
library(textdata)
library(tidyverse)
library(stringr)
library(htmlwidgets)
library(readr)

################################################################################
# Directories
################################################################################
dir_repo = "C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\project"
dir_data = paste(dir_repo,"\\","data", sep='')
dir_data_speakers = paste(dir_data, "\\", 'speaker_n_sentiment', sep='')

################################################################################
# Import Data
################################################################################
data.speaker <- read.csv(paste(dir_data_speakers, "\\",
                               '2012_2016_segmented_speaker_sample.csv',
                               sep=''))

# Create docname comprising 'text' + index number
data.speaker$docnum <- seq(9999) 
data.speaker$doctxt <- rep("text", 9999)
data.speaker$docname <- with(data.speaker, paste0(data.speaker$doctxt, '',
                                                  data.speaker$docnum))
data.speaker$docnum <- NULL
data.speaker$doctxt <- NULL
#View(data.speaker)


################################################################################
# Segment Text By Key Words
################################################################################

# Define Words Phrases to Match
patt1 <- c("minimum wage", "wages", "wage ", "competitive wage", "competitive pay",
           "fair pay", "fair-pay", "hourly wage", "overtime",
           "wage and hour", "wage an hour",
           "part-time", "part time", "over-time", "over time", "work week",
           "work-week", "workweek")
patt1.matches <- kwic(data.speaker[,11], 
                 pattern = patt1, 
                 window = 100,
                 valuetype = "regex",
                 case_insensitive = TRUE)
#View(patt1.matches)


# Create DataFrame of Kwic Text & Combine Pre-post text
df.matches <- as.data.frame(patt1.matches)
df.matches$prepost <- paste(df.matches$pre, df.matches$post)
df.matches$pre <- NULL
df.matches$post <- NULL
View(df.matches)



################################################################################
# Create Corpus of segmented Wage & Hour Text
################################################################################

# Corpus
corpus <- corpus(df.matches, text="prepost")
#View(corpus)

# Tokens
toks <- tokens(corpus)
#View(toks)


################################################################################
# Sentiment Analysis - Wage & Hour Text
################################################################################

# Quanteda's built-in sentiment dictionary
data_dictionary_LSD2015

# Compound neg_negative and neg_positive tokens before creating a dfm object
kwic_toks_compound <- tokens_compound(toks, data_dictionary_LSD2015)

# Match Tokens w/ Sentiment Dictionary
kwic_sentiment <- dfm_lookup(dfm(kwic_toks_compound), data_dictionary_LSD2015)
#View(kwic_sentiment)

# Convert kwic_sentiment to a dataframe
df.sentiment <- convert(kwic_sentiment, to = "data.frame")
#View(df.sentiment)

# Add the document identifier column back in
df.sentiment$docname <- df.matches$docname
#View(df.sentiment)


################################################################################
# Get Sentiment - Original / All Text
################################################################################
corpus.all <- corpus(data.speaker, text='speech')
toks.all <- tokens(corpus.all)
kwic.toks.compound.all <- tokens_compound(toks.all, data_dictionary_LSD2015)
kwic.sentiment.all <- dfm_lookup(dfm(kwic.toks.compound.all), data_dictionary_LSD2015)
df.sentiment.all <- convert(kwic.sentiment.all, to = "data.frame")
df.sentiment.all$docname <- df.sentiment.all$doc_id
df.sentiment.all$doc_id <- NULL
#View(df.sentiment.all)


################################################################################
# Create Final DataFrame
################################################################################

# Merge Original Dataset & Sentiment Scores All Data
df.original.w.sent <- left_join(data.speaker, df.sentiment.all, by='docname')
View(df.original.w.sent)

# Merge W&H Sentiment & PrePost Text
df.wnh.sent.prepost <- left_join(df.matches, df.sentiment, by='docname')
df.wnh.sent.prepost$doc_id <- NULL
View(df.wnh.sent.prepost)

# Merge W&H Sentiment w/ Original Dataset
df.final <- left_join(df.origina.w.sent, df.wnh.sent.prepost,
                      by='docname', suffix = c(".all.txt", ".wnh.txt"))

View(df.final)






