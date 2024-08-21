# GLD Wage Information Script README

## What is the issue?


## How is it addressed?


## How to install the function?

```
net install GLD-latest-file-check, replace from("https://raw.githubusercontent.com/worldbank/gld/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/GLD%20files%20update%20check")
```

## How to run the code?


## Overview

This Stata script is designed to add wage information (both hourly and monthly) to Global Labor Database (GLD) surveys. The script supports two recall periods—weekly and yearly—and allows customization based on specific worker groups and desired timeframes. The script ensures that sufficient wage data is present before calculations are performed.

## Key Features

- Customizable Worker Groups: The script allows you to focus on either wage workers (waged) or all workers (all).
- Flexible Timeframes: Wage calculations can be done over a weekly or yearly recall period, or both.
- Threshold-Based Processing: The script only proceeds if a user-defined percentage of required data is present.
- Automatic Handling of Different Pay Periods: The script converts various pay frequencies (e.g., weekly, monthly, annual) into consistent hourly and monthly wages.

## Syntax

```
gld_add_wage [, WORKer(string) TIME(string) THREshold(real 75) PPP]
```

## Options

- WORKer(string): Defines the worker group to be used. Accepted values:
  - **"a"** or **"all"**: All workers
  - **"w"** or **"waged"**: Only wage workers

- TIME(string): Defines the recall period. Accepted values:
  - **"w"** or **"week"**: Weekly
  - **"y"** or **"year"**: Yearly
  - **"b"** or **"both"**: Both weekly and yearly

- THREshold(real): The percentage threshold (0-100) of cases required to have complete wage data before the script proceeds. Default is 75.

- PPP: Optional. This option will include Purchasing Power Parity (PPP) adjustments (feature not yet implemented).

## How the Code Works

### Step 1: Initial Setup and Input Validation

- The script begins by setting up the environment and parsing user inputs.
- It checks the validity of the options provided by the user, ensuring correct worker groups, timeframes, and threshold values are specified.

### Step 2: Variable Availability Check

- The script checks for the availability of essential variables (e.g., employment status, wage information, working hours) for the chosen recall period.

### Step 3: Hourly Wage Calculation (Weekly Recall Period)

- If the selected recall period includes the weekly option, the script calculates the hourly wage for the specified worker group.
- Different pay frequencies (daily, weekly, monthly, etc.) are converted into consistent hourly rates.

### Step 4: Monthly Wage Calculation (Weekly Recall Period)

- The script calculates monthly wages based on the weekly recall period using consistent conversion factors for different pay frequencies.

### Step 5: Hourly Wage Calculation (Yearly Recall Period)

- If the selected recall period includes the yearly option, the script performs similar calculations as in Step 3, but for a yearly recall period.

## Threshold Evaluation

- The script evaluates whether sufficient data (based on the specified threshold) is available for processing. If not, it exits with an error message.

## Error Handling

The script includes comprehensive error checking:

- If an invalid option is provided, the script notifies the user and exits.
- If key variables are missing, the script exits with a clear error message.
- If insufficient cases meet the threshold requirement, the script exits without performing calculations.

## Usage Example

```
gld_wage_info, WORKer("all") TIME("both") THREshold(80)
```

In this example, the script calculates wage information for all workers across both weekly and yearly recall periods, but only if 80% of the necessary data is available.

Notes:

- The script assumes that key variables (like empstat, wage_no_compen, unitwage, and whours) are present in the dataset.
- The script is optimized for GLD surveys but can be adapted for similar datasets with minimal changes.
- Future updates may include additional features like PPP adjustments.
