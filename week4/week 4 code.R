# AUTHOR:     Charlotte Alexander
# COURSE:     MSA 8350/ LAW 7675
# PURPOSE:    Dictionary lookups and context exploration
# DATE:       January 28, 2021

# Resources for all packages -- enter relevant package name:
# help(quanteda)
# ??quanteda

# Resources for quanteda packages: 
# https://tutorials.quanteda.io/
# https://muellerstefan.net/files/quanteda-cheatsheet.pdf
# additional function- or operation-specific resources included in code below

# Install new packages
install.packages("text2vec")
install.packages("sentimentr")
install.packages("tidytext")
install.packages("textdata")

# Load the relevant libraries
library(readtext)
library(quanteda)
library(text2vec)
library(sentimentr)
library(tidytext)
library(textdata)

# This code uses the same set of 10_txt documents used in week 3.
# If you saved your workspace from week 3, load that in now.

# Alternatively, set your working directory to the location of the 
# 10_txt folder on your machine.
setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\data")

# Read in your dataset; create corpus, tokens, and dfm objects
# Note that the functions below take different objects as inputs: tokens, corpus, dfm
cr_txt <- readtext("*.txt")
cr_corpus <- corpus(cr_txt)
cr_toks <- tokens(cr_corpus)
cr_dfm <- dfm(cr_corpus)
summary(cr_dfm)

########################### SYNONYMS VIA GLOVE WORD EMBEDDINGS ###########################
# https://cran.r-project.org/web/packages/text2vec/vignettes/glove.html
# https://machinelearningmastery.com/what-are-word-embeddings/

## Create function for calculating cosine similarity
cossim = function(x,y)
{
  numerator = sqrt(sum(x*y))
  denominator = sqrt(sum(x^2)) * sqrt(sum(y^2))
  return(list(cosine_similarity = numerator/denominator))
}
 
## Create function for finding list of the N most similar terms
most_similar = function(x,y,method="cosine",N=10)
{
  most_sim=head(sort(
    sim2(x, x[y, , drop=FALSE], 
         method=method)[,1], decreasing=TRUE), N)
  return(list(top_words=most_sim))
}

# Create a feature-co-occurrence matrix (fcm) using the tokens object
fcm <- fcm(cr_toks, 
           context = "window", 
           count = "weighted", 
           weights = 1 / (1:5), 
           tri = TRUE)

help(fcm)

# Set up and fit the GloVe model
glove <- GlobalVectors$new(rank = 50, x_max = 10)

# Apply model to fcm
fcm_tokens <- glove$fit_transform(fcm, n_iter = 20)
fcm_tokens

# Create list of N most similar words
most_similar(fcm_tokens, "PROCEEDINGS")


########################### DICTIONARY LOOKUPS ###########################
# https://tutorials.quanteda.io/basic-operations/dfm/dfm_lookup/

# Using the dfm you created above, isolate your list of keywords 
dfm_keywords <- dfm_select(cr_dfm, pattern = c("worker","taxpayer","consumer"), 
                           selection = "keep")

View(dfm_keywords)

# Write out to a csv file if you like
dfm_keywords <- convert(dfm_keywords, to = "data.frame")
write.table(dfm_keywords, "dfm_keywords.csv")

# Alternative: read in list of keywords from txt document
# Use dfm_select on the basis of that object 
keywords <- readLines("dfm_keywords.csv")

dfm_keywords <- dfm_select(cr_dfm, pattern = keywords, 
                           selection = "keep")

# Another alternative: create a dictionary object to group multiple words under a single label
# Then use dfm_lookup
# https://www.rdocumentation.org/packages/quanteda/versions/2.1.2/topics/dfm_lookup
# *tax - wildcard - R will pull out any match of tax

dict <- dictionary(list(worker = c("worker", "union", "employee"),
                        consumer = c("consumer", "prices", "competition"),
                        taxglob = "tax*"))

#*** Note that the frequencies roll up into the worker key, not per token frequency.
# Pass the dictionary to dfm_lookup to build your dfm
dfm_keywords <- dfm_lookup(cr_dfm, dict, valuetype = "glob",
                           case_insensitive = FALSE) # Specify glob because one dictionary item is in glob format
dfm_keywords

View(dfm_keywords) # Note that this sums all dictionary word counts

# Option: add case_insensitive = TRUE or FALSE within parentheses




# Generate Bi-grams

cr_toks2 <- tokens_replace(cr_toks, phrase(c("minimum wage")), 
                       phrase(c("minimum_wage")))


# Alternative: tokens_compound, or use regular expressions
# https://tutorials.quanteda.io/advanced-operations/compound-mutiword-expressions/

# Recreate your dfm from your toks object
cr_dfm2 <- dfm(cr_toks2)
cr_dfm2

# Add those bigrams/ngrams to your dfm_select or dfm_lookup workflow
dfm_keywords2 <- dfm_select(cr_dfm2, pattern = c("minimum_wage","economic","worker","taxpayer","consumer"), 
                           selection = "keep")

View(dfm_keywords2)

# Note that you can add a tokens_replace function upstream in the GloVe word embeddings
# workflow if you want to generate synonyms for a multi-word phrase



########################### KEYWORDS IN CONTEXT (KWIC) ###########################
# https://quanteda.io/reference/kwic.html

# Note: kwic's input can be a character, corpus, or tokens object

# Key to kwic arguments:
# pattern: keyword or phrase
# window: number of words before and after
# valuetype: "glob" wildcard expressions; "regex" for regular expressions; "fixed" for exact matching 


# Exact lookup; window = number of words before and after
economic <- kwic(cr_corpus, pattern = "economic",
                 window = 10, valuetype = "fixed")

# Turn your kwic object into a dataframe (key words in context)
economic <- as.data.frame(economic)

# Look at it
View(economic)


# Wildcard lookup
econ <- kwic(cr_corpus, pattern = "econ*", 
                   window = 10, valuetype = "glob")


# Turn your kwic object into a dataframe
econ <- as.data.frame(econ)

# Look at it
View(econ)

# Phrase look-up
minimum_wage <- kwic(cr_corpus, pattern = phrase("minimum wage"), 
                    window = 10)      

minimum_wage <- as.data.frame(kwic(cr_corpus, pattern = phrase("minimum wage"), 
                     window = 10))      


# Look at it
View(minimum_wage)

# Challenge question: How else could you have generated a kwic window for "minimum wage?"

# What can you do with your kwic results?

# Combine pre- and post- text into a single column in a new dataframe 
minimum_wage$pre_post <- paste(minimum_wage$pre, minimum_wage$post)

View(minimum_wage)

# Turn it into a corpus; tell the corpus command where the text is
# Note: each row is a kwic extract, not a Cong. Rec. document
kwic_corpus <- corpus(minimum_wage, text = "pre_post")
View(kwic_corpus)


# Tokenize
kwic_toks <- tokens(kwic_corpus)
View(kwic_toks)



########################### READABILITY ###########################
# https://quanteda.io/reference/textstat_readability.html

# Check out the list of readability measures in the link above
# Investigate how to interpret. Grade level? Another scale? Is a higher number more or less readable?

# Popular: Flesch-Kincaid, Dale-Chall, Gunning's FOG, 
# https://en.wikipedia.org/wiki/Readability

# Think about the size of your kwic window. Is it large enough?
# Measures are all diff. 

kwic_read <- textstat_readability(kwic_corpus, measure = "Flesch.Kincaid")
kwic_read

# More than one measure
kwic_read <- textstat_readability(kwic_corpus, measure = c("Flesch.Kincaid", "Dale.Chall"))
kwic_read

# Add the document identifier and text columns back in
# Cbind does not do an inner join. Your primary key in your two dataframes need to match.
kwic_read <- cbind(minimum_wage$docname, minimum_wage$pre_post, kwic_read)
kwic_read

# Clean up (Delete column)
kwic_read$document <- NULL

View(kwic_read)

########################### LEXICAL DIVERSITY ###########################
# https://tutorials.quanteda.io/statistical-analysis/lexdiv/
# How many unique tokens are used in that document divided by total tokens
# Not cleaning because it will drop out lexical diversity.

# Think about the size of your kwic window. Is it large enough?

# Create a dfm from the kwic_corpus object
kwic_dfm <- dfm(kwic_corpus) 

# Calculate lexical diversity: number of unique tokens per document/number of tokens in document
kwic_lexdiv <- textstat_lexdiv(kwic_dfm)

kwic_lexdiv

# Add the document identifier and text columns back in
kwic_lexdiv <- cbind(minimum_wage$docname, minimum_wage$pre_post, kwic_lexdiv)

# Clean up
kwic_lexdiv$document <- NULL

View(kwic_lexdiv)


########################### SENTIMENT ANALYSIS FIVE WAYS ###########################
## OPTION 1: QUANTEDA
# https://quanteda.io/reference/data_dictionary_LSD2015.html
# https://tutorials.quanteda.io/advanced-operations/targeted-dictionary-analysis/

# Use quanteda's built-in sentiment analysis dictionary: http://www.lexicoder.com/
data_dictionary_LSD2015

# Compound neg_negative and neg_positive tokens before creating a dfm object
# Function knows something is a bigram.
kwic_toks_compound <- tokens_compound(kwic_toks, data_dictionary_LSD2015)

# Using dfm_lookup function to compare to a dictionary of sentiment.
kwic_sentiment <- dfm_lookup(dfm(kwic_toks_compound), data_dictionary_LSD2015)

View(kwic_sentiment)

# Convert kwic_sentiment to a dataframe
kwic_sentiment <- convert(kwic_sentiment, to = "data.frame")


# Add the document identifier column back in
kwic_sentiment <- cbind(minimum_wage$docname, kwic_sentiment)

View(kwic_sentiment)

# Write to a csv if you wish

## OPTION 2: SENTIMENTR
# https://github.com/trinker/sentimentr
# https://towardsdatascience.com/doing-your-first-sentiment-analysis-in-r-with-sentimentr-167855445132
# Uses Jockers(2017) dictionary: https://github.com/mjockers/syuzhet --> incorporates Syuzhet, Bing, AFINN, and NRC lexicons



# Input is a data frame with text column identified
kwic_sentimentr <- sentiment_by(minimum_wage$pre_post)

View(kwic_sentimentr)

# Add the document identifier column back in
kwic_sentimentr <- cbind(minimum_wage$docname, kwic_sentimentr)

## OPTION 3: TIDYTEXT DICTIONARIES
# https://www.tidytextmining.com/sentiment.html#the-sentiments-dataset

# Three dictionaries: AFINN, Bing, nrc
# These do not take multi-word phrases into account, e.g. "not good"
get_sentiments("bing") # pos/neg
get_sentiments("nrc") # pos/neg, anger, fear, negative, sadness
get_sentiments("afinn") # numeric scale -5 to 5

# Create objects for each
bing_lexicon <- get_sentiments("bing")
nrc_lexicon <- get_sentiments("nrc")
afinn_lexicon <- get_sentiments("afinn")

# Convert to dictionary objects
bing_lexicon <- as.dictionary(bing_lexicon)
nrc_lexicon <- as.dictionary(nrc_lexicon)

# Convert AFINN value column to pos/neg sentiment column
afinn_lexicon$sentiment <- ifelse(afinn_lexicon$value >0, "positive", "negative")
afinn_lexicon$value <- NULL

# Then convert to dictionary
afinn_lexicon <- as.dictionary(afinn_lexicon)

# Use dfm_lookup on kwic_dfm created above
dfm_bing <- dfm_lookup(kwic_dfm, dictionary =  bing_lexicon)
dfm_nrc <- dfm_lookup(kwic_dfm, dictionary =  nrc_lexicon)
dfm_afinn <- dfm_lookup(kwic_dfm, dictionary =  afinn_lexicon)

# Convert dfm's to dataframes 
df_bing <- convert(dfm_bing, to = "data.frame")
df_nrc <- convert(dfm_nrc, to = "data.frame")
df_afinn <- convert(dfm_afinn, to = "data.frame")

# Change colnames in each for easy identification
colnames(df_bing)[colnames(df_bing)=="negative"] <- "bing_neg"
colnames(df_bing)[colnames(df_bing)=="positive"] <- "bing_pos"
colnames(df_nrc)[colnames(df_nrc)=="negative"] <- "nrc_neg"
colnames(df_nrc)[colnames(df_nrc)=="positive"] <- "nrc_pos"
colnames(df_afinn)[colnames(df_afinn)=="negative"] <- "afinn_neg"
colnames(df_afinn)[colnames(df_afinn)=="positive"] <- "afinn_pos"

# Combine all, plus original docnames 
kwic_sentiment_tidy <- cbind(minimum_wage$docname, df_bing, df_nrc$nrc_neg, df_nrc$nrc_pos, df_afinn)

View(kwic_sentiment_tidy)

# Drop doc_id columns [twice]
kwic_sentiment_tidy$doc_id <- NULL

## OPTIONAL: Bind all sentiment approaches together to compare, plus add text
all_sentiment <- cbind(kwic_sentiment_tidy, 
                       kwic_sentiment$negative, 
                       kwic_sentiment$positive, 
                       kwic_sentiment$neg_positive, 
                       kwic_sentiment$neg_negative,
                       kwic_sentimentr$ave_sentiment)

View(all_sentiment)

# Add text column
all_sentiment <- cbind(minimum_wage$pre_post, all_sentiment)

# Review in R or export to csv to validate

# Do you want to combine some columns, e.g. neg-negative + positive? or positive - negative?
# Example: all_sentiment$bing_pos_neg <- all_sentiment$bing_pos - all_sentiment$bing_neg

# Which approach to sentiment is best?

# Think about the size of your kwic window. Is it large enough?
