##################################################################################
# Legal Analytics II: Segmentation (Part 2)
#  Authors: Susan Smelcer
#  Date: February 18, 2021
#  Course: GSU MSA 8350/ LAW 7675
##################################################################################

# Load the relevant libraries 
library(quanteda) # general text analytics library
library(readtext) # use this to read in text data
library(tidyverse) # loads the stringr package

# Set your working directory to the folder on your computer where your data 
# are saved. This is Dr. Smelcer's working directory; you'll need to set your own

setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\weeks\\7\\Segmentation, Part II")

# Ordinarily, we would load the "2018_2020_workspace2.RData" file into my
# workspace. For the purposes of this video, I am only going to load the first 
# 20 documents from the Congressional Record. 

txt <- readtext("20_txt/*")

# Goal: Segment the text in a separate corpus for each speaker.
# Last week, I presented text that would split the text at the speaker. But this 
# simple regex was both over- and under-inclusive. The regex was over-inclusive
# because it included statements by the presiding officer of the Senate and the 
# speaker (or speaker pro tempore) of the House. The regex was also under-
# inclusive because it excluded speakers that were identified by both their name
# and their state. 

# This week, we will start with the corpus segment function and build on our 
# baseline regex to capture both the presiding officer comments and variations on
# the speaker's name. 

#### EXTENDED SEGMENTATION ####

# You will use a corpus object to do this 
corp <- corpus(txt)
summary(corp)


# Step 1: Write an additional regex to capture extensions of the speaker's name.

ext_pattern <- "(\\n\\s*(M[a-z]\\.\\s*([A-Z]*))\\.)|(\\n\\s*(M[a-z]\\.\\s*([A-Z]*))\\s*of\\s*([A-Za-z]*)\\.)"

# The first pattern is the regex from last week. The second pattern captures the 
# name of the speaker AND the state (e.g., "Ms. SEWELL of Alabama.")

# Let's check this against our corpus. 

check_ext_regex <- str_match_all(corp, ext_pattern)
check_ext_regex # It works! Yay. 

# Step 2: Further extend our regex to capture comments made by the presiding 
# officer of each chamber:

# In the SENATE, the presiding officer is referred to as:
# - "The VICE PRESIDENT." 
# - "The PRESIDENT pro tempore." 
# - "The PRESIDING OFFICER (Mr. NAME)."
# - "The PRESIDING OFFICER." 

# In the HOUSE, the presiding officer is referred to as:
# - "The SPEAKER."
# - "The SPEAKER pro tempore." 

presiding_pattern <- "(\\n\\s*The\\s*[A-Z]*\\.)|(\\n\\s*The\\s*[A-Z]*\\s*pro\\s*tempore\\.)|(\\n\\s*The\\s*[A-Z]*\\s*[A-Z]*\\.)|(\\n\\s*The\\s*[A-Z]*\\s*[A-Z]*\\s*\\(.*\\)\\.)"

check_presiding_regex <- str_match_all(corp, presiding_pattern)
check_presiding_regex # It works! 

# STEP 3: Our lives will be easier if we assign the chamber now. We will add 
# a pattern to capture the chamber from the text. 

chamber_pattern <- "(\\nSenate\\n)|(\\nIN\\s*THE\\s*SENATE\\n)|(\\nHouse\\s*of\\s*Representatives\\n)|(\\nIN\\s*THE\\s*HOUSE\\s*OF\\s*REPRESENTATIVES\\n)"
check_chamber_regex <- str_match_all(corp, chamber_pattern)
check_chamber_regex # It works!

# Now, we can put all of these regular expressions together in a single 
# statement 

full_pattern <- "(\\n\\s*(M[a-z]\\.\\s*([A-Z]*))\\.)|(\\n\\s*(M[a-z]\\.\\s*([A-Z]*))\\s*of\\s*([A-Za-z]*)\\.)|(\\n\\s*The\\s*[A-Z]*\\.)|(\\n\\s*The\\s*[A-Z]*\\s*pro\\s*tempore\\.)|(\\n\\s*The\\s*[A-Z]*\\s*[A-Z]*\\.)|(\\n\\s*The\\s*[A-Z]*\\s*[A-Z]*\\s*\\(.*\\)\\.)|(\\nSenate\\n)|(\\nIN\\s*THE\\s*SENATE\\n)|(\\nHouse\\s*of\\s*Representatives\\n)|(\\nIN\\s*THE\\s*HOUSE\\s*OF\\s*REPRESENTATIVES\\n)"

corp_seg <- corpus_segment(corp, 
                           pattern = full_pattern, 
                           pattern_position = c("before"), 
                           valuetype = "regex", 
                           extract_pattern = TRUE,
                           case_insensitive = FALSE)
corp_seg
# Once we've segmented the corpus, we can bind the text chunks, the docid info,
# and the pattern match. 
df_corp_seg <- cbind(text = texts(corp_seg), 
                     docvars(corp_seg), 
                     docid = docnames(corp_seg), 
                     stringsAsFactors = FALSE)

head(as_tibble(df_corp_seg), n = 10) # check to make sure we've done it correctly. 
df_corp_seg$pattern


# That looks good. But now we have too many speakers We don't care about the 
# statements made by the presiding officer of each chamber, and we want to drop 
# these. 

# We are going to flag the parts of the corpus associated with the presiding 
# officer using the data frame we just created, str_detect, and the presiding 
# pattern we created (above).

df_corp_seg$drop_presiding <- ifelse(str_detect(df_corp_seg$pattern, presiding_pattern),1,0)

head(as_tibble(df_corp_seg)) # Cool. That worked! 

# Now, we can drop all of these observations by subsetting the data
df_speaker <- df_corp_seg[df_corp_seg$drop_presiding == 0,1:3]
head(as_tibble(df_speaker))

# Now we need to assign the chamber to each text chunk by manipulating the
# Senate and House of Representative matches. First, we are going to create a 
# new column in the data frame to capture the chamber of the speaker. 

df_speaker$chamber <- ifelse(str_detect(df_speaker$pattern, "(\\nSenate\\n)|(\\nIN\\s*THE\\s*SENATE\\n)"), "Senate", ifelse(str_detect(df_speaker$pattern, "(\\nHouse\\s*of\\s*Representatives\\n)|(\\nIN\\s*THE\\s*HOUSE\\s*OF\\s*REPRESENTATIVES\\n)"), "House", NA))
summary(df_speaker$chamber)

# Fill in the "NA" columns with the chamber from the previous row

for(i in 1:dim(df_speaker)[1]){
  prev_chamber = df_speaker$chamber[i-1]
  if(is.na(df_speaker$chamber[i])){
    df_speaker$chamber[i] = prev_chamber
  }
}

# Check this! 
head(as_tibble(df_speaker), n = 10)

# Now, finally, remove the rows that matched the chamber pattern, just as we 
# removed the presiding officer rows.

df_speaker$drop_chamber <- ifelse(str_detect(df_speaker$pattern, chamber_pattern),1,0)
df_chamber <- df_speaker[df_speaker$drop_chamber == 0,1:4]
head(as_tibble(df_chamber), n = 10)


# This leaves us with a corpus of 2505 speaker statements and includes (1) the 
# text of each speaker's statement, (2) the name of the speaker, (3) 
# the name of the document from which the speaker's statement came, and (4)
# the chamber.

#### CODING AND MERGING IN METADATA ###

# This is great and everything, but we really need to be able to merge the 
# speakers' statements with metadata about the speakers themselves (i.e., the 
# speaker's party, state, chamber, etc.) 

# We are going to use the pattern (i.e., the name of the speaker) to match up 
# the speaker with their metadata. To do this, we need to isolate the speaker 
# (and the state, if that's applicable) to join with the speaker list discussed 
# by Prof. Alexander. 

df_chamber$speaker <- str_match(df_chamber$pattern, "\\n\\s*M[a-z]\\.\\s*([A-Z]*)(\\.|\\s*of\\s*[A-Za-z]*\\.)")[,2]

df_chamber$state <- str_match(df_chamber$pattern, "\\n\\s*M[a-z]\\.\\s*[A-Z]*\\s*of\\s*([A-Za-z]*)\\.")[,2]
head(as_tibble(df_chamber))

# Now we need to match these states with their postal code abbreviation, which is how they are stored in the speaker list. 

states <- read_csv("states.csv")
df_states <- left_join(df_chamber, states, by = "state")
head(as_tibble(df_states), n = 50)

# Okay, last thing. Let's extract the date from the docid (CR file name). 

df_states$crDate <- as.Date(str_match(df_states$docid, "[0-9]{4}\\-[0-9]{2}\\-[0-9]{2}"))

# The date tells us what Congress we're in, so we can create a a variable to 
# capture this. This will also help us merge in the appropriate speaker data. 

df_states$congress <- ifelse(df_states$crDate >= "2017-01-03" & df_states$crDate <= "2019-01-03", 115, 116)
head(as_tibble(df_states), n = 50)

# Now we want to merge in metadata about the speaker themselves. We will use the 
# speaker map to merge in party data. 

# First, we need to import the speaker data prepared by Prof. Alexander. I 
# changed some of the names of the columns to conform to the data frame I created. 
# In particular, I changed "lastname" to "speaker" and "state_abbrev" to "abbrev."

memberList <- read_csv("member names/member list 2017-2020.csv")

# We have an issue with the name of the member: it must be in all caps. 

memberList$speaker <- toupper(memberList$speaker)

df <- left_join(df_states, memberList, by = c("speaker","congress","chamber"))
head(as_tibble(df), n = 20)

# You can save this corpus and metadata as a CSV file to your working directory 
# using the following command: 
write_csv(df, "2021-02-20_df-speaker.csv")

# Remember to save your workspace image, which saves ALL of the objects
# in your workspace. 
save.image("week_7_segmentation")
