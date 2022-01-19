# GSU LEGAL ANALYTICS : HW3

############################################################################
# Load Libraries
############################################################################
library(quanteda)
library(ggplot2)


21############################################################################
# Set Directories
############################################################################
setwd('C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\hw\\hw3')

############################################################################
# Load Data
############################################################################
load('2018_2020_workspace.RData')


############################################################################
# QUESTIONS
############################################################################


# 1) How many documents are in this corpus
cr_dfm_clean
summary(cr_dfm_clean)
head(cr_dfm_clean)
'Answer : 636 Documents
'

# 2) What are the top 10 tokens and their frequency?
topfeatures(cr_dfm_clean)
head(textstat_frequency(cr_dfm_clean), n=10)
'Answer :
             feature frequency
          1       mr    517849
          2        s    294143
          3      act    245887
          4  section    226094
          5   states    203579
          6    shall    199942
          7   united    189683
          8    house    183585
          9        b    180166
          10    bill    157303
'

# 3) From your review of the frequency table, what are the additional
#    stopwords that you would liek to drop from the 2018 to 2020 file?

# Load Stopwords
stopwords.en <- stopwords('en')
stopwords.en = stopwords.en[-c(which(stopwords.en=="i"))]

n_toks = 100
tokens <- textstat_frequency(cr_dfm_clean)[1:n_toks, 1]

tokens
'mr, s, b, h.r, ms, re-, e, c, f, con-, in-, ii, sep, d, d-, com-, pro-, fm,
use, us, 
'

# 4) Generate a wordcloud and textstat_frequency plot to show top 50 words

# Frequency plot
# Assign your textstat_frequency results to an object
tstat <- textstat_frequency(cr_dfm_clean)

# Freq Plot
ggplot(tstat[1:50, ], aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency")

# Generate the word cloud
dev.new(width = 1000, height = 1000, unit = "px")
textplot_wordcloud(cr_dfm_clean, max_words = 50) 




