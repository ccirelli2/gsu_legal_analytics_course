

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

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.tree import export_graphviz
from sklearn.metrics import r2_score
from sklearn.metrics import mean_squared_error


from scipy.stats import pearsonr

import pydot

import shap

###############################################################################
# Functions 
###############################################################################

def data_transform(data):
    # Add flag wage & hour text
    logging.info('Adding wage & hour flag')
    data['wnh_flag'] = list(map(lambda x: 1 if isinstance(x, str) else 0,
                                data['prepost_txt'].values))

    # Limit Data to Wage & Hour
    logging.info('Limit data to only wage & hour text')
    data_wnh = data[data['wnh_flag']==1]

    # Convert negative_wnh_txt score to negative
    logging.info('Converting score to negative')
    data_wnh.loc[:, 'negative_wnh_txt'] = [
            x * -1 for x in data_wnh['negative_wnh_txt'].values]

    # Concat First & Last Name
    logging.info('Concatenating First & Last Names')
    data_wnh['firstlastname'] = np.add(
            data_wnh.loc[:, 'firstname'].values,
            data_wnh.loc[:, 'lastname'].values)


    # Convert Keyword Column to lowercase
    data_wnh['keyword'] = [x.lower() for x in data_wnh['keyword'].values]

    # Consolidate keywords to root
    logging.info('Consolidating key words to wages, overtime and workweek')
    kword_dict={
            'wages': 'wages', 'overtime': 'overtime', 'workweek': 'workweek',
            'workweeks': 'workweek', 'overtimes': 'overtime', 'wagesa': 'wages',
            'doubleovertime': 'overtime', 'yearswages': 'wages',
            'overtimethe': 'overtime', 'backwages': 'wages', 'wagesso': 'wages',
            'wageslocally': 'wages', 'wageshave': 'wages', 'overtimeany': 'overtime',
            'workweekso': 'workweek', 'workweekis': 'workweek', 'workweekthe': 'workweek',
            'workweeksthat': 'workweek', 'upwages': 'wages', 'wageso': 'wages',
            'wageswhat': 'wages', 'wagesupport': 'wages', 'wagesthose': 'wages',
            'wagesincluding': 'wages', 'wagesno': 'wages', 'wageswhether': 'wages',
            'wagesas': 'wages', 'overtimewhich': 'overtime'}

    data_wnh['keyword'] = [kword_dict[x] for x in data_wnh['keyword'].values]

    # Return transformed data
    return data_wnh


def fit_rf(data, FEATURES, TARGET, shap):                                        
    # Subset dataset                                                            
    data = data[FEATURES + TARGET]                                              
                                                                                
    # Subset data only positive networth
    logging.info(f'Logx True. Dimensions pre log => {data.shape}')
    data = data[data['AverageNetWorth'] > 0]
    logging.info(f'Dimensions post log => {data.shape}')
    # Log NetWorth
    data['AverageNetWorth'] = np.log(data['AverageNetWorth'].values)
    
    # Define X & Y Variables                                                    
    X = data.drop(TARGET, axis=1)                                               
                                                                                
    y = data[TARGET[0]].values                                                  
                                                                                
    # Train Test Split                                                          
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.33)   
                                                                                
    # Fit RF Model                                                              
    rf = RandomForestRegressor(n_estimators=500, random_state=123,              
            oob_score=True)                                                     
    rf.fit(X_train, y_train)                                                    
                                                                                
    # Predict                                                                   
    yhat = rf.predict(X_test)                                                   
                                                                                
    # R2                                                                      
    r2 = r2_score(y_test, yhat)                                                 
    
    # MSE
    mse = mean_squared_error(y_test, yhat)

    # Pearson                                                                   
    pearson = pearsonr(y_test, yhat)                                            
                                                                                
    # Scatter Plot Predicted vs Observed                                        
    plt.scatter(y_test, yhat, c=y_test)
    plt.title('Prediction vs Actual')
    plt.xlabel('Actual')                                                      
    plt.ylabel('Predicted')
    plt.legend(['Actual', 'Predicted'], loc='upper right')
    plt.show()                                                                  
    plt.close()                                                                 
                                                                                
    # Feature Importance                                                        
    f_importance = rf.feature_importances_                                      
    df_feature_imp = pd.DataFrame({})                                           
    df_feature_imp['Feature'] = FEATURES                                        
    df_feature_imp['Imp'] = f_importance        
    df_feature_imp.sort_values(by='Imp')

    # Random Forest Feature Importance
    plt.bar(x=FEATURES, height=f_importance)
    plt.xticks(rotation=90)
    plt.show()                                                                  
    plt.close()                                                                 
    
    if shap:
        # Shap Feature Importance
        shap_values = shap.TreeExplainer(rf).shap_values(X_train)
        shap.summary_plot(shap_values, X_train, plot_type='bar')
        plt.show()
        plt.close()

        # Shap Summary Plot
        shap.summary_plot(shap_values, X_train)
        plt.show()
        plt.close()

        # Shap Dependency Plot
        shap.dependence_plot("AverageNetWorth", shap_values, X_train)
        plt.show()
        plt.close()

    # Return results                                                               
    logging.info(f'MSE => {mse}')
    logging.info(f'R squared score => {r2}')                                    
    logging.info(f'Pearson corrcoef => {pearson[0]}')     



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
    sms_reg_plot(results,
            title=title,
            savefig=True,
            dir_output=dir_output)



    












