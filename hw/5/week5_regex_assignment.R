#### REGULAR EXPRESSIONS PROBLEM SET (INDIVIDUAL ASSIGNMENT) ####
#### DUE: February 9, 2021

# Using the "2018_2020_workspace2.RData", please answer the following questions. 

#### PRELIMINARIES ####
library(tidyverse)

#### QUESTION 1 ####

# Please use the stringr and regex syntax to view all instances of "wage," 
# "wages," "Wage," and "Wages" in the second document.

# Note that your output will appear in the "Viewer" tab. If there is too much 
# text, you can view the results in your web browser by clicking on the "Viewer" 
# button labeled "Show in new window"

# Which member of Congress utters the word "wage" (or a variant thereof) in this document? 

#### QUESTION 2 ####

# Extract all instances of "wage" (and its variants) that occur within 50 
# characters of the word "living" in the first 50 documents. Save these matches 
# to an object named "living_wage"

# How many matches did you find? 
# Which of the first 10 documents has the highest number of matches? 
# What were the phrases captured by the regex? 

# Now run the code again, expanding the window to 100, 200, and 500 characters. 
# Does the regex find any additional phrases? If so, what are they? 

#### PROBLEM 3 ####

# Use the kwic command to extract a 100-token window around the regex you wrote 
# for Problem 2. Save this kwic object as "lw_window" and convert it into a data
# frame named "df_lw_window". 

# What are the dimensions of this data frame? 

#### PROBLEM 4 #### 

# As you may have noticed, many words are split in half by a hyphenation followed 
# by at least one space ("- "). This is a function of how the PDF documents were 
# originally formatted and the difficulty of converting these documents to plain 
# text. 

# Write a regex to replace all occurrences of this break in the first 10 documents
# in the cr_txt object and create a new data frame named "cr_txt_cleaned."

# Then check the text to make sure that you have performed this replacement 
# properly. 

#### PROBLEM 5 ####

# Next week, we will move on to segmenting (i.e., splitting up) the text by 
# speaker. We will be leveraging the Congressional Record's relatively uniform 
# structure to split the text at the beginning of a speaker's statement. These 
# transitions (1) start with a new line, (2) include the word "Mr." or "Ms.", and
# list the name of the speaker in ALL CAPS. 

# Write a regex to match and extract all instances of a new speaker in the first 
# 10 documents. Save these matches in an object named "speakers" and convert
# this list object into a data frame. 
