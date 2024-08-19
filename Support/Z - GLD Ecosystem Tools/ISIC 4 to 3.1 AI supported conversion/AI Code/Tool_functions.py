# -*- coding: utf-8 -*-
"""
Created on Fri Apr 19 10:16:32 2024

@author: Caleb Jensen
"""

def step_one_cleaning(prompt, key, mod = 'gemini-pro'):  
    from io import StringIO
    import csv
    import pathlib
    import textwrap
    import google.generativeai as genai
    import numpy as np
    import pandas as pd
    ## Need to change this line to get your own API key if possible
    #from config import GOOGLE_API_KEY
    
    #setting the model and API key
    genai.configure(api_key=key)
    model = genai.GenerativeModel(mod)
    
    # Input string prompt to the google model 
    response = model.generate_content(prompt)
    
    # Define the data string
    data_string = response.text
    
    # Create a StringIO object to mimic a file-like object
    data_io = StringIO(data_string)
    
    # Create first df to be cleaned and returned 
    df = pd.read_csv(data_io, delimiter="|")
    
    # Drop empty top row 
    df = df.iloc[1:].reset_index(drop = True)
    
    # Drop empty columns
    names = df.columns
    for name in names: 
        if "unnamed" in name.lower(): 
            df = df.drop(columns = [name])
    return df

## function looks for asterisks in a string and removes them, this is useful for cleaning data below 
def remove_asterisks(text):
    import re
    pattern = r"\*"
    return re.sub(pattern, "", text)

## function looks for non digit characters in a string and removes them, this is useful for cleaning data below
def strip_non_digits(text):
    import re
    return re.sub(r"[^\d.]", "", text)

## Takes a prompt, code, key, and mod and returns a dataframe with the code pairs and their corresponding parbabilities 
def step_two_cleaning(prompt, code, key, mod = 'gemini-pro'):
    import numpy as np
    import pandas as pd
    from collections import Counter
    import time
    status = "broken"
    ## While loop try step_one_cleaning(), only continues if the first step executes properly 
    while status == "broken":
        df = step_one_cleaning(prompt, key, mod)
        #gets column names to be used below
        names = df.columns
        #checks for common errors when data is returned from AI
        if len(names) == 3 and len(df) != 0 and type(df[names[2]][0]) == str:
            count = Counter(df[names[2]][0])
            if count["."] == 1:
                df[names[2]] = df[names[2]].astype(str)
                props = np.array(df[names[2]])
                # checking for common error of 1 being **1** in data frame, python has trouble with this 
                for i in range(len(props)): 
                    if df[names[2]][i] == "**1**":
                        df[names[2]][i] = "1.00"
                        ## removing any n/a or nan strings from data frame, these can also cause errors 
                    elif type(df[names[2]][i]) == str:
                        if 'n/a' in df[names[2]][i].lower() or 'nan' in df[names[2]][i].lower():
                            df[names[2]][i] = "0"
                ## if all conditions met, we move on to further cleaning 
                status = "clean"
        if status == "clean":
            names = df.columns
            names_2 = ["version_4", "version_3.1", "Proportion of Jobs"]
            df.columns = names_2
            # Replace non-numeric characters with an empty string and replace any extraneous characters in the dataframe for the version 4 codes
            pattern = r'\D'  # Matches any non-digit character
            df["version_4"] = df["version_4"].astype(str)
            df["version_4"] = df["version_4"].str.replace(pattern, '') 
            df["version_4"] = df["version_4"].apply(remove_asterisks)
            df["version_4"] = df["version_4"].str.replace(' ', '')
            ## do the  same as above for version 3.1 code 
            df["version_3.1"] = df["version_3.1"].astype(str)
            df["version_3.1"] = df["version_3.1"].str.replace(pattern, '')
            df["version_3.1"] = df["version_3.1"].apply(remove_asterisks)
            df["version_3.1"] = df["version_3.1"].str.replace(' ', '')
            ## removing extraneous characters from the probability column 
            if type(df["Proportion of Jobs"].iloc[0]) == str:
                df["Proportion of Jobs"] = df["Proportion of Jobs"].apply(remove_asterisks)

        #Checking if full code is present, if not, loop will be forced to restart 
            if len(df["version_3.1"].iloc[0]) != 4:
                status = "broken"
            if len(df["version_4"].iloc[0]) != 4:
                df["version_4"] = code
  
    # Making proportion column a float between 0 and 1
    if type(df["Proportion of Jobs"][0]) == str:
        ## remove any non digit characters 
        df["Proportion of Jobs"] = df["Proportion of Jobs"].apply(strip_non_digits)
        ## strip off any blank spaces 
        df["Proportion of Jobs"] = df["Proportion of Jobs"].str.strip()
        ## reomove percent signs, sometimes these are problematic 
        df["Proportion of Jobs"] = df["Proportion of Jobs"].str.replace("%", "")
        ## remove < signs, these can be issues as well 
        df["Proportion of Jobs"] = df["Proportion of Jobs"].str.replace("<", "")
        ## make all as type float 
        df["Proportion of Jobs"] = df["Proportion of Jobs"].astype(float)
        ## If the proportions are greater than 1, scale all down to be between 0 and 1 
    if df["Proportion of Jobs"][0] > 1:
        df["Proportion of Jobs"] = df["Proportion of Jobs"]/100 
    
    ## scale the data frame
    df = df.reset_index(drop = True)
    ## if the sum of the proportions is greater than 1 we scale them all down equally so that they all sum to 1
    if df["Proportion of Jobs"].sum() > 1:
        total = df["Proportion of Jobs"].sum()
        for i in range(len(df["Proportion of Jobs"])):
            df["Proportion of Jobs"][i] = df["Proportion of Jobs"][i]/total
    ## returns dataframe with code pairs and correspondence probability 
    return df


## Creating a usable prompt to query an AI API with
def make_prompt(digits, four_code, corr_table, ISIC_old, ISIC_new):
    num_codes = corr_table["ISIC4code"].value_counts()
    prompt = "A " + digits + " digit code " + four_code + " which is (" + str(ISIC_new[ISIC_new["Code"] == four_code]["Description"].iloc[0]) + ") in ISIC version 4 is comprised of " + str(num_codes[four_code]) + " four digit codes in ISICs version 3.1, "
    codes_31 = corr_table[corr_table["ISIC4code"] == four_code]
    ## Code to go through each corresponding code and add it and its large description to the prompt
    for code in codes_31["ISIC31code"].unique(): 
        ## start by just adding the code and its standard description from the ISIC code data frame, we will repeat this process over every code
        prompt = prompt + code + " which is (" + ISIC_old[ISIC_old['Code'] == code]['Description'].iloc[0] + "), "
    ## Give prompt 2 different endings, both with main question, for if there are many correspondences, which is rare, or if there is only a few, which is much more frequent. 
    if num_codes[four_code] > 10:
        prompt = prompt + " What is your best estimate of the proportion of jobs now coded in " + four_code + " that were in each of the previous codes in version 3.1? The proportions can be less than .05 and many probably are less .05. Can you give me your best guesses in a table with 3 columns, first the three digit code, " + four_code + " then the four didgit codes, then the proportions?"
    else: 
        prompt = prompt + " What is your best estimate of the proportion of jobs now coded in " + four_code + " that were in each of the previous codes in version 3.1? If there is only 1 version 3.1 code, it is automatically 1. Can you give me your best guesses in a table with 3 columns, first the version 4 code, " + four_code + " then the version 3.1 codes, then the proportions?"
    return prompt

## Function is the main loop to generate a new correspondence table, takes:
    ## codes --> list of new ISIC codes 
    ## corr_table --> df, corresponds the old and new ISIC versions 
    ## ISIC_old --> holds the old ISIC codes with their corresponding descriptions 
    ## ISIC_new --> holds the new ISIC codes with their corresponding descriptions
    ## key --> string, API key for the model you are using 
    ## mod --> string, defines model to be used for prediction 
def tool_loop(codes, corr_table, ISIC_old, ISIC_new, key, mod = 'gemini-pro'):
    import pandas as pd
    import time
    # initialize big dataframe to hold correspondence table, after each code is run the small df is appended to this large one
    df_big = pd.DataFrame({'version_4': [], 'version_3.1': [], "Proportion of Jobs": []})
    # start of main loop, goes through each code in the New ISIC codes 
    for four_code in codes:
        ## Checks if there is more than 1 instance of the code in the corr_table, if not, then immediatly assign a value of 1 to the correspondence proportion 
        if corr_table["ISIC4code"].value_counts()[four_code] == 1:
            code_31 = corr_table[corr_table["ISIC4code"] == four_code]
            v_3 = code_31["ISIC31code"].iloc[0]
            data = {"version_4": [four_code], "version_3.1": [v_3], "Proportion of Jobs": [1]}
            df_2 = pd.DataFrame(data, [len(df_big)])
            df_big = pd.concat([df_big, df_2])
            df_big = df_big[df_big.notna().all(axis=1)]
            df_big = df_big.reset_index(drop = True)
        ## If there is more than 1 instance of the code, then use the AI model to generate new codes
        ## As rarely there can be issues with the model output, we use try to make sure execution of the loop is not prematurely stopped 
        else:
            max_attempts = 10
            for i in range(1+max_attempts):
                try:
                    prompt = make_prompt("four", four_code, corr_table, ISIC_old = ISIC_old, ISIC_new = ISIC_new)
                    df_2 = step_two_cleaning(prompt, four_code, key, mod)
                    break
                except Exception as e:
                    if i == max_attempts:
                        return(print("it broke", e))
            ## Add the new correspondence probability to the correspondence table dataframe
            df_big = pd.concat([df_big, df_2])
            df_big = df_big[df_big.notna().all(axis=1)]
            df_big = df_big.reset_index(drop = True)
            ## Finally, we put in several seconds of sleep every 5 iterations of the loop to ensure we do over-query the API
            if i % 5 == 0:
                time.sleep(3)
        print(four_code)
        ## Returns correspondence dataframe
    return df_big