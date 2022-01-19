"""
Description: Script to load open secrets bulk data files

"""
################################################################################
# Load Libraries
################################################################################
import logging
import pandas as pd
import os
import sys

################################################################################
# Directories 
################################################################################
dir_repo=r'/home/cc2/Desktop/repositories/gsu_legal_analytics_course'
dir_proj=os.path.join(dir_repo, 'project')
dir_scripts=os.path.join(dir_proj, 'scripts')
dir_data=os.path.join(dir_proj, 'data')
dir_meta=os.path.join(dir_proj, 'data', 'metadata')
sys.path.append(dir_scripts)

################################################################################
# Import Project Modules 
################################################################################
import functions_bulk_data as m1


################################################################################
# Load Data 
################################################################################

# Get Asset Column Names
colnames=pd.read_csv(os.path.join(
    dir_meta, 'assets_data_dict.csv'))['Field Name'].tolist()


assets=pd.read_csv(os.path.join(dir_data,
    'original_income_files',
    'assets.csv'), encoding='cp1252', sep='|',
    nrows=302000,
    names=colnames)


# Write output
assets.to_csv(os.path.join(
    dir_data, 'formatted_income_files', 'assets_alldata.csv'))




