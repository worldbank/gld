# -*- coding: utf-8 -*-
"""
Created on Fri Apr 26 10:25:47 2024

@author: Caleb Jensen
"""
## Load in required packages
import pandas as pd
import numpy as np
from Tool_functions import make_prompt
from Tool_functions import step_one_cleaning
from Tool_functions import step_two_cleaning
from Tool_functions import remove_asterisks
from Tool_functions import tool_loop
from config import GOOGLE_API_KEY
import sys


# Access input and output file paths from sys.argv
corr_table = sys.argv[1]
ISIC_old = sys.argv[2]
ISIC_new = sys.argv[3]

## load in all the data sets needed from command line arguments
ISIC_new = pd.read_excel(ISIC_new, dtype = {"Code": str, "Description": str})
ISIC_old = pd.read_excel(ISIC_old, dtype = {"Code": str, "Description": str})
corr_table = pd.read_csv(corr_table, dtype={"ISIC4code": str, "partialISIC4": str, "ISIC31code": str, "partialISIC31": str})

## Ensure there are no NAs from reading in from excel
corr_table.fillna("", inplace = True)
ISIC_old.fillna("", inplace = True)
ISIC_new.fillna("", inplace = True)

## Get codes array to be looped through in main loop
codes = np.array(ISIC_new["Code"])

## Check if model is specified, if not we will go with the default and run the tool loop. 
if len(sys.argv) > 5:
    mod = sys.argv[4]
    out_file = sys.argv[5]
    correspondence_table = tool_loop(codes, corr_table = corr_table, ISIC_old=ISIC_old, ISIC_new=ISIC_new, key = GOOGLE_API_KEY, mod = mod)
    
## Tool loop if we are using the default model 
else: 
    out_file = sys.argv[4]
    correspondence_table = tool_loop(codes, corr_table=corr_table, ISIC_old=ISIC_old, ISIC_new=ISIC_new, key = GOOGLE_API_KEY, mod = 'gemini-pro')

## Read correspondence table out to excel with our desired output name 
correspondence_table.to_excel(out_file, index= False)