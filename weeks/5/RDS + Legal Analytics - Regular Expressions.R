# The content in this notebook was developed by Jeremy Walker.
# All sample code and notes are provided under a Creative Commons
# ShareAlike license.

# Official Copyright Rules / Restrictions / Privileges
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
# https://creativecommons.org/licenses/by-sa/4.0/


##########################
##### Part 1 - Setup #####

# Import the stringr package
install.packages("tidyverse")
library(stringr)

# Arbitrary example placeholder texts.
texts <- c(
  "The State intends to seek the death Penalty against defendant, Dr. Who, and hereby gives written notice.",
  
  "8/12/1990 - The state of Florida intends to seek the Death Penalty against defendant and hereby gives written notice.",
  
  "The State does not intend to seek the death penalty against defendant, Obi Wan Kenobi.",
  
  "The state intend to seek the death penalty against defendant, Tyrion Lannister, and hereby gives written notice on 10/11/2011.",
  
  "4/1/99 - The State of Alaska intends to seek the Death penalty for the First Degree Murder(s) charged in this case."
  
)

# Preview and inspect the text before going further.
texts
texts[1]
texts[2]


############################################
##### Part 2 - Basic stringr functions #####

# str_view and str_view_all are the single most helpful functions
# when starting off.  These allow you to readily see how the 
# "pattern" you define matches with the texts you are working with.
# It also shows the full strings from the texts, allowing you to 
# quickly see the context around identified patterns.


# str_view will only highlight the first valid instance of your 
# pattern within a string.  The outputs for these commands should 
# appear in the "Viewer" pane in RStudio.

str_view(
  string = texts,
  pattern = "the"
)

# str_view_all will highlight all valid instances within a string.

str_view_all(
  string = texts,
  pattern = "the"
)

# Example using whitespace
str_view_all(
  string = texts,
  pattern = " "
)


##               ##
## PRACTICE TIME ##
##               ##

# Edit and run the code below in such a way that "Dr. Who" is
# highlighted in the appropriate text.

str_view_all(
  string = texts,
  pattern = "Dr. Who"
)

# Edit and run the code below in such a way that the phrase
# "intend to" is highlighted in the appropriate text.
str_view_all(
  string = texts,
  pattern = "intend to"
)




##################################################################
##### Part 3 - Simple pattern matching with explicit strings #####

# Using the str_view_all() function, now we can practice creating
# regular expression "patterns".

# Search for phrase "death penalty" in the "texts" object.
# Note: regular expressions are case-sensitive by default, so not 
# all instances of "death penalty" are highlighted depending on how 
# the letters are capitalized.
str_view_all(
  string = texts,
  pattern = "death penalty"
)

# Cheat sheet: see "ALTERNATES" and "GROUPS" on page 2
# (1) Using the | symbol in this context is equivalent to making a boolean OR statement.
# (2) Using the (), just like a math formula, will group components of a regular expression together.
# As you will start to notice, you can mix and combine aspects of regular expression patterns
# in a variety of different ways.


str_view_all(
  string = texts,
  pattern = "(death penalty)|(Death Penalty)"
)


str_view_all(
  string = texts,
  pattern = "(death|Death) (penalty|Penalty)"
)


str_view_all(
  string = texts,
  pattern = "(d|D)eath (p|P)enalty"
)


# While using groupings and alternates is often necessary, in this 
# case, there is an easier approach.  Wrapping the entire "pattern" 
# inside of a regex(...) function, we can explicitly ask that 
# case-sensitivity be ignored.

# Original "death penalty" pattern, with the regex() function added
str_view_all(
  string = texts,
  pattern = regex( "death penalty" )
)

# Same as above, but with ignore_case parameter passed to regex()
str_view_all(
  string = texts,
  pattern = regex( "death penalty" , ignore_case = TRUE)
)



##               ##
## PRACTICE TIME ##
##               ##

# Edit and run the code below in such a way that "the state" is
# highlighted in each of the states, regardless of CaPiTaLiZaTiOn.

# You will need to uncomment the next few lines of code.

str_view_all(
   string = texts,
   pattern = regex( "the state" , ignore_case = TRUE)
   )





##############################################################################
##### Part 4 - Pattern matching using special characters and quantifiers #####

# Using special characters as part of regular expressions is fundamental
# to creating generalized and robust patterns that go beyond simple 
# character-for-character string matching and searching.  The examples below
# demonstrate the use of some special characters such as "." "\w" "\s" and "\d". 
# Additionally, quantifiers ("+" "*" and "{}") are shown in conjunction with these
# special characters as methods for capturing patterns containing repetitive information.

# Cheat sheet: See "MATCH CHARACTERS" and "QUANTIFIERS" sections

# Standard "death penalty" pattern
str_view_all(
  string = texts,
  pattern = regex( "death penalty" , ignore_case = TRUE)
)

# Using the "." wildcard to extend the pattern "death" to include any single subsequent character.

str_view_all(
  string = texts,
  pattern = regex( "death.*" , ignore_case = TRUE)
)

# And by multiple characters

str_view_all(
  string = texts,
  pattern = regex( "death...." , ignore_case = TRUE)
)



# Adding the "+" modifies the "." preceding it.  This returns valid strings
# in which one or more characters immediately follows "death"

str_view_all(
  string = texts,
  pattern = regex( "death.+" , ignore_case = TRUE)
)



# Adding the "*" modifies the "." preceding it.  This returns valid strings 
# in which zero or more characters immediately follows "death"

str_view_all(
  string = texts,
  pattern = regex( "death.*" , ignore_case = TRUE)
)


# Whereas "*" and "+" are quantifiers  that can yield up to an infinite
# number of subsequent characters, the {} allows for more precise 
# control over the number of repetitions that can be returned as a 
# valid and matching pattern.

# {fixed-count}
str_view_all(
  string = texts,
  pattern = regex( "death.{5}" , ignore_case = TRUE)
)

# {fixed-count}
str_view_all(
  string = texts,
  pattern = regex( "death.{25}" , ignore_case = TRUE)
)

# {minimum , }
str_view_all(
  string = texts,
  pattern = regex( "death.{7,}" , ignore_case = TRUE)
)

# {minimum , maximum}
str_view_all(
  string = texts,
  pattern = regex( "death.{7,13}" , ignore_case = TRUE)
)



# In lieu of using "." which can represent any character, other special 
# characters exist that allow for more targetted selections (i.e. digits,
# punctuation, spaces, line breaks).  See Cheat sheet for full listing 
# of available options.


# \\s == whitespaces, \\w == alphanumeric characters

str_view_all(
  string = texts,
  pattern = regex( "death\\s\\w\\w\\w" , ignore_case = TRUE)
)


str_view_all(
  string = texts,
  pattern = regex( "death\\s\\w{5}" , ignore_case = TRUE)
)


str_view_all(
  string = texts,
  pattern = regex( "death\\s\\w{1,3}" , ignore_case = TRUE)
)


str_view_all(
  string = texts,
  pattern = regex( "death\\s\\w*" , ignore_case = TRUE)
)


str_view_all(
  string = texts,
  pattern = regex( "death\\s\\w+" , ignore_case = TRUE)
)


##               ##
## EXAMPLE TIME  ##
##               ##

# Since some of the texts contain dates, here one example of how 
# you might proceed in developing a regular expression pattern that
# can accurately match said dates.

# Attempt to identify all digits individually
str_view_all(
  string = texts,
  pattern = regex( "\\d./" , ignore_case = TRUE)
)


# Identify sequences of digits using the "+" quantifier
str_view_all(
  string = texts,
  pattern = regex( "\\d+" , ignore_case = TRUE)
)


# Add in the "/" that separates date components
str_view_all(
  string = texts,
  pattern = regex( "\\d+/" , ignore_case = TRUE)
)


# Write out full pattern to capture the M / D / Y of the dates
str_view_all(
  string = texts,
  pattern = regex( "\\d+/\\d+/\\d+" , ignore_case = TRUE)
)


# Alternative Solution that condenses pattern
str_view_all(
  string = texts,
  pattern = regex( "\\d+(/\\d+){2}" , ignore_case = TRUE)
)


# Alternative Solution that condenses pattern in another way
str_view_all(
  string = texts,
  pattern = regex( "(\\d+/*){3}" , ignore_case = TRUE)
)


# Alternative Solution using the {} quantifiers to explicitly define digit-sequence length
str_view_all(
  string = texts,
  pattern = regex( "\\d{1,2}/\\d{1,2}/\\d{2,4}" , ignore_case = TRUE)
)



##               ##
## PRACTICE TIME ##
##               ##

# Create a single pattern and run the code below in such a way
# that the output highlights "the state" and the three words 
# following that phrase. In each of the respective texts, the 
# following should be highlighted:
# (1) The State intends to seek
# (2) The State of Florida intends
# (3) The State does not intend
# (4) The State intend to seek
# (5) The State of Alaska intends

str_view_all(
  string = texts,
  pattern = regex( "The State\\s+(\\w+\\s+){3}" , ignore_case = TRUE)
)



+#########################################
##### Part 5 - Positional arguments #####
# Cheat sheet: see "ANCHORS" and "LOOKAROUNDS"

# In some instances, you will want to include the very beginning
# or the very end of an entire string as your criterion.  This is 
# where "anchors" come into play.

# This pattern simply collects the entire string ("." = any character, "*" = any number or quantity)
str_view_all(
  string = texts,
  pattern = regex( ".*" , ignore_case = TRUE)
)

# View all of the individual digits in the texts
str_view_all(
  string = texts,
  pattern = regex( "\\d" , ignore_case = TRUE)
)

# Using the "^" indicates that the following item must be present at the beggining of the string.
# In this case, ^\\d indicates a pattern that will only match a single digit IF that digit is at
# the beginning of the string.
str_view_all(
  string = texts,
  pattern = regex( "^\\d" , ignore_case = TRUE)
)


# Extending the example above will match entire strings, but only if the first character is a digit (\\d)
str_view_all(
  string = texts,
  pattern = regex( "^\\d.*" , ignore_case = TRUE)
)


# Using the "$" provides the inverse functionality.  The pattern below matches all characters in the string
# so long as the final character in the string is a digit (\\d)
str_view_all(
  string = texts,
  pattern = regex( ".*\\d$" , ignore_case = TRUE)
)


# Since each of the texts ends with a period, the pattern needs include \\. to represent a period.
str_view_all(
  string = texts,
  pattern = regex( ".*\\d\\.$" , ignore_case = TRUE)
)


# Whereas anchors aid in matching patterns that are positioned at the beginning and end of strings,
# look-arounds allow for more relative pattern matching.  Specifically, these methods let you define
# patterns that are characterized by strings that explicitly do or do not follow or precede other strings.

# Example: This pattern matches statements about intending to seek the death penalty.
str_view_all(
  string = texts,
  pattern = regex( "intend.* to seek the death penalty" , ignore_case = TRUE)
)

# By incorporating (?<=not ) into the pattern, this matches where the targeted phrase is preceded by "not ".
str_view_all(
  string = texts,
  pattern = regex( "(?<=not )intend.* to seek the death penalty" , ignore_case = TRUE)
)

# Same as previous example, but with the whitespace explicitly represented (\\s)
str_view_all(
  string = texts,
  pattern = regex( "(?<=not\\s)intend.* to seek the death penalty" , ignore_case = TRUE)
)


# Instead of using fixed length look-arounds, it is possibly to include variable length patterns.
# Although you can't use "*" or "+" in look-arounds, you can use {}.  This is helpful in creating
# patterns that detect strings/patterns that are within a defined range of other strings and patterns.

str_view_all(
  string = texts,
  pattern = regex( "death penalty" , ignore_case = TRUE)
)

# This effectively search for "not" and anywhere between 1-100 of any characters (".") 
# immediately preceding "death penalty".  If the "death penalty" phrase is detected, it
# will only match if the lookaround (?<=not.{1,100}) is detected immediately preceding it.
str_view_all(
  string = texts,
  pattern = regex( "(?<=not.{1,100})death penalty" , ignore_case = TRUE)
)

# With look-arounds, it is easy to switch between positive vs. negative logical statements. 
# The prior examples all highlighted how you can match a pattern conditional on the presence
# of a nearby pattern.  You can invert this to only match patterns that are NOT preceded/followed
# by a nearby pattern. 
str_view_all(
  string = texts,
  pattern = regex( "(?<!not.{1,100})death penalty" , ignore_case = TRUE)
)



##               ##
## PRACTICE TIME ##
##               ##

# Using and referring to the "LOOK AROUNDS" in the stringr cheat sheet, create a 
# regular expression pattern that matches the word "State" only if the word "state"
# is NOT followed by the word "of". 

str_view_all(
  string = texts,
  pattern = regex( "??????????" , ignore_case = TRUE)
)



#######################################################################
##### Part 6 - Detecting, Subsetting, and Mutating with REAL DATA #####

# Import readr; a utility that makes reading text files super simple.
library(readr)

# MAKE SURE TO SET YOUR WORKING DIRECTORY TO THE CORRECT LOCATION
# Top menu -> Session -> Set Working Directory

# Get a list of all text files in directory by their full pathname
files <- list.files(path="text_samples/", full.names = TRUE)
files

# Open each of the text files and assign them to the realtexts object
realtexts <- c()
for (i in files){
  temptext <- read_file(i)
  realtexts <- c(realtexts,temptext)
}

# Inspect individual texts to get a sense for what is there.  Call
# individual texts explicitly as well as using the cat(...) function.
realtexts[1]
cat(realtexts[1])

realtexts[2]
cat(realtexts[2])

# For simplicity, let's convert realtexts into a data.frame() object.
# This will make it easier to manage going forward.
textDF <- data.frame("texts" = realtexts)


# Once you have a grasp of how to write regular expression patterns, 
# you are ready to start using some other functions for transforming 
# texts, labeling samples, and extracting substrings.

# Cheat sheet: See Page 1 (Detect Strings, Subset Strings, Manage Lengths, and Mutate Strings, namely)

# Based on inspecting the realtexts object, a quick view of the pattern below 
# reveals that some sentences and phrases are broken up by full line breaks 
# (\\n).  This can make it very hard to search for patterns.
str_view_all(
  string = textDF$texts,
  pattern = "\n(?!\n)"
  )

# So one text-cleanup remedy I identified for this problem is to simply
# replace all line breaks that are not immediately followed by another 
# line break with a simple space (" ").

textDF$texts_mod <- str_replace_all(
  string=textDF$texts,
  pattern="\n(?!\n)",
  replacement = " "
  )

# Inspect to make sure the replacement worked correctly
# Original
str_view_all(
  string = textDF$texts,
  pattern = "\n(?!\n)"
  )

# Updated in dataframe
str_view_all(
  string = textDF$texts_mod,
  pattern = "\n(?!\n)"
  )


# Now, using "Detect" and "Subset" functions, patterns can be 
# used to build out the textDF dataset.

# str_view_all() for the pattern "aggravat" representing the words like
# "aggravating", "aggravate", "aggravated", ...
str_view_all(
  string = textDF$texts_mod,
  pattern = regex("aggravat", ignore_case = TRUE)
  )

# Using detect returns an array of TRUE/FALSE if a pattern is detected.
str_extract_all(
  string = textDF$texts_mod,
  pattern = regex("aggravat", ignore_case = TRUE)
)

# Using detect returns an array of TRUE/FALSE if a pattern is detected.
str_detect(
  string = textDF$texts_mod,
  pattern = regex("aggravating", ignore_case = TRUE)
)

# Assign the values of detect to textDF$mitigate
textDF$aggravate <- str_detect(
  string = textDF$texts_mod,
  pattern = regex("aggravat", ignore_case = TRUE)
  )

# Get and assign counts of the pattern "mitig" to its own column in textDF.
textDF$aggravate_count <- str_count(
  string = textDF$texts_mod,
  pattern = regex("aggravat", ignore_case = TRUE)
  )

# NOW LET'S EXPAND
# The pattern example below is just one of many ways you can systematically
# explore the texts.  In this case, finding instances of "aggravat" and then
# finding up to 3 subsequent lines of text with up to 500 characters.
str_extract_all(
  string = textDF$texts_mod,
  pattern = regex("aggravat.{1,500}(\\n.{1,500}){0,3}", ignore_case = TRUE)
)


# stringr (and regular expression broadly) also allow you to extract information.
# While this can be used on fixed strings, it is often more useful when using more 
# generalized regular expression patterns.

# For example, a cursory scan of the texts shows a variety of legal statutes and rules.
# It may be valuable to extract these for ready reference and analysis later on.

# 3.181
# 921.141(6)
# §782.04(1)(b)
# 3.202(3)

# One regex pattern that might encapsulate all of these
# [:punct:]*\\d+\\.\\d+(\\((\\d+|\\w+)\\))*

# Run str_extract_all() by itself to see if the pattern works as expected
str_extract_all(
  string = textDF$texts_mod,
  pattern = regex("[:punct:]*\\d+\\.\\d+(\\((\\d+|\\w+)\\))*", ignore_case = TRUE)
)

# Assign extracted values to dataframe
textDF$law_codes <- str_extract_all(
  string = textDF$texts_mod,
  pattern = regex("[:punct:]*\\d+\\.\\d+(\\((\\d+|\\w+)\\))*", ignore_case = TRUE)
  )



##               ##
## PRACTICE TIME ##
##               ##

# There are a handful of texts that contain the defendant's name in a consistent pattern:
# "...defendant, NAME GOES HERE, ..." 
# See if you can write a pattern that accurately captures identifies that pattern and then
# extract that information into its own column in textDF.
# Note: This may be quite challenging at first.  I have included one possible solution further
# down in the code.  So if you get stuck, you can try to use my example, understand it, and 
# modify it if you think of a better way to approach the challenge.  GOOD LUCK!


# Inspect sample #2 : A sample known to have the "...defendant, NAME NAME,..." pattern
print(textDF$texts_mod[2])
cat(textDF$texts_mod[2])

# Test and experiment with the pattern on a known-text
str_extract_all(
  string = textDF$texts_mod[2],
  pattern = regex( "??????????????" , ignore_case = TRUE)
)

# Test and experiment with the pattern for all texts
str_extract_all(
  string = textDF$texts_mod,
  pattern = regex( "??????????????" , ignore_case = TRUE)
)

# Assign values to textDF
textDF$named_defendant <- str_extract_all(
  string = textDF$texts_mod,
  pattern = regex( "??????????????" , ignore_case = TRUE)
  )

# 
# 
# 
# 
# 
# 
# 
# 
# 
print("BE CAREFUL, THE NEXT LINES OF CODE CONTAIN POSSIBLE ANSWERS")
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
pattern_names <- "(?<=defendant, )(\\w+)(\\s\\w+){1,2}(?=,)"

str_extract_all(
  string = textDF$texts_mod,
  pattern = regex(  pattern_names , ignore_case = TRUE)
)

textDF$named_defendant <- str_extract_all(
  string = textDF$texts_mod,
  pattern = regex(  pattern_names , ignore_case = TRUE)
)



