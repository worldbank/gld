#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 24 20:46:30 2023

@author: angelosantos
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 23 11:51:30 2023

@author: angelosantos
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 23 08:21:38 2023

@author: angelosantos
"""
import os 

def update_GLD(var_name_I2D2, tag_GLD, I2D2, GLD):
    # Determine the end string
    end_str_I2D2 = f"label var {var_name_I2D2}"
    # Find the start index for the block in the I2D2 file
    start_I2D2 = next((i for i, line in enumerate(I2D2) if 'gen' in line.replace('=', ' ').split() and var_name_I2D2 in line.replace('=', ' ').split()), None)

    # If start_I2D2 is None, the line was not found in the file
    if start_I2D2 is None:
        print(f"Could not find start line for {var_name_I2D2}")
        return GLD
    
    # Find the end index for the block in the I2D2 file
    end_I2D2 = next((i for i, line in enumerate(I2D2) if end_str_I2D2 in line), None)

    # If end_I2D2 is None, the line was not found in the file
    if end_I2D2 is None:
        print(f"Could not find end line for {var_name_I2D2}")
        return GLD

    # Extract the code block from the I2D2 file
    block_I2D2 = I2D2[start_I2D2:end_I2D2]

    # Replace the variable name in the code block
    block_I2D2 = [line.replace(var_name_I2D2, tag_GLD) for line in block_I2D2]

    print(tag_GLD)
     # Find the start and end indices for the tag in the GLD file
    #start_GLD = next((i for i, line in enumerate(GLD) if 'gen' in line.split() and tag_GLD in line.split()), None)
    start_GLD = GLD.index(f'*<_{tag_GLD}_>\n')+ 1
    # Find end of current tag section
    try:
        end_GLD_current = next(i for i, line in enumerate(GLD[start_GLD:], start=start_GLD) if line.strip() == f'*</_{tag_GLD}_>')
    except StopIteration:
        print(f"Could not find end line for {tag_GLD}")
        return GLD
  
    # Get labelvar line
    labelvar_line = next((line for line in GLD[start_GLD:end_GLD_current] if 'label var' in line), None)
    
    # Get label values line
    labelvalues_line = next((line for line in GLD[start_GLD:end_GLD_current] if 'label values' in line), None)
    
    # Get label define line
    labeldefine_line = next((line for line in GLD[start_GLD:end_GLD_current] if 'la de' in line or 'label define' in line), None)
    
    # Combine lines into new block
    new_block = [line for line in [labelvar_line, labelvalues_line, labeldefine_line] if line is not None]

    end_GLD = GLD.index(f'*</_{tag_GLD}_>\n')  # Update this line to find the correct end index

    # Replace the code block in the GLD file with the one from the I2D2 file
    updated_GLD = GLD[:start_GLD] + block_I2D2 + new_block + GLD[end_GLD:]
    return updated_GLD


# Define variable pairs
var_pairs = [
    ('ccode', 'countrycode'),
    ('sample', 'survname'),
    ('year', 'year'),
    ('intv_year', 'int_year'),
    ('month', 'int_month'),
    ('idh', 'hhid'),
    ('idp', 'pid'),
    ('wgt', 'weight'),
    ('psu', 'psu'),
    ('urb', 'urban'),
    ('reg01', 'subnatid1'),
    ('reg02', 'subnatid2'),
    ('strata', 'strata'),
    ('hhsize', 'hsize'),
    ('age', 'age'),
    ('gender', 'male'),
    ('head', 'relationharm'),
    ('marital', 'marital'),
    ('ed_mod_age', 'ed_mod_age'),
    ('atschool', 'school'),
    ('literacy', 'literacy'),
    ('educy', 'educy'),
    ('edulevel1', 'educat7'),
    ('edulevel2', 'educat5'),
    ('edulevel3', 'educat4'),
    ('lb_mod_age', 'minlaborage'),
    ('lstatus', 'lstatus'),
    ('nlfreason', 'nlfreason'),
    ('unempldur_l', 'unempldur_l'),
    ('unempldur_u', 'unempldur_u'),
    ('empstat', 'empstat'),
    ('ocusec', 'ocusec'),
    ('industry_orig', 'industry_orig'),
    ('industry', 'industrycat10'),
    ('industry1', 'industrycat4'),
    ('occup_orig', 'occup_orig'),
    ('occup', 'occup'),
    ('wage', 'wage_no_compen'),
    ('unitwage', 'unitwage'),
    ('whours', 'whours'),
    ('contract', 'contract'),
    ('healthins', 'healthins'),
    ('socialsec', 'socialsec'),
    ('union', 'union'),
    ('firmsize_l', 'firmsize_l'),
    ('firmsize_u', 'firmsize_u'),
    ('empstat_2', 'empstat_2'),
    ('industry_orig_2', 'industry_orig_2'),
    ('industry_2', 'industrycat10_2'),
    ('industry1_2', 'industrycat4_2'),
    ('occup_2', 'occup_2'),
    ('wage_2', 'wage_no_compen_2'),
    ('unitwage_2', 'unitwage_2'),
    ('lstatus_year', 'lstatus_year'),
    ('empstat_year', 'empstat_year'),
    ('empstat_2_year', 'empstat_2_year'),
    ('njobs', 'njobs')
]


# Define the file paths
I2D2_path = '/Users/angelosantos/Downloads/MNG_2021_I2D2_LFS.do'
GLD_path = '/Users/angelosantos/Downloads/GLD_Harmonization_Template.do'
updated_GLD_path = '/Users/angelosantos/Downloads/updated_GLD.do'

# Extract details from I2D2 file name
I2D2_name = os.path.basename(I2D2_path)
I2D2_name = os.path.basename(I2D2_path)
I2D2_name = I2D2_name.split(".do")[0]  # remove .do extension
components = I2D2_name.split("_")
country = components[-4]
year = components[-3]
survey = components[-1]



# Define new GLD path details
gld_path_details = {
    'server': "Y:/GLD-Harmonization/510859_AS",
    'country': country,
    'year': year,
    'survey': survey,
    'vermast': "V01",
    'veralt': "V01",
}


# Read the I2D2 and GLD files
country, _, year, survey = I2D2_name.split("_")

with open(GLD_path, 'r') as file:
    GLD = file.readlines()

# Loop through GLD and replace path details
for i, line in enumerate(GLD):
    for detail in gld_path_details.keys():
        if f'local {detail}' in line:
            GLD[i] = f'local {detail}  "{gld_path_details[detail]}"\n'

with open(I2D2_path, 'r') as file:
    I2D2 = file.readlines()


# Loop through variable pairs and apply function
for var_name_I2D2, tag_GLD in var_pairs:
    GLD = update_GLD(var_name_I2D2, tag_GLD, I2D2, GLD)

# Write the updated GLD file
with open(updated_GLD_path, 'w') as file:
    file.writelines(GLD)
