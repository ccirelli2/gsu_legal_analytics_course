###############################################################################
# Import Libraries
###############################################################################
import os
import sys
import logging
logging.basicConfig(level=logging.INFO)
import pandas as pd
import numpy as np
import warnings
import matplotlib.pyplot as plt
import seaborn as sns
from collections import Counter


import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.graphics.gofplots import qqplot

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.tree import export_graphviz
from sklearn.metrics import r2_score
from scipy.stats import pearsonr

import statsmodels.formula.api as smf

import pydot

###############################################################################
# Library Settings
###############################################################################
pd.set_option("max_rows", 100)
pd.set_option("max_columns", None)
warnings.filterwarnings('ignore')


###############################################################################
# Define Directories 
###############################################################################
dir_repo = 'C:\\Users\\chris.cirelli\\Desktop\\repositories\\gsu_legal_analytics_course\\project'
dir_data=os.path.join(dir_repo, 'data')
dir_scripts=os.path.join(dir_repo, 'scripts')
dir_results=os.path.join(dir_repo, 'results')
dir_eda=os.path.join(dir_results, 'eda')
dir_results_ols=os.path.join(dir_results, 'ols')

[sys.path.append(x) for x in [dir_scripts, dir_results, dir_eda]]


###############################################################################
# Import Project Modules 
###############################################################################
import functions_regression_analysis as m1


###############################################################################
# Import Data 
###############################################################################
data = pd.read_csv(os.path.join(
    dir_results, 'crp_sentiment_join_networth.csv'))
logging.info(f'Data dimensions => {data.shape}')


###############################################################################
# Declare Variables By DataType
###############################################################################
CATCOLS=['chamber', 'state', 'gender', 'party', 'keyword']
CONTCOLS=['AverageNetWorth', 'negative_wnh_txt', 'positive_wnh_txt']
FEATURES=CATCOLS+CONTCOLS
TARGET=['sent_score']
ROOTKEYWORDS=['wages', 'overtime', 'workweek']

###############################################################################
# Data Transformation 
###############################################################################

# Basic data cleaning
data_wnh = m1.data_transform(data)

# Group Data W/out key words
'''Note: Different key words were grouped to the same speaker, which
         complicates grouping by speaker name to get average networth by
         speaker.'''
d_grouped_w=m1.group_data(data_wnh, CATCOLS, CONTCOLS, 'with')
d_grouped_wout=m1.group_data(data_wnh, CATCOLS, CONTCOLS, 'without')

# Imput Mean to Null Cols
d_grouped_w=m1.impute_mean_nan(d_grouped_w, CONTCOLS)
d_grouped_wout=m1.impute_mean_nan(d_grouped_wout, CONTCOLS)


# Create Dummy Variables For Cat Features
d_grouped_w = pd.get_dummies(d_grouped_w, columns=CATCOLS)
d_grouped_wout = pd.get_dummies(d_grouped_wout, columns=CATCOLS.copy().remove(
    'keyword'))

# Redefine Feature Variables Include Dummies
FEATURES_w=[x for x in d_grouped_w.columns if x not in ['firstlastname',
    'negative_wnh_txt', 'positive_wnh_txt', 'sent_score']]
FEATURES_wout=[x for x in d_grouped_wout.columns if x not in ['firstlastname',
    'negative_wnh_txt', 'positive_wnh_txt', 'sent_score']]

###############################################################################
# Calculate Average Sentiment Score 
###############################################################################

d_grouped_wout['sent_score'] = np.add(
        d_grouped_wout.loc[:, 'negative_wnh_txt'].values,
        d_grouped_wout.loc[:, 'positive_wnh_txt'].values)

d_grouped_w['sent_score'] = np.add(
        d_grouped_w.loc[:, 'negative_wnh_txt'].values,
        d_grouped_w.loc[:, 'positive_wnh_txt'].values)


# Pearson Correlation
def get_pearson_corr(data, var1, var2):
    v1 = data[var1].values
    v2 = data[var2].values
    pearson_coef = pearsonr(v1, v2)

# Generate Scatter Plots
"""
m1.get_scatter_plot(d_grouped_wout, independent='AverageNetWorth',
        dependent='sent_score', gen_subgroup=True, log_x=True,
        savefig=True, dir_output=dir_results)

m1.get_scatter_plot(d_grouped_wout, var1='AverageNetWorth', var2='sent_score',
        log_x=False, title='Scattere Plot Sentiment ~ AvgNetWorth',
        savefig=True, dir_output=dir_results)
"""

###############################################################################
# Write Prepared Dataset to CSV 
###############################################################################

#d_grouped_wout.to_csv(os.path.join(dir_data, 'ols_transformed_data.csv'))



###############################################################################
# EDA Independent & Dependent Variables 
###############################################################################
"""
m1.plot_hist(d_grouped, 'sent_score', 'Sentiment Score', True, dir_output)
m1.plot_hist(d_grouped, 'AverageNetWorth', 'Average Net Worth', True, dir_output)
m1.sms_qqplot(data=d_grouped, var_name='AverageNetWorth',
        logx=True, title="QQPlot Log AvgNetWorth",
        savefig=True, dir_output=dir_output)
"""

###############################################################################
# Fit OLS Model 
###############################################################################

m1.OLS(d_grouped_wout, logx=True,
        x_vars=['AverageNetWorth'], reg=False,
        title='OLS Sentiment on All Features w Lasso Ridge',
        dir_output=dir_results_ols)


###############################################################################
# Fit OLS Model - Sub Feature 
###############################################################################

"""
sub_var='party_R'
m1.OLS_feature_sub(d_grouped_wout, logx=True,
        x_vars=['AverageNetWorth'], sub_var=sub_var, reg=False,
        title=f'OLS Sentiment on LogAvgNetWorth - {sub_var}',
        dir_output=dir_results_ols)
"""


###############################################################################
# Fit OLS Polynomial Form 
###############################################################################

#m1.reg_poly(d_grouped_wout, logx=True, degree=3)


###############################################################################
# Fit Random Forest Model 
###############################################################################

#m1.fit_rf(d_grouped, FEATURES, TARGET, shap=False)


###############################################################################
# Log Results 
###############################################################################


# Sent Score ~ NetWorth
"""
                                OLS Regression Results                                
==============================================================================
Dep. Variable:             sent_score   R-squared (uncentered):          0.020
Model:                            OLS   Adj. R-squared (uncentered):     0.018
Method:                 Least Squares   F-statistic:                     9.825
Date:                Sat, 10 Apr 2021   Prob (F-statistic):            0.00183
Time:                        09:48:49   Log-Likelihood:                -1490.4
No. Observations:                 479   AIC:                              2983.
Df Residuals:                     478   BIC:                              2987.
Df Model:                           1                                                  
Covariance Type:            nonrobust                                                  
==============================================================================
                      coef    std err          t      P>|t| [0.025      0.975]
------------------------------------------------------------------------------
AverageNetWorth  2.599e-08   8.29e-09      3.135      0.002 9.7e-09    4.23e-08
==============================================================================
Omnibus:                       24.687   Durbin-Watson:                   1.459
Prob(Omnibus):                  0.000   Jarque-Bera (JB):               71.223
Skew:                          -0.096   Prob(JB):                     3.42e-16
Kurtosis:                       4.879   Cond. No.                         1.00
==============================================================================
"""

# Sent Score ~ Log Networth
"""
               OLS Regression Results                                
==============================================================================
Dep. Variable:             sent_score   R-squared (uncentered):          0.362
Model:                            OLS   Adj. R-squared (uncentered):     0.360
Method:                 Least Squares   F-statistic:                     250.0
Date:                Sat, 10 Apr 2021   Prob (F-statistic):           6.15e-45
Time:                        09:50:06   Log-Likelihood:                -1271.3
No. Observations:                 442   AIC:                            2545.
Df Residuals:                     441   BIC:                            2549.
Df Model:                           1                                                  
Covariance Type:            nonrobust                                                  
==============================================================================
                      coef    std err          t      P>|t| [0.025      0.975]
-----------------------------------------------------------------------------
AverageNetWorth     0.2200      0.014     15.812      0.000  0.193       0.247
==============================================================================
Omnibus:                       24.854   Durbin-Watson:                   2.151
Prob(Omnibus):                  0.000   Jarque-Bera (JB):               75.698
Skew:                          -0.094   Prob(JB):                     3.65e-17
Kurtosis:                       5.019   Cond. No.                         1.00
==============================================================================

"""

# Sent Score - All Feautres
"""
                            OLS Regression Results                            
==============================================================================
Dep. Variable:             sent_score   R-squared:                       0.124
Model:                            OLS   Adj. R-squared:                 -0.009
Method:                 Least Squares   F-statistic:                    0.9319
Date:                Sat, 10 Apr 2021   Prob (F-statistic):              0.618
Time:                        09:57:28   Log-Likelihood:                -1241.3
No. Observations:                 442   AIC:                             2601.
Df Residuals:                     383   BIC:                             2842.
Df Model:                          58                                         
Covariance Type:            nonrobust                                         
===================================================================================
                      coef    std err          t      P>|t|      [0.025      0.975]
-----------------------------------------------------------------------------------
AverageNetWorth     0.0475      0.122      0.389      0.698      -0.193       0.288
chamber_H           1.0311      0.811      1.271      0.205      -0.564       2.627
chamber_S           1.3125      0.863      1.521      0.129      -0.385       3.010
state_AK           -1.9450      2.492     -0.780      0.436      -6.846       2.956
state_AL            0.0538      1.642      0.033      0.974      -3.174       3.281
state_AR            0.6843      1.940      0.353      0.725      -3.131       4.500
state_AS            6.4936      4.260      1.524      0.128      -1.883      14.870
state_AZ           -1.0404      1.458     -0.714      0.476      -3.907       1.826
state_CA           -0.3084      0.798     -0.387      0.699      -1.877       1.260
state_CO           -1.4194      1.769     -0.803      0.423      -4.897       2.058
state_CT            2.3590      2.162      1.091      0.276      -1.893       6.611
state_DC           -0.3136      4.281     -0.073      0.942      -8.732       8.104
state_DE            1.4478      3.048      0.475      0.635      -4.545       7.440
state_FL           -1.7348      0.991     -1.751      0.081      -3.683       0.213
state_GA           -0.1863      1.284     -0.145      0.885      -2.710       2.338
state_HI            1.3796      1.940      0.711      0.477      -2.434       5.193
state_IA           -1.0047      1.768     -0.568      0.570      -4.481       2.472
state_ID            9.5419      3.049      3.130      0.002       3.547      15.537
state_IL           -0.0245      1.123     -0.022      0.983      -2.233       2.184
state_IN            0.5245      1.536      0.342      0.733      -2.495       3.544
state_KS           -0.1901      2.159     -0.088      0.930      -4.436       4.055
state_KY           -1.8280      2.153     -0.849      0.396      -6.060       2.404
state_LA           -1.5005      1.928     -0.778      0.437      -5.292       2.291
state_MA           -1.6333      1.339     -1.220      0.223      -4.266       0.999
state_MD           -2.4819      1.546     -1.605      0.109      -5.522       0.558
state_ME           -0.2466      2.334     -0.106      0.916      -4.836       4.343
state_MI           -1.5702      1.056     -1.487      0.138      -3.646       0.505
state_MN            2.7011      1.455      1.857      0.064      -0.159       5.561
state_MO            0.5576      1.768      0.315      0.753      -2.918       4.033
state_MP           -0.1040      5.666     -0.018      0.985     -11.245      11.037
state_MS           -2.9792      3.018     -0.987      0.324      -8.914       2.956
state_MT            0.8990      1.772      0.507      0.612      -2.585       4.383
state_NC            0.0146      1.271      0.012      0.991      -2.485       2.514
state_ND            0.2331      1.930      0.121      0.904      -3.561       4.027
state_NE           -0.7366      1.643     -0.448      0.654      -3.967       2.494
state_NH            1.1198      2.163      0.518      0.605      -3.132       5.372
state_NJ           -1.7476      1.151     -1.518      0.130      -4.011       0.516
state_NM            1.1580      1.931      0.600      0.549      -2.638       4.955
state_NV           -0.5222      1.532     -0.341      0.733      -3.534       2.489
state_NY           -0.7967      1.008     -0.790      0.430      -2.778       1.185
state_OH            1.5802      1.145      1.380      0.169      -0.672       3.832
state_OK           -0.1207      1.775     -0.068      0.946      -3.611       3.369
state_OR           -2.1629      1.653     -1.309      0.191      -5.412       1.087
state_PA           -1.9338      1.064     -1.818      0.070      -4.025       0.157
state_RI           -0.3283      2.168     -0.151      0.880      -4.592       3.935
state_SC           -2.1741      1.767     -1.231      0.219      -5.648       1.300
state_SD            1.5276      2.476      0.617      0.538      -3.341       6.396
state_TN            0.1137      1.644      0.069      0.945      -3.118       3.346
state_TX           -1.7093      0.865     -1.976      0.049      -3.410      -0.008
state_UT           -0.8146      2.169     -0.376      0.707      -5.080       3.450
state_VA           -0.3894      1.234     -0.316      0.752      -2.815       2.036
state_VI            3.7578      4.281      0.878      0.381      -4.660      12.176
state_VT           -1.2713      3.502     -0.363      0.717      -8.157       5.614
state_WA            2.1129      1.384      1.526      0.128      -0.609       4.835
state_WI            0.5343      1.759      0.304      0.761      -2.925       3.993
state_WV           -0.1739      1.635     -0.106      0.915      -3.389       3.041
state_WY           -1.0583      3.043     -0.348      0.728      -7.041       4.924
gender_F            0.9845      0.884      1.114      0.266      -0.754       2.723
gender_M            1.3591      0.806      1.687      0.092      -0.225       2.943
party_D             0.9676      1.129      0.857      0.392      -1.253       3.188
party_I             1.1362      2.901      0.392      0.696      -4.567       6.840
party_R             0.2398      1.164      0.206      0.837      -2.049       2.529
==============================================================================
Omnibus:                       24.193   Durbin-Watson:                   2.113
Prob(Omnibus):                  0.000   Jarque-Bera (JB):               71.822
Skew:                          -0.097   Prob(JB):                     2.54e-16
Kurtosis:                       4.965   Cond. No.                     1.37e+17
==============================================================================

"""


# Sent Score - Lasso
"""
 OLS Regression Results                            
==============================================================================
Dep. Variable:             sent_score   R-squared:                       0.022
Model:                            OLS   Adj. R-squared:                  0.014
Method:                 Least Squares   F-statistic:                     2.015
Date:                Sat, 10 Apr 2021   Prob (F-statistic):             0.0918
Time:                        19:27:34   Log-Likelihood:                -1002.5
No. Observations:                 359   AIC:                             2015.
Df Residuals:                     355   BIC:                             2034.
Df Model:                           4                                         
Covariance Type:            nonrobust                                         
====================================================================================
                       coef    std err          t      P>|t|      [0.025      0.975]
------------------------------------------------------------------------------------
AverageNetWorth      0.2043      0.025      8.186      0.000       0.155       0.253
chamber_H            0.6050      0.417      1.452      0.147      -0.214       1.424
chamber_S                 0          0        nan        nan           0           0
state_AK                  0          0        nan        nan           0           0
state_AL                  0          0        nan        nan           0           0
state_AR                  0          0        nan        nan           0           0
state_AS                  0          0        nan        nan           0           0
state_AZ                  0          0        nan        nan           0           0
state_CA                  0          0        nan        nan           0           0
state_CO                  0          0        nan        nan           0           0
state_CT                  0          0        nan        nan           0           0
state_DC                  0          0        nan        nan           0           0
state_DE                  0          0        nan        nan           0           0
state_FL                  0          0        nan        nan           0           0
state_GA                  0          0        nan        nan           0           0
state_HI                  0          0        nan        nan           0           0
state_IA                  0          0        nan        nan           0           0
state_ID                  0          0        nan        nan           0           0
state_IL                  0          0        nan        nan           0           0
state_IN                  0          0        nan        nan           0           0
state_KS                  0          0        nan        nan           0           0
state_KY                  0          0        nan        nan           0           0
state_LA                  0          0        nan        nan           0           0
state_MA                  0          0        nan        nan           0           0
state_MD                  0          0        nan        nan           0           0
state_ME                  0          0        nan        nan           0           0
state_MI                  0          0        nan        nan           0           0
state_MN                  0          0        nan        nan           0           0
state_MO                  0          0        nan        nan           0           0
state_MP                  0          0        nan        nan           0           0
state_MS                  0          0        nan        nan           0           0
state_MT                  0          0        nan        nan           0           0
state_NC                  0          0        nan        nan           0           0
state_ND                  0          0        nan        nan           0           0
state_NE                  0          0        nan        nan           0           0
state_NH                  0          0        nan        nan           0           0
state_NJ                  0          0        nan        nan           0           0
state_NM                  0          0        nan        nan           0           0
state_NV                  0          0        nan        nan           0           0
state_NY                  0          0        nan        nan           0           0
state_OH                  0          0        nan        nan           0           0
state_OK                  0          0        nan        nan           0           0
state_OR                  0          0        nan        nan           0           0
state_PA                  0          0        nan        nan           0           0
state_RI                  0          0        nan        nan           0           0
state_SC                  0          0        nan        nan           0           0
state_SD                  0          0        nan        nan           0           0
state_TN                  0          0        nan        nan           0           0
state_TX                  0          0        nan        nan           0           0
state_UT                  0          0        nan        nan           0           0
state_VA                  0          0        nan        nan           0           0
state_VI                  0          0        nan        nan           0           0
state_VT                  0          0        nan        nan           0           0
state_WA                  0          0        nan        nan           0           0
state_WI                  0          0        nan        nan           0           0
state_WV                  0          0        nan        nan           0           0
state_WY                  0          0        nan        nan           0           0
gender_F                  0          0        nan        nan           0           0
gender_M                  0          0        nan        nan           0           0
party_D                   0          0        nan        nan           0           0
party_I                   0          0        nan        nan           0           0
party_R                   0          0        nan        nan           0           0
keyword_overtime     0.4883      0.471      1.037      0.301      -0.438       1.415
keyword_wages             0          0        nan        nan           0           0
keyword_workweek    -1.0685      0.562     -1.901      0.058      -2.174       0.037
==============================================================================
Omnibus:                       45.195   Durbin-Watson:                   1.968
Prob(Omnibus):                  0.000   Jarque-Bera (JB):              225.214
Skew:                           0.353   Prob(JB):                     1.25e-49
Kurtosis:                       6.816   Cond. No.                          nan
==============================================================================


"""

# Sent Score - Top Features
"""
Features:   'AverageNetWorth', 'chamber_H', 'chamber_S', 'party_D',
            'party_R'
Lasso:      False

                      OLS Regression Results                            
==============================================================================
Dep. Variable:             sent_score   R-squared:                       0.012
Model:                            OLS   Adj. R-squared:                  0.003
Method:                 Least Squares   F-statistic:                     1.343
Date:                Sat, 10 Apr 2021   Prob (F-statistic):              0.253
Time:                        10:27:11   Log-Likelihood:                -1267.8
No. Observations:                 442   AIC:                             2546.
Df Residuals:                     437   BIC:                             2566.
Df Model:                           4                                         
Covariance Type:            nonrobust                                         
===================================================================================
                      coef    std err          t      P>|t|      [0.025      0.975]
-----------------------------------------------------------------------------------
AverageNetWorth     0.0570      0.111      0.512      0.609      -0.162       0.276
chamber_H           2.6243      2.904      0.904      0.367      -3.082       8.331
chamber_S           3.2520      2.928      1.111      0.267      -2.503       9.007
party_D            -0.0188      2.500     -0.008      0.994      -4.932       4.895
party_R            -0.7320      2.502     -0.293      0.770      -5.649       4.185
==============================================================================
Omnibus:                       24.015   Durbin-Watson:                   2.112
Prob(Omnibus):                  0.000   Jarque-Bera (JB):               73.254
Skew:                          -0.049   Prob(JB):                     1.24e-16
Kurtosis:                       4.992   Cond. No.                         374.
==============================================================================
"""

# Sent Score - Top Features - Lasso

"""
                            OLS Regression Results                            
==============================================================================
Dep. Variable:             sent_score   R-squared:                       0.009
Model:                            OLS   Adj. R-squared:                  0.004
Method:                 Least Squares   F-statistic:                     1.308
Date:                Sat, 10 Apr 2021   Prob (F-statistic):              0.271
Time:                        10:31:33   Log-Likelihood:                -1268.5
No. Observations:                 442   AIC:                             2545.
Df Residuals:                     439   BIC:                             2561.
Df Model:                           3                                         
Covariance Type:            nonrobust                                         
===================================================================================
                      coef    std err          t      P>|t|      [0.025      0.975]
-----------------------------------------------------------------------------------
AverageNetWorth     0.1830      0.021      8.749      0.000       0.142       0.224
chamber_H                0          0        nan        nan           0           0
chamber_S           0.5992      0.468      1.280      0.201      -0.321       1.519
party_D             0.7888      0.401      1.965      0.050      -0.000       1.578
party_R                  0          0        nan        nan           0           0
==============================================================================
Omnibus:                       24.745   Durbin-Watson:                   2.117
Prob(Omnibus):                  0.000   Jarque-Bera (JB):               76.158
Skew:                          -0.076   Prob(JB):                     2.90e-17
Kurtosis:                       5.028   Cond. No.                         374.
==============================================================================

"""


































































