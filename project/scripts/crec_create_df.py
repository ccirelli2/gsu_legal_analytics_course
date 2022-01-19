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
dir_data=os.path.join(dir_proj, 'data/crec')

################################################################################
# Import Project Modules 
################################################################################

filenames_dirty=os.listdir(dir_data)
filenames_clean=[x.lower().replace('-', '_').replace('.pdf', '') for x in os.listdir(dir_data)]

df_txt=pd.DataFrame({})
fname=[]
text=[]

for filen in filenames_dirty:
    fname.append(filen.lower().replace('-', '_').replace('.pdf', ''))
    txt=open(os.path.join(dir_data, filen), 'r').read()
    txt_clean=txt.encode("ascii", errors="ignore").decode()
    text.append(txt_clean)

df_txt['filename']=fname
df_txt['text']=text
df_txt.to_csv(os.path.join(dir_data, 'crec_dataframe.csv'))


print(df_txt.head())
