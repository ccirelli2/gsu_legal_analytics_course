# AUTHOR:     Charlotte Alexander
# COURSE:     MSA 8350/ LAW 7675
# PURPOSE:    Text exploration and visualization
# DATE:       January 21, 2021

# Download the Congressional Record txt files [not the pdf files] from Teams 
# Save them on your computer

# This is a pre-written starter script for you to use.
# Use "save as" to save it on your own computer, and save modifications you make to it.
# We encourage you to annotate/comment/mark up your code; make it your own.

# R requires packages in addition to its base installation.
# These packages will only need to be installed once.
# They bring in a number of user-written functions or libraries.
# Googling the package name will open up a host of support materials, 
# including the official documentation on CRAN.
# Ref : https://cran.r-project.org/web/packages/quanteda/vignettes/quickstart.html

install.packages("readtext")
install.packages("quanteda")
install.packages("ggplot2")

# Resources for quanteda packages: 
# https://tutorials.quanteda.io/
# https://muellerstefan.net/files/quanteda-cheatsheet.pdf

# Every time you start R you will need to reload the libraries relevant to your installed packages.

library(readtext)
library(quanteda)
library(ggplot2)

# Set your working directory to the folder on your computer where your data is saved.
# Note that R uses forward slashes rather than back slashes in file paths.
# You can also use the menus at the top of the screen: Session > Set Working Directory > Choose Directory
# Note that a "directory" is a folder
    
setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\week3\\txt_data")
# Above is Prof. Alexander's working directory; you'll need to set your own
# This script runs only on the 2018 Cong. Rec. documents. 
# You will need to run your homework on the full set of 2018-2020 documents. 

# Read in your dataset
cr_txt <- readtext("*")

# Explore your cr_txt object  
cr_txt
summary(cr_txt)
str(cr_txt)
head(cr_txt)
tail(cr_txt)

# Create a corpus from your text object
cr_corpus <- corpus(cr_txt)


# Check it out
ndoc(cr_corpus)
class(cr_corpus)

# Convert your corpus to a document-feature-matrix (dfm)
cr_dfm <- dfm(cr_corpus)  # Does this do any preprocessing?  How does it tokenize?
                          # According to the professor it tokenizes based on white spaces
                          # and standalone punctuation (so essentially str.split(' '))

# View the top (head) of the dfm
View(head(cr_dfm))

# Generate a list of all unique tokens by term frequency and document frequency.
textstat_frequency(cr_dfm)

# Are all of these useful words?  What about symbols and punctuation?

# Quanteda has built-in functions for dropping stopwords, symbols, numbers
# Refer to week 3 reading (Denny & Spirling) for more information on text cleaning
stopwords("en")
print('hello world')

# You can customize your list of stopwords by removing or adding terms.

# Remove words from the standard stopwords list
my_stopwords <- stopwords('en')

my_stopwords = my_stopwords[-c(which(my_stopwords=="i"))] #Take off of stopword list "i"

my_stopwords
summary(my_stopwords)
help(summary)

# Add words to the standard stopwords list 
my_stopwords <- c("economic", my_stopwords)
my_stopwords <- c(-c(which(my_stopwords=="i")))

# Read words in from a txt file in your working directory or elsewhere
more_stopwords <- readLines("C:/Users/calexander/Dropbox/Courses/LA2 S21/more_stopwords.txt")

# Add them to your stopwords list
my_stopwords <- c(my_stopwords, more_stopwords)

# Re-run the dfm step with cleaning steps added
cr_dfm_clean <- dfm(cr_corpus,
                remove = my_stopwords, # can sub in 'en' vs my_stopwords to get all english stopwords
                remove_punct = TRUE,
                remove_numbers = TRUE,
                remove_symbols = TRUE)


# You can also stem the words in your corpus
# Do this as a second step after removing stopwords
cr_dfm_cleaner <- dfm(cr_dfm_clean, stem = TRUE)

# You can also trim the dfm, cutting out terms that don't occur enough times, 
# or that don't occur in enough documents. 

# min_docfreq sets the minimum number of documents in which the word must appear
# min_termfreq sets the minimum number of times, overall, that the word must appear in the whole corpus

cr_dfm_trimmed <- dfm_trim(cr_dfm_cleaner,
                     min_docfreq=5,
                     min_termfreq=10)
cr_dfm_trimmed

# A side note on saving: to save individual objects, especially those that take some time to generate,
# or to save everything in your workspace, do the following:

save(cr_dfm_trimmed, file = "cr_dfm_trimmed.RData") # to save an individual object
save.image(file = "2021_1_19_workspace.RData") # to save the entire workspace

# Then when you start your next R session, either open it via the File menu or load()

# Continuing with the dfm

# Now re-run the frequency table
textstat_frequency(cr_dfm_trimmed)

# Go back throug the steps above if you need to do more cleaning
# Note for later --> do we want to drop Mr.?  Identifier of speakers?

# Once you are happy with your word list, explore some visualizations: plots and word clouds

# Frequency plot
# Assign your textstat_frequency results to an object
tstat <- textstat_frequency(cr_dfm_trimmed)
tstat
head(tstat[1:20, 1:2])

# Generate the plot -- top 20 words
ggplot(tstat[1:20, ], aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency")

# Word cloud
# Open a new plot window for better viewing
dev.new(width = 2000, height = 2000, unit = "px")

# Generate the word cloud
textplot_wordcloud(cr_dfm_trimmed, max_words = 100) # Top 100 words

## Move from single tokens to ngrams

# Go back to your corpus and convert it into tokens
# Build in cleaning steps, though note different structure and order
cr_toks <- tokens(cr_corpus,
                  remove_punct = TRUE,
                  remove_numbers = TRUE,
                  remove_symbols = TRUE)

# Removing stopwords
cr_toks <- tokens_remove(cr_toks, pattern = stopwords('en'))
cr_toks

# Stemming
cr_toks <- tokens_wordstem(cr_toks, language = quanteda_options("language_stemmer"))

# Generate n-grams of any length
# https://rdrr.io/cran/quanteda/man/tokens_ngrams.html

toks_ngram <- tokens_ngrams(cr_toks, n = 2)

# Look at the first few documents' tokens now
head(toks_ngram)

# Create a dfm
ngram_dfm <- dfm(toks_ngram)

textstat_frequency(ngram_dfm)

# Generate plots and word clouds using the same code as above

## Smarter ngram generation using SpacyR
# https://spacyr.quanteda.io/index.html
# https://spacyr.quanteda.io/reference/spacy_extract_nounphrases.html

## Other options: tokenize on the basis of sentences first, then create n-grams