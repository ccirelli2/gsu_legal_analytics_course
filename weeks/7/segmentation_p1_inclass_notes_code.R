################################################################################
# Week 6 - Note From In Class Video
# Topic - Segmentation - Three Different Strategies
# Overall Goal - Separate Text of Each Speaker Into a Separate Corpus
# Unit of Measure - One Day in Congress.
################################################################################

# Clearn Environment
rm(list=ls())

# Load the relevant libraries 
library(quanteda) # general text analytics library
library(readtext) # use this to read in text data
library(tidyverse) # loads the stringr package

# Set Working Directory
setwd("C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\weeks\\7\\Segmentation, Part II")

# Load Data
df.txt <- readtext("20_txt_all/*")
dim(df.txt)
head(df.txt)


################################################################################
# Approach 1:  Use StringR Command to Find Regex Match Location
################################################################################

# Define Result Objects
speaker_doc <- vector()
speaker_match <- vector()
speaker_locate <- vector()

# Iterate Over Each Document and Find Match
for(i in dim(df.txt)[1]){
  # Match Txt
  tmp_match <- str_match_all(string=df.txt[i, 2],
                             pattern=regex("\\n\\s*M[a-z]\\.\\s*[A-Z]*\\.",
                                           ignore_case=FALSE))[1] # return first match.
  # Locate th beginning and end of each of these matches using str_locate_all 
  tmp_locate <- str_locate_all(string=df.txt[i, 2],
                               pattern=regex("\\n\\s*M[a-z]\\.\\s*[A-Z]*\\.",
                                             ignore_case=FALSE))
  # Create a vector of valuaes identifying the document in which the speaker
  # appears so that we can extract the text later.
  tmp_doc <- rep(i, length(unlist(tmp_match)))
    
  # Append to result objects
  speaker_match <- append(speaker_match, unlist(tmp_match))
  speaker_locate <- append(speaker_locate, tmp_locate)
  speaker_doc <- append(speaker_doc, unlist(tmp_doc))
  }


# Convert list of lists into dataframe
speaker_locate <- as.data.frame(do.call(rbind, lapply(speaker_locate, as.data.frame)))
speaker_info <- as.data.frame(cbind(speaker_doc, speaker_match, speaker_locate))


################################################################################
# Step2: Extract Text based on position of the names
################################################################################

speaker_info$utterances <- NA
head(speaker_info)
speaker_info$speaker_doc


for(i in 1:dim(speaker_info)[1]){
  doc <- speaker_info$speaker_doc[i]
  next_doc <- speaker_info$speaker_doc[i+1]
  
  if(i==dim(speaker_info)[1]){
    utt_end <- -1
  } else {
    if(doc != next_doc){
      utt_end <- -1
    } else {
      utt_end <- speaker_info$start[i+1]
    }
  }
  
  
  # STart Position identified from the locate_all command above
  utt_start <- speaker_info$start[i]
  
  # subset string based on start and end
  speaker_info$utterances[i] <- str_trim(str_sub(string=df.txt[doc, 2],
                                                 start=utt_start,
                                                 end=utt_end),
                                         side='both')
}


# View Results
View(head(as_tibble(speaker_info)))  # tibble adds nice formating

# Merge in Name of Document & Date
txt_index <- cbind(speaker_doc = as.numeric(rownames(df.txt)),
                   data.frame(df.txt, row.names=NULL))
merge_doc <- txt_index[,1:2]

merge_doc$speaker_doc

# merge object with the document information with the speaker info df
speaker_info <- left_join(speaker_info, merge_doc, by="speaker_doc")
View(speaker_info)


# Need to create unique doc id.  Prerequisite for creating a corpus
speaker_info$unique_doc_id <- paste(speaker_info$doc_id, speaker_info$start, sep="_")

# Create Corpus
speaker_info_corp <- corpus(speaker_info,
                            docid_field = "unique_doc_id",
                            text_field="utterances",
                            meta="speaker_match")


################################################################################
# Approach 2: Use the String Split Function
################################################################################


#Result objects
split_txt <- vector()
speaker_doc <- vector()

# Iterate Documents and split each one
for(i in 1:dim(df.txt)[1]){
  split_tmp <- str_split(string=df.txt[i, 2],
                         pattern=regex("\\n\\s*M[a-z]\\.\\s*[A-Z]*\\.",
                                       ignore_case=FALSE))
  doc_tmp <- rep(i, length(unlist(split_tmp)))
  split_txt <- append(split_txt, str_trim(unlist(split_tmp), side="both"))
  speaker_doc <- append(speaker_doc, as.numeric(doc_tmp))
      }


# Check the length of these lists
length(split_txt)
length(speaker_doc)

# Now bind these to a dataframe
alt_speaker_info <- as.data.frame(cbind(split_txt, speaker_doc))
dim(alt_speaker_info)

# Note: When we split on the speaker the program did not retain the name
# of the speaker.  
# Need to get rid of junk text

alt_speaker_info <- alt_speaker_info %>%
  group_by(speaker_doc) %>%
  mutate(seqnum = 1: length(speaker_doc))

# Keep only where sequence number > 1, 1 = junk text
alt_speaker_info <- alt_speaker_info[alt_speaker_info$seqnum > 1,]

# Add speaker using the speaker match code from above
speaker_match <- vector()

for(i in 1:dim(df.txt)[1]){
  tmp_match <- str_match_all(string= df.txt[i, 2], pattern=regex("\\n\\s*M[a-z]\\.\\s*[A-Z]*\\.",
                                                              ignore_case=FALSE))
  speaker_match <- append(speaker_match, unlist(tmp_match))
  }


alt_speaker_info <- cbind(speaker=speaker_match, alt_speaker_info)


# Turn into a corpus
alt_speaker_info$speaker_doc <- as.numeric(alt_speaker_info$speaker_doc)
alt_speaker_info <- left_join(alt_speaker_info, merge_doc, by="speaker_doc")


################################################################################
# Use Corpus Segment Function
################################################################################

corp <- corpus(df.txt)
head(corp)

# Segment text based on regex
corp_seg <- corpus_segment(corp,
                           pattern="\\n\\s*M[a-z]\\.\\s*[A-Z]*\\.",
                           pattern_position=c("before"),
                           valuetype="regex",
                           extract_pattern=TRUE,
                           case_insensitive=FALSE)

df_corp_seg <- cbind(text=text(corp_seg),
                     docvars(corp_seg),
                     docid=docnames(corp_seg),
                     stringsAsFactors=FALSE)

# Save as csv file
write_csv(as.data.frame(df_corp_seg), 'df_corp_seg.csv')

# hw: regex to capture procedural text to exclude it from the speach of the
# senator.



#############################################################################
# SEGMENTATION PART II
# Focus on cleaning data & adding meta-data
# Only going to focus on the corpus segment function
#############################################################################

ext_pattern <- "(\\n\\s*(M[a-z]\\.\\s*([A-Z]*))\\.)|(\\n\\s*(M[a-z]\\.\\s*([A-Z]*))\\s*of\\s*([A-Za-z]*)\\.)"
check_ext_regex <- str_match_all(corp, ext_pattern)
head(check_ext_regex)
class(check_ext_regex)


presiding_pattern <- "(\\n\\s*The\\s*[A-Z]*\\.)|(\\n\\s*The\\s*[A-Z]*\\s*pro\\s*tempore\\.)|(\\n\\s*The\\s*[A-Z]*\\s*[A-Z]*\\.)|(\\n\\s*The\\s*[A-Z]*\\s*[A-Z]*\\s*\\(.*\\)\\.)"

check_presiding_regex <- str_match_all(corp, presiding_pattern)
head(check_presiding_regex) # It works! 









