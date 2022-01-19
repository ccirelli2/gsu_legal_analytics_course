"""                                                                             
Description: Functions to load open secrets bulk data files                        
                                                                                
"""                                                                             
################################################################################
# Load Libraries                                                                
################################################################################
import logging                                                                  
import pandas as pd                                                             
import os                                                                       
              




################################################################################
# Functions                                                                
################################################################################



def read_unformatted_csv_file(dir_data, filename, colnames, sep, 
        sample, nrows):                       
    if sample:
        data=pd.read_csv(os.path.join(dir_data, filename),
                encoding='cp1252', sep=sep,                                         
                names=colnames, nrows=nrows)
    else:
        data=pd.read_csv(os.path.join(dir_data, filename),
                encoding='cp1252', sep=sep)                                         

    return data                



def clean_cols(df, write2file, dir_output, filename):
    """
    Function to clean columns of unecessary punctuation

    Args:
        df:
        write2file:
        dir_output:
        filename:

    Returns:

    """
    ###########################################################################
    # Iterate Each Column
    ###########################################################################
    for col in df.columns.tolist():
        # Create Result Object
        clean_col=[]
        # Object Values For Column
        dirty_col=df[col].tolist()
        #######################################################################
        # Iterate Each Value
        #######################################################################
        for val in dirty_col:
            # Use Lambda Statement to remove vertical bar
            if isinstance(val, str):
                clean_col.append(''.join(list(map(
                    lambda x: x if '|' not in x else '', val))))
            else:
                clean_col.append(None)
        #######################################################################
        # Replace Column In Original Dataframe
        #######################################################################
        df[col]=clean_col

    #######################################################################
    # Write results to file
    #######################################################################
    if write2file:
        df.to_csv(os.path.join(dir_output, filename))

    # Return dataframe
    return df
