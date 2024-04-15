"""Script to define the structure of the GLD harmonization scripts."""
import os

# delete .md file if it exists
if os.path.exists('docs/script_structure.md'):
    os.remove('docs/script_structure.md')

# create the .md file to populate
f = open('docs/script_structure.md', 'w+')

# define the first line
f.write('# GLD Harmonization Script Structure\n\n')

# write some introductory text
f.write('This document describes the structure of the GLD harmonization scripts. The scripts are organized by country, survey year, entry, program, and file. The below structure outlines the structure of the scripts on GitHub organized in within the `GLD` folder. The file structure is as follows:\n\n')

# parse the GLD/ directory
for ctry in os.listdir('GLD/'):
    # write line for the country
    f.write('## ' + ctry + '\n\n')
    # parse the country directory
    for survey in os.listdir('GLD/' + ctry):
        # only do if survey starts with country code
        if survey[:len(ctry)] == ctry:
            # if the survey is a .do file, determine URL and write hyperlink
            if survey[-3:] == '.do':
                # determine URL
                url = f'https://github.com/worldbank/gld/blob/main/GLD/{ctry}/{survey}'
                # write hyperlink
                f.write(f'* [{survey}]({url})\n')
            else:
                # write line for the survey year
                f.write('### ' + survey + '\n\n')
                # if the survey is a directory, parse it
                if os.path.isdir('GLD/' + ctry + '/' + survey):
                    # parse the survey directory
                    for entry in os.listdir('GLD/' + ctry + '/' + survey):
                        # if the entry is a .do file, determine URL and write hyperlink
                        if entry[-3:] == '.do':
                            # determine URL
                            url = f'https://github.com/worldbank/gld/blob/main/GLD/{ctry}/{survey}/{entry}'
                            # write hyperlink
                            f.write(f'* [{entry}]({url})\n')
                        else:
                            # write line for the entry
                            f.write('* ' + entry + '\n')
                            # if the entry is a directory, parse it
                            if os.path.isdir('GLD/' + ctry + '/' + survey + '/' + entry):
                                # parse the entry directory
                                for program in os.listdir('GLD/' + ctry + '/' + survey + '/' + entry):
                                    # if the program is a .do file, determine URL and write hyperlink
                                    if program[-3:] == '.do':
                                        # determine URL
                                        url = f'https://github.com/worldbank/gld/blob/main/GLD/{ctry}/{survey}/{entry}/{program}'
                                        # write hyperlink
                                        f.write('  * [' + program + '](' + url + ')\n')
                                    else:
                                        # write line for the program
                                        f.write('  * ' + program + '\n')
                                        # if the program is a directory, parse it
                                        if os.path.isdir('GLD/' + ctry + '/' + survey + '/' + entry + '/' + program):
                                            # parse the program directory
                                            for file in os.listdir('GLD/' + ctry + '/' + survey + '/' + entry + '/' + program):
                                                # if the file is a .do file, determine URL and write hyperlink
                                                if file[-3:] == '.do':
                                                    # determine URL
                                                    url = f'https://github.com/worldbank/gld/blob/main/GLD/{ctry}/{survey}/{entry}/{program}/{file}'
                                                    # write hyperlink
                                                    f.write('    * [' + file + '](' + url + ')\n')
                                                else:
                                                    # write line for the file
                                                    f.write('    * ' + file + '\n')
