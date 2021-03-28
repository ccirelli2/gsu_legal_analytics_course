"""
Script to prepare the networth dataset.
"""

###############################################################################
# Import Libraries
###############################################################################
import os
import sys
import pandas as pd
import numpy
import re

###############################################################################
# Define Directories
###############################################################################
dir_repo = r'/home/cc2/Desktop/repositories/gsu_legal_analytics_course/project'
dir_scripts = os.path.join(dir_repo, 'scripts')
dir_data = os.path.join(dir_repo, 'data')


###############################################################################
# Load Data
###############################################################################
path2file = os.path.join(dir_data, 'net_worth_cp_webpage.xlsx')
data = pd.read_excel(path2file, sheet_name='all_years')

###############################################################################
# Data Wrangling
###############################################################################

def sep_first_last_names(data, **kwargs):

    # Declare Variables
    NAMES = data['Name'].values

    # Declare Regex Statements
    regex_first_name = '^[A-Z][a-z]+\s'
    regex_last_name = '\s[A-Z][a-z]+\s'
    regex_party_state= '\(R-[A-Z][A-Za-z]+\)|\(D-[A-Z][A-Za-z]+\)|\(I-[A-Z][A-Za-z]+\)'
    regex_party = 'R-|D-|I-'
    regex_state = '-[A-Z][A-Za-z]+'
    # Find Matches
    first_name = list(map(lambda x:
        re.search(regex_first_name, x).group(0) if
        isinstance(re.search(regex_first_name, x), re.Match) else
        'NoMatch', NAMES))
    last_name = list(map(lambda x:
        re.search(regex_last_name, x).group(0) if
        isinstance(re.search(regex_last_name, x), re.Match) else
        'NoMatch', NAMES))
    party_state = list(map(lambda x:
        re.search(regex_party_state, x).group(0) if
        isinstance(re.search(regex_party_state, x), re.Match) else
        'NoMatch', NAMES))
    party = list(map(lambda x:
        re.search(regex_party, x).group(0) if
        isinstance(re.search(regex_party, x), re.Match) else
        'NoMatch', party_state))
    state = list(map(lambda x:
        re.search(regex_state, x).group(0) if
        isinstance(re.search(regex_state, x), re.Match) else
        'NoMatch', party_state))

    # Add Columns to DataFrame
    data['first_name'] = first_name
    data['last_name'] = last_name
    data['party_state'] = party_state
    data['party'] = party
    data['state'] = state
    

    # Write2file
    if kwargs['write2file']:
        data.to_csv(os.path.join(
            kwargs['dir_data'], 'net_worth_data_processed.csv'))

    # Return data
    return data



kwargs = {'dir_data' : dir_data, 'write2file':True}

data = sep_first_last_names(data, **kwargs)




