dir_data=r'/home/cc2/Desktop/repositories/gsu_legal_analytics_course/project/data/crec'

import pandas as pd
import os

df=pd.read_csv(os.path.join(dir_data, 'speaker_output_chris.csv'), nrows=5)


for row in df.itertuples():
    print(row[3])
