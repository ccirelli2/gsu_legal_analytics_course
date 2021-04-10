
import pandas as pd
import os
import sys
import csv
from csv import reader
from csv import unix_dialect

dir_data=r'/home/cc2/Desktop/repositories/gsu_legal_analytics_course/project/data/original_income_files'

csv.field_size_limit(sys.maxsize)

years={}
count=0
with open(os.path.join(dir_data, 'assets.csv'), 'r', encoding='cp1252') as read_obj:
    csv_reader=reader(read_obj, delimiter='|')
    for row in csv_reader:
        count+=1
        try:
            years[str(row[7])]=''
        except IndexError:
            pass

print(years)
print(count)
