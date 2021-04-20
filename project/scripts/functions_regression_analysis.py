

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
from scipy.stats import pearsonr


from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.tree import export_graphviz
from sklearn.metrics import r2_score
from sklearn.metrics import mean_squared_error


from scipy.stats import pearsonr

import pydot

import shap

###############################################################################
# Functions - Data Transformation
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

def group_data(data, catcols, contcols, how):                                    
    """                                                                         
    Function to group data with and without the keywords as covariates.         
                                                                                
    Args:                                                                          
        data: Ungrouped dataframe                                               
        catcols: list of columns to include in group.                           
        contcols: list of columns to take mean.                                  
        how: with or without                                                    
                                                                                
    Returns:                                                                    
        grouped data                                                            
                                                                                
    """
    catcols_cp = catcols.copy()

    # Group Data Without Key Words                                              
    if how=='without':
        catcols_cp.remove('keyword')                                               
                                                                                
    # Add concatenated name before group                                        
    catcols_cp+=['firstlastname']                                                  
                                                                                
    # Return grouped data                                                       
    d_grouped=data.groupby(catcols_cp)['AverageNetWorth', 'negative_wnh_txt',         
                'positive_wnh_txt'].mean().reset_index()    
    
    # Remove Names Column
    d_grouped.drop('firstlastname', inplace=True, axis=1)

    # Return grouped data
    return d_grouped

def impute_mean_nan(data, CONTCOLS):                                               
    # Get Null Values By Feature                                                   
    nans = data.isna().sum()                                                  
    nan_cols = nans[nans.values > 0].index.tolist()                                
    print(f'cols w/ null values => {nan_cols}')                           
    # Iterate Columns w/ Null Values                                               
    for col in nan_cols:                                                           
        if col in CONTCOLS:                                                        
            data[col].fillna(data[col].mean(), inplace=True)             
    # Get remaining null columns                                                   
    nans = data.isna().sum()                                                  
    nan_cols = nans[nans.values > 0].index.tolist()                                
    print(f'remaining cols w/ null values => {nan_cols}\n')                           
    # Return data                                                                  
    return data


###############################################################################
# Functions - Plots
###############################################################################

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


def get_scatter_plot(data, independent, dependent, gen_subgroup,
        log_x, savefig, dir_output):      
    
    if log_x:                                                                   
        # Drop nan values                                                       
        print(f'data dim pre drop nans => {data.shape}')                        
        data.dropna(inplace=True, axis=0)                                       
        print(f'data dim post drop nans => {data.shape}')                       
        # Drop Negative Values                                                  
        data=data[data[independent] > 0]                                               
        # Take Log of data                                                      
        data[independent] = np.log(data[dependent].values)                                  


    if gen_subgroup:
        # Define SubGroup Columns
        cols_subgroup=[x for x in data.columns if x not in [
            'AverageNetWorth', 'sent_score']]
        # Iterate column w/ subgroups
        for subgroup in cols_subgroup:
            # Subset data by subgroup
            data_sub=data[data[subgroup]==1]
            # Minimum Number of Observations

            if data_sub.shape[0] > 2:
                # Generate Scatter Plot
                var1=data_sub[independent].values
                var2=data_sub[dependent].values
                sns.regplot(var1, var2)                                          
                title='''Scatter Plot {} ~ {}, Subgroup => {},
                         Log => {} Pearson =>'''.format(
                        dependent, independent, subgroup, log_x)
                plt.title(title)                                                            
                plt.xlabel(var1)                                                            
                plt.ylabel(var2)                                                            
                if savefig:                                                                    
                    path2file = os.path.join(dir_output, title.replace(' ', '_'))              
                    plt.savefig(path2file)                                                     
                plt.show()                                                                     
                plt.close()   



def regplot_by_subgroup(data, savefig, dir_output):
    # Define features
    features=[x for x in data.columns if x not in ['AverageNetWorth',
        'sent_score', 'negative_wnh_txt', 'positive_wnh_txt']]

    # Convert Independent Variable to Log
    data = data[data['AverageNetWorth'] > 0]
    data['AverageNetWorth'] = np.log(data['AverageNetWorth'].values)
    print(data.shape)
    data['AverageNetWorth'].dropna(inplace=True, axis=0)
    print(data.shape)
    print('Features => {}'.format(features))
    print('Data cols => {}'.format(data.columns))

    # Iterate Subgroups
    for col in features:
        # SubSet Data
        data_cp = data.copy()
        subdata=data_cp[data_cp[col]==1]
        print(f'Sub col {col} dimensions => {subdata.shape}')

        if subdata.shape[0] > 2:
            # Calculate 
            corr=round(pearsonr(subdata['AverageNetWorth'].values,
                subdata['sent_score'].values)[0], 2)
            # Generate Plot
            sns.regplot(subdata['AverageNetWorth'].values,
                        subdata['sent_score'].values)
            title=f'''Regression Plot - Sentiment on AvgNetWorth
                      Sub Group {col} Corr {corr}'''
            filename=f'regression_plot_sent_on_networth_subgroup_{col}'
            plt.title(title)
            plt.xlabel('AverageNetWorth')
            plt.ylabel('Sentiment')
            plt.tight_layout()
            if savefig:
                path2file = os.path.join(dir_output, 'scatter_plots', filename)
                plt.savefig(path2file)
            plt.show()
            plt.close()




###############################################################################
# Functions - Models 
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


    # Define Model
    x = data['AverageNetWorth'].values.tolist()
    y = data['sent_score'].values
    model = sm.OLS(y, x)
    
    plt.scatter(x, y)
    plt.show()
    plt.close()

    # Fit Model Normal & Regularized Regression Model
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


def OLS_feature_sub(data, logx, x_vars, sub_var, reg, title, dir_output):
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

    # Subset Data
    data=data[data[sub_var]==1]

    # Define Model
    x = data[x_vars]
    y = data['sent_score']
    model = sm.OLS(y, x)
    
    # Fit Model Normal & Regularized Regression Model
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


def reg_poly(data, logx, degree):
    # Convert AverageNetWorth Log Scale
    if logx:
        # Subset data only positive networth
        logging.info(f'Logx True. Dimensions pre log => {data.shape}')
        data = data[data['AverageNetWorth'] > 0]
        logging.info(f'Dimensions post log => {data.shape}')
        # Log NetWorth
        data['AverageNetWorth'] = np.log(data['AverageNetWorth'].values)
    
    # Polynomial
    data['AverageNetWorth_poly'] = data['AverageNetWorth'].values **degree

    x = data[['AverageNetWorth', 'AverageNetWorth_poly']].values
    y = data['sent_score'].values
    
    model = sm.OLS(y, x)
    result=model.fit() 
    print(result.summary())
    
    # Plot OLS Rel
    sms_reg_plot(results,
            title=title,
            savefig=True,
            dir_output=dir_output)


    
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












