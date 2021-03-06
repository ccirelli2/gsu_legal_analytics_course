################################################################################
# HW7
# Chris Cirelli
# 02-28-2021
################################################################################
'

Using the 2018-2020 (or optionally add 2017) Congressional Record documents,
turn in an R script that includes code and explanatory #comments for the
following steps:
1	Segment the text by speaker;
2	Merge in your team's covariates of interest (e.g. party, birth date, etc.);
	Troubleshoot failed merges by harmonizing member names;
3	[OPTIONAL: combine your later CR documents with prior years from Stanford;
  harmonize speaker names and unique IDs across text sources and merge in
  speaker covariates; see week 7 text comparison code for details];
4	Choose at least one text comparison method from the week 7 code and generate
  a comparison between subsets of your text, e.g. speeches by Republicans versus
  by Democrats and Independents;
5	Write a few sentences at the end about what this comparison shows you (include
  this as # comments at the end of your R script).
'


################################################################################
# Load Libraries
################################################################################
rm(list=ls())
library(quanteda) 
library(readtext) 
library(tidyverse) 
library(ggplot2)

################################################################################
# Load Data
################################################################################
setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\data\\crec\\2018_2020_txt_1")
crec.txt <- readtext("*.txt")
member.info <- readtext("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\data\\member_info.csv")


################################################################################
# 1: Segment Text By Speaker
################################################################################

# Create Corpus
corp <- corpus(crec.txt)
summary(corp)
head(corp)

# Define Patters
regex.speaker <- "\\n\\s*M[a-z]\\.\\s*[A-Z]*\\."
regex.ext <- "(\\n\\s*(M[a-z]\\.\\s*([A-Z]*))\\.)|(\\n\\s*(M[a-z]\\.\\s*([A-Z]*))\\s*of\\s*([A-Za-z]*)\\.)"
regex.presiding <- "(\\n\\s*The\\s*[A-Z]*\\.)|(\\n\\s*The\\s*[A-Z]*\\s*pro\\s*tempore\\.)|(\\n\\s*The\\s*[A-Z]*\\s*[A-Z]*\\.)|(\\n\\s*The\\s*[A-Z]*\\s*[A-Z]*\\s*\\(.*\\)\\.)"

# Segment Text
corp.seg <- corpus_segment(corp,
                           pattern=regex.speaker,
                           valuetype='regex',
                           extract_pattern=TRUE,
                           case_insensitive=FALSE)

# Create Data Frame
df.corp.seg <- cbind(text=texts(corp.seg),
                     docvars(corp.seg),
                     docid=docnames(corp.seg),
                     stringsAsFactors=FALSE)

# Write to csv
#setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\hw\\7")
#write_csv(as.data.frame(df.corp.seg), 'hw7_segmented_txt_presiding.csv')
#head(df.corp.seg)

################################################################################
# 2: Merge Member Info
################################################################################

# Inspect Speaker Names
head(member.info)
member.info$speaker[1:10]
member.info$firstname[1:10]
member.info$speaker[1:10]
member.info.repeat_ln <- subset(member.info, repeat_last_name == "x")
member.info.repeat_ln$speaker

# Convert Member Info Names to Lowercase
member.info$speaker <- tolower(member.info$speaker)

# Get Last Name From Crec Corpus
df.corp.seg$lastname <- tolower(str_remove(str_extract(df.corp.seg$pattern, "\\.*[A-Z]+\\."), "\\."))

# Test Equality
df.corp.seg$lastname[1]
member.info$speaker[360]
df.corp.seg$lastname[1] == member.info$speaker[360]

# Left Join Speaker Data On Speaker Last Name
df.corp.seg.mem.info.all <- merge(x=df.corp.seg, y=member.info, by.x="lastname", by.y="speaker", all.x=TRUE)
df.corp.seg.mem.info.lim <- merge(x=df.corp.seg, y=member.info, by.x="lastname", by.y="speaker")
head(df.corp.seg.mem.info.lim)

# Write to CSV
setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\hw\\7")
write_csv(as.data.frame(df.corp.seg.mem.info.lim), 'hw7_segmented_txt_speaker_plus_info.csv')



################################################################################
# 4: Text Comparison Method - 
################################################################################

# Create Corpus
df.txt.party <- df.corp.seg.mem.info.lim[c("text.x", "party")]
corp.txt.party <- corpus(df.txt.party, text="text.x")

# Create Dfm & Group By Party
dfm.txt.party <- dfm(corp.txt.party,
                     groups='party',
                     remove = stopwords("en"),
                     remove_punct=TRUE,
                     remove_numbers=TRUE,
                     remove_symbols=TRUE)

# Write to working directory
View(dfm.txt.party)
setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\hw\\7")
write_csv(as.data.frame(dfm.txt.party), 'hw7_segmented_dfm_txt_by_party.csv')

# Get Top 20 Tokens 
tstat_party <- textstat_frequency(dfm.txt.party, n = 20, groups = "party")

# Plot
ggplot(data = tstat_party, aes(x = factor(nrow(tstat_party):1), y = frequency)) +
  geom_point() +
  facet_wrap(~ group, scales = "free") +
  coord_flip() +
  scale_x_discrete(breaks = nrow(tstat_party):1,
                   labels = tstat_party$feature) +
  labs(x = NULL, y = "Relative Frequency by Party")

# Word Cloud
dev.new(width = 1000, height = 1000, unit = "px")
textplot_wordcloud(dfm.txt.party, comparison = TRUE)

# Text Similarity
tstat_cosine <- textstat_simil(dfm.txt.party, method = "cosine", margin = "documents")
tstat_cosine_df <- as.data.frame(tstat_cosine)
View(tstat_cosine_df)
'result = 0.678'




################################################################################
# 5. Comments on Text Similarity
################################################################################
'
 Top 20 tokens & Word Cloud Comparis:
 - A number of similar tokens are found in the top 20 tokens utilized by both
   republicans and demographs.  These include senate, president, states,
   health.
 - That said, many more do not.  Examples include district, care, new, secretary,
   united, trump.
 - Simply based on the vector of the words used in the dfm the resulting cosine
   similarity was 0.678, which indicates that they are fairly similar text.
'



