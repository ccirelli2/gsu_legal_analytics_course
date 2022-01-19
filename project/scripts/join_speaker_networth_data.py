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
dir_results = os.path.join(dir_repo, 'results')

###############################################################################
# Load Data
###############################################################################
path2file = os.path.join(dir_results, 'net_worth_data_processed.csv')
networth = pd.read_csv(path2file)

path2file = os.path.join(dir_data, 'SAMPLE_2017-2020_segmented_speaker.csv')
speaker = pd.read_csv(path2file)


###############################################################################
# Data Wrangling
###############################################################################

# Speaker File
speaker['first_name'] = list(map(lambda x: x.split(' ')[0].upper().strip() if
                                isinstance(x, str) else x,
                                speaker['firstname']))
speaker['last_name'] = list(map(lambda x: x.split(' ')[0].upper().strip() if
                                isinstance(x, str) else x,
                                speaker['speaker']))

print(speaker.shape)











