# AI-Generated Correspondences: The Robotic Workhorse

This folder contains the code for generating individual correspondence tables. It includes the code files, tables, a batch process, and an additional folder to store outputs.

## Underlying Tables

The correspondence is built on three key elements:

1. **ISIC 4 to ISIC 3.1 Correspondence Table**: This table is available from the [UN Website](https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC4_ISIC31/ISIC4_ISIC31.txt) (file `ISIC4_ISIC31.csv`).

2. **ISIC Revision 4 Codes**: This file (`ISIC_4_4digit_long.xlsx`) provides descriptions of each ISIC 4 code, sourced from Part Three of the [ISIC 4 Manual](https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_4_publication_English.pdf).

3. **ISIC Revision 3.1 Codes**: This file (`ISIC_31_4digit_long.xlsx`) contains descriptions of ISIC 3.1 codes, taken from Part Three of the [ISIC 3.1 Manual](https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/Isic31_English.pdf).

## Python Code Files

There are three Python code files used to create the correspondence tables:

- **`config.py`**: This file should contain your Google API key. It serves as an example but does not include a key; you must generate your own and enter it into your local `config.py`.

- **`Tool_functions.py`**: Defines the functions used by the main script.

- **`main_script.py`**: Executes the program by calling the necessary modules and functions and saving the output.

To run the main script, navigate to the folder containing the files in the command prompt (Windows environment). For guidance on navigating directories, refer to [this tutorial](https://www.geeksforgeeks.org/change-directories-in-command-prompt/). Once in the correct directory, enter:

```
python main_script.py ISIC4_ISIC31.csv ISIC_31_4digit_long.xlsx ISIC_4_4digit_long.xlsx Runs/output.xlsx
```

Here, python tells the environment to run the Python interpreter. Ensure Python is in your PATH; you can [learn more about this here](https://projects.raspberrypi.org/en/projects/using-pip-on-windows/4). The arguments after main_script.py specify the input files and the output path. Note that the "Runs" folder is specified for output storage; this folder will not be created automatically.

## Batch process

As mentioned in the introductory README, the AI-generated correspondence tables may occasionally produce errors or omissions. To address this, the main script was run 100 times. Repeatedly entering the command manually would be inefficient, so a batch process can automate this. For details on creating a batch file, [see this guide](https://www.howtogeek.com/263177/how-to-write-a-batch-script-on-windows/).

For most users, placing the batch file (`loop_main_script.bat`) in the same folder as the other files and ensuring that `config.py` contains a valid API key will allow you to simply double-click the batch file to execute the process.