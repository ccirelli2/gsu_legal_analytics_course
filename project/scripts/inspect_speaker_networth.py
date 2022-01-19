###############################################################################
# Import Libraries
###############################################################################
import os
import logging
logging.basicConfig(level=logging.INFO)
import pandas as pd
import numpy as np
import warnings
import matplotlib.pyplot as plt
import seaborn as sns


###############################################################################
# Library Settings
###############################################################################
pd.set_option("max_rows", 100)
pd.set_option("max_columns", None)
warnings.filterwarnings('ignore')


###############################################################################
# Define Directories 
###############################################################################
dir_repo = r'/home/cc2/Desktop/repositories/gsu_legal_analytics_course/project'
dir_results=os.path.join(dir_repo, 'results')
dir_eda=os.path.join(dir_results, 'eda')

###############################################################################
# Import Data 
###############################################################################
data = pd.read_csv(os.path.join(
    dir_results, 'crp_sentiment_join_networth.csv'))

logging.info(f'Data dimensions => {data.shape}')


###############################################################################
# Data Transformation 
###############################################################################

# Add flag wage & hour text
data['wnh_flag'] = list(map(lambda x: 1 if isinstance(x, str) else 0,
                            data['prepost_txt'].values))
logging.info(f"Number of wage & hour rows => {data['wnh_flag'].sum()}")

# Limit Data to Wage & Hour
data_wnh = data[data['wnh_flag']==1]

# Convert negative_wnh_txt score to negative
data_wnh.loc[:, 'negative_wnh_txt'] = [
        x * -1 for x in data_wnh['negative_wnh_txt'].values]

# Concat First & Last Name
data_wnh['firstlastname'] = np.add(
        data_wnh.loc[:, 'firstname'].values,
        data_wnh.loc[:, 'lastname'].values)

# Group By First & Last Name 
d_grouped = data_wnh.groupby([
            'firstlastname', 'chamber', 'state', 'gender', 'party'])[
                'AverageNetWorth', 'negative_wnh_txt',
                'positive_wnh_txt'].mean()

# Calculate Average Sentiment Score By Congressman 
d_grouped['sent_score'] = np.add(
        d_grouped.loc[:, 'negative_wnh_txt'].values,
        d_grouped.loc[:, 'positive_wnh_txt'].values)

# Fill Nans & Reset Index
d_grouped.fillna(value=0, inplace=True)
d_grouped.reset_index(inplace=True)

###############################################################################
# Plot Functions 
###############################################################################

# Plot Distributions
def get_dist(x, nbins, title, varname, savefig, directory):
    # Plot Parameters
    plt.figure(figsize=(20, 15), dpi=100)
    plt.rcParams.update({'font.size': 20})
    # Plot
    plt.hist(x, bins=nbins)
    # Asthetics
    plt.grid(b=True)
    plt.title(title)
    plt.xlabel(varname)
    # Save Figure
    if savefig:
        title = title.replace(' ', '_')
        path2file = os.path.join(directory, title)
        plt.savefig(path2file)
        logging.info(f'Saving figure to => {path2file}')
    # Show Figure
    plt.show()
    plt.close()

# Scatter Plot - Net Worth vs Sentiment
def get_scatter_plot(x, y, title, savefig, directory):
    sns.set(rc={'figure.figsize':(20, 15)})
    sns.set(font_scale=2)
    sns.scatterplot(x, y, s=75, alpha=.5)
    plt.title(f'{title}')
    plt.xlabel('Avg Net Worth')
    plt.ylabel('Sentiment')
    plt.grid(b=True)
    if savefig:
        title = title.replace(' ', '_')
        path2file = os.path.join(directory, title)
        plt.savefig(path2file)
        logging.info(f'Saving figure to => {path2file}')
    # Show Figure
    plt.show()
    plt.close()


def get_reg_plot(x, y, title, savefig, directory):
    sns.set(rc={'figure.figsize':(20, 15)})
    sns.set(font_scale=2)
    sns.regplot(x, y)
    plt.title(f'{title}')
    plt.xlabel('Avg Net Worth')
    plt.ylabel('Sentiment')
    plt.grid(b=True)
    if savefig:
        title = title.replace(' ', '_')
        path2file = os.path.join(directory, title)
        plt.savefig(path2file)
        logging.info(f'Saving figure to => {path2file}')
    # Show Figure
    plt.show()
    plt.close()

    plt.show()
    plt.close()


###############################################################################
# Plots 
###############################################################################

# Exclude Outlier Net Worth For Scaling
d_grouped = d_grouped[(d_grouped['AverageNetWorth'] > 0)]

# Declare X & Y Values
x = d_grouped['AverageNetWorth'].values
y = d_grouped['sent_score'].values

# Get Log Scaled Values
x_log = np.log(x) 


# Distribution Plots
get_dist(x, 20, 'Dist Of AvgNetWorth - No Scaling',
        'AvgNetWorth', True, dir_eda)

get_dist(y, 20, 'Dist Of Sentiment Scores - No Scaling',
        'Sentiment Score', True, dir_eda)

# Distribution Plots - Log Scale
get_dist(x_log, 20, 'Dist Avg Net Worth - Log Scale',
        'Log Avg Net Worth', True, dir_eda)


# Scatter Plot - Normal Scale
get_scatter_plot(x, y, 'Avg Net Worth vs Sentiment Score - No Scaling',
        True, dir_eda)


# Scatter Plot - Log Scale
get_scatter_plot(x_log, y, 'Avg Net Worth vs Sentiment Score - Log Scale',
        True, dir_eda)

# Regression Plots
get_reg_plot(x, y,
        'Reg Plot Avg Net Worth vs Sentiment Score - No Scaling',
        True, dir_eda)

get_reg_plot(x_log, y,
        'Reg Plot Log Avg Net Worth vs Sentiment Score - Log Scale',
        True, dir_eda)




















