'Gsu Legal Analytics
 Homework 4
 02/07/2021

 Instructions: 
  1.) Choose a set of key words or phrases that are useful for your team project
      and use GloVe word embeddings to find additional synonyms within the
      corpus. List any new words as a #comment.
  2.) Generate a frequency table showing the appearances per document of your
      key words/phrases using the dfm_select or dfm_lookup function.
  3.) Use the kwic function to extract a text window around one of your key
      words or phrases and combine the pre- and post- windows.
  4.) Choose one of the following and analyze the text windows: readability,
      lexical diversity, or one of the sentiment analysis approaches.
  5.) Write a few sentences at the end about what this analysis shows you
      (include this as # comments at the end of your R script).

'
################################################################################
# Load Libraries
################################################################################
library(readtext)
library(quanteda)
library(text2vec)
library(sentimentr)
library(tidytext)
library(textdata)
library(textclean)
library(ggplot2)

################################################################################
# Set Directories
################################################################################
dir_base = 'C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course'
dir_data = file.path(dir_base, '\\data')
dir_crec = file.path(dir_data, '\\crec\\2018_2020_txt')
dir_hw = file.path(dir_base, '\\hw\\hw4')



################################################################################
# Load Data
################################################################################

# Nlra Text
nlra.txt <- readtext(paste0(dir_data, "\\nlra.txt"))
setwd(dir_data)

# Congressional Texts
setwd(dir_crec)
cr.txt <- readtext("*.txt")
cr.txt <- cr.txt$text


################################################################################
# 1.) Get Tokens of Interest
################################################################################
en.sw <- stopwords("en")
cr.ascii <- replace_non_ascii(cr.txt, replacement="", remove.nonconverted=TRUE)
cr.corpus <- corpus(cr.ascii)

cr.tk.1gram <- tokens_wordstem(
                 tokens_select(
                 tokens(cr.corpus, remove_punct=TRUE,
                        remove_symbols=TRUE, remove_numbers=TRUE),
                        pattern=en.sw, selection="remove")
                 )

cr.tk.2gram <- tokens_ngrams(cr.tk.1gram, n=2)

# Get 1 Gram Dfm
cr.1gram.dfm <- dfm(cr.tk.1gram)
cr.tf.1gram <- textstat_frequency(cr.1gram.dfm)
head(cr.tf.1gram, n=200)
ggplot(cr.tf.1gram[1:20, ], aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() + coord_flip() + labs(x = NULL, y = "Frequency")
tk.of.int.1gram <- c('labor', 'employe', 'employ', 'board', 'servic', 'unfair',
               'collect', 'concili', 'right')
# Get Bi-Gram Dfm
cr.2gram.dfm <- dfm(cr.tk.2gram)
cr.tf.2gram <- textstat_frequency(cr.2gram.dfm)
head(cr.tf.2gram, n=100)
cr.tf.2gram$feature[1:100]
ggplot(cr.tf.2gram[1:20, ], aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() + coord_flip() + labs(x = NULL, y = "Frequency")
tk.of.int.2gram <- c('labor_organ', 'unfair_labor', 'labor_practic',
                     'repres_employe', 'labor_disput', 'collect_bargain',
                     'employe_employ', 'nation_labor')

################################################################################
# 2.) Generate Frequency Table - Appearance of Tokens of Interest
################################################################################

cr.corpus = corpus(cr.txt)
cr.tk.1gram <- tokens_wordstem(
               tokens_select(
               tokens(cr.corpus, remove_punct=TRUE,
               remove_symbols=TRUE, remove_numbers=TRUE),
               pattern=en.sw, selection="remove")
               )
cr.tk.2gram <- tokens_ngrams(cr.tk.1gram, n=2)

cr.dfm.1gram <- dfm(cr.tk.1gram)
cr.dfm.2gram <- dfm(cr.tk.2gram)

cr.dfm.kw.1gram <- dfm_select(cr.dfm.1gram, pattern=tk.of.int.1gram, selection="keep")
cr.dfm.kw.2gram <- dfm_select(cr.dfm.2gram, pattern=tk.of.int.2gram, selection="keep")

cr.tf.1gram <- textstat_frequency(cr.dfm.kw.1gram)
cr.tf.2gram <- textstat_frequency(cr.dfm.kw.2gram)

cr.tf.1gram
cr.tf.2gram


# Frequency Co-occurance Matrix
fcm <- fcm(cr.tk.1gram, 
           context = "window", 
           count = "weighted", 
           weights = 1 / (1:5), 
           tri = TRUE)
# Glove Word Embedding
glove <- GlobalVectors$new(rank = 50, x_max = 10)
# Apply model to fcm
fcm_tokens <- glove$fit_transform(fcm, n_iter = 20)
fcm_tokens
# Create list of N most similar words
## Create function for finding list of the N most similar terms
most_similar = function(x,y,method="cosine",N=10)
{
  most_sim=head(sort(
    sim2(x, x[y, , drop=FALSE], 
         method=method)[,1], decreasing=TRUE), N)
  return(list(top_words=most_sim))
}
most_similar(fcm_tokens, "prayer")


################################################################################
# 3.) Use the kwic function to extract a text window around one of your key
################################################################################

prayer <- as.data.frame(kwic(cr.corpus, pattern='prayer', window=10))
prayer.pre.post <- paste(prayer$pre, prayer$post)
prayer.corpus <- corpus(prayer.pre.post)
prayer.corpus
prayer.tk <- tokens_wordstem(
             tokens_select(
             tokens(prayer.pre.post, remove_punct=TRUE,
             remove_symbols=TRUE, remove_numbers=TRUE),
             pattern=en.sw, selection="remove"))
prayer.tk.dfm = dfm(prayer.tk)
prayer.tf <- textstat_frequency(prayer.tk.dfm)
ggplot(prayer.tf[1:20, ], aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() + coord_flip() + labs(x = NULL, y = "Frequency")

################################################################################
# 4.) Sentiment Analysis
################################################################################
kwic.setiment <- as.data.frame(dfm_lookup(prayer.tk.dfm, data_dictionary_LSD2015))
View(kwic.setiment)

neg.sum <- sum(kwic.setiment$negative)
pos.sum <- sum(kwic.setiment$positive)

neg.sum
pos.sum

'Comments
  Based on the sum of the positive and negative sentences that contained the
  term "prayer" it would appear that for this particular coprus the sentiment
  was largely positive

'


