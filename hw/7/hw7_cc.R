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
setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\hw\\7")
write_csv(as.data.frame(df.corp.seg), 'hw7_segmented_txt_presiding.csv')
head(df.corp.seg)


################################################################################
# 2: Merge Member Info
################################################################################

# Inspect Speaker Names
member.info$speaker[1:10]
member.info$firstname[1:10]
member.info$speaker[1:10]
member.info.repeat_ln <- subset(member.info, repeat_last_name == "x")
member.info.repeat_ln$speaker


# Get Last Name From Crec Corpus
df.corp.seg$lastname <- str_remove(str_extract(df.corp.seg$pattern, "\\.*[A-Z]+\\."), "\\.")

# Left Merge Speaker Data On Speaker Last Name





