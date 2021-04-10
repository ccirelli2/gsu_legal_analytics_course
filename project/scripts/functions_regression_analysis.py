

###############################################################################
# Import Libraries
###############################################################################
import logging
logging.basicConfig(level=logging.INFO)
import os
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import seaborn as sns

import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.graphics.gofplots import qqplot

###############################################################################
# Functions 
###############################################################################

def OLS(data, logx, x_vars, reg, title, dir_output):
    """

    Args:
        data: DataFrame; contains training and target data
        logx: Boolean; Take log of AverageNetWorth
        x_vars: List; list of independent variables
        title: Str; Title for plots
        dir_output: Str; directory to write model results

    """

    # If Log of AvgNetWorth
    if logx:
        # Subset data only positive networth
        logging.info(f'Logx True. Dimensions pre log => {data.shape}')
        data = data[data['AverageNetWorth'] > 0]
        logging.info(f'Dimensions post log => {data.shape}')
        # Log NetWorth
        data['AverageNetWorth'] = np.log(data['AverageNetWorth'].values)

    # Plot Distribution Scaled Variable
    #m1.plot_hist(data, 'AverageNetWorth', title, True, dir_output) 

    # Define Model
    x = data[x_vars]
    y = data['sent_score']
    model = sm.OLS(y, x)

    # Fit Model
    if reg:
        results=model.fit_regularized(alpha=0.1,method='elastic_net',
                L1_wt=1,refit=True)
        #print(results.params)
        print(results.summary())
    else:
        results=model.fit()
        print(results.summary())
    
    # Plot OLS Rel
    m1.sms_reg_plot(results,
            title=title,
            savefig=True,
            dir_output=dir_output)



def plot_hist(data, var_name, title, savefig, dir_output):
    plt.hist(data[var_name].values)          
    plt.title(title)                          
    if savefig:
        path2file = os.path.join(dir_output, title.replace(' ', '_')) 
        plt.savefig(path2file)
    plt.show()                                                                  
    plt.close()     


def sms_reg_plot(results, title, savefig, dir_output):
    fig, ax = plt.subplots(figsize=(15, 10))
    plt.rcParams.update({'font.size':20})
    fig = sm.graphics.plot_fit(results, 0, ax=ax)
    ax.set_ylabel("Sentiment Score")
    ax.set_xlabel("Average Net Worth")
    ax.set_title(title)
    if savefig:
        path2file = os.path.join(dir_output, title.replace(' ', '_')) 
        plt.savefig(path2file)
    plt.show()
    plt.close()

def sms_qqplot(data, var_name, logx, title, savefig, dir_output):
    
    if logx:
        # Subset data only positive networth
        data = data[data['AverageNetWorth'] > 0]
        # Log NetWorth
        data['AverageNetWorth'] = np.log(data['AverageNetWorth'].values)
    
    # Generate Plot
    qqplot(data[var_name].values,
            line="45")
    plt.ylabel("Sentiment Score")
    plt.xlabel("Average Net Worth")
    plt.title(title)
    if savefig:
        path2file = os.path.join(dir_output, title.replace(' ', '_')) 
        plt.savefig(path2file)
    plt.show()
    plt.close()
    












