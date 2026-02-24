# GLD Survey Update Pipeline

An R-based pipeline for applying programmatic updates to GLD harmonization `.do` files. Given a spreadsheet of Stata code changes (see example `pak_tza_updates.xlsx`), the pipeline validates each survey, creates a new versioned GLD folder, applies the updates, and optionally runs Stata to produce the updated harmonized output.

---

## Overview

When a variable's harmonization code needs to be corrected or revised across one or more surveys, this pipeline automates the full process:

1. Reads a structured input file (CSV or Excel) listing the Stata code changes
2. Validates each survey — checking folder structure, `.do` file presence, variable markers, and whether the update actually differs from the current code
3. Creates a new versioned `_A_GLD` folder (e.g. `V01_A` → `V02_A`) with the updated `.do` file
4. Appends an entry to the Version Control block inside the `.do` file
5. Optionally executes the updated `.do` file in Stata and verifies the harmonized `.dta` output was produced

Surveys that fail validation are skipped and logged; the pipeline continues processing the remaining surveys. A summary table is printed at the end.

---

## File Structure

The repository contains four R scripts. They must all be sourced before running the pipeline.

| File | Purpose |
|---|---|
| `helper_utilities.R` | Low-level utility functions (file discovery, folder building, code block manipulation) |
| `validate_survey_combination.R` | Pre-flight validation for a single (country, year, survey) combination |
| `execute_survey_updates.R` | Creates the new versioned folder and applies all updates |
| `orchestrate_updates.R` | Top-level function — reads input, loops over surveys, collects results |
| `example_usage.R` | A ready-to-run example script |

---

## Input File Format

The input file must be a **CSV or Excel** (`.xlsx`/`.xls`) file with the following five columns:

| Column | Description |
|---|---|
| `country` | Three-letter country code (e.g. `ZAF`, `PAK`) |
| `year` | Survey year (e.g. `2020`) |
| `survey` | Survey abbreviation (e.g. `QLFS`, `LFS`) |
| `var_name` | Name of the variable block to update (must match the marker in the `.do` file) |
| `lines` | One line of Stata code per row |

Each row is **one line** of Stata code. All rows sharing the same `(country, year, survey, var_name)` combination are treated as a single block and will replace everything currently between `*<_varname_>` and `*</_varname_>` in the `.do` file.

**Example:**

| country | year | survey | var_name | lines |
|---|---|---|---|---|
| ZAF | 2020 | QLFS | survey | `gen survey = "QLFS-Q1"` |
| ZAF | 2020 | QLFS | survey | `label var survey "Survey type"` |
| ZAF | 2020 | QLFS | lstatus | `gen lstatus = .` |

> **Note:** Each `var_name` must have a corresponding `*<_varname_>` / `*</_varname_>` marker pair already present in the `.do` file. The pipeline will flag missing markers during validation and skip that survey.

---

## Expected Folder Structure

The pipeline expects the following directory layout under `base_path`:

```
base_path/
  ZAF/
    ZAF_2020_QLFS/
      ZAF_2020_QLFS_V01_M/
      ZAF_2020_QLFS_V01_M_V01_A_GLD/        ← latest GLD folder (source)
        Data/
          Harmonized/
        Doc/
        Programs/
          ZAF_2020_QLFS_V01_M_V01_A_GLD_ALL.do
        Work/
```

After a successful run, the pipeline will create:

```
ZAF_2020_QLFS_V01_M_V02_A_GLD/              ← new versioned folder
  Data/Harmonized/                           ← filled by Stata if run
  Programs/
    ZAF_2020_QLFS_V01_M_V02_A_GLD_ALL.do    ← updated .do file
  Doc/                                       ← copied from V01
  Work/                                      ← copied from V01
```

The A-version number is automatically incremented. `Doc/` and `Work/` are copied from the source folder; `Data/Harmonized/` starts empty and is populated when Stata runs.

---

## Step-by-Step Usage

### 1. Prepare your input file

Create a CSV or Excel file following the format described above. Each row is one line of Stata code for a given survey and variable. Save it somewhere accessible.

### 2. Open `example_usage.R` and set your paths

```r
input_file  <- "path/to/your/updates.xlsx"   # or .csv
base_path   <- "path/to/GLD/Countries"
source_path <- "path/to/this/repository"
```

### 3. Source all scripts

```r
source(file.path(source_path, "helper_utilities.R"))
source(file.path(source_path, "validate_survey_combination.R"))
source(file.path(source_path, "execute_survey_updates.R"))
source(file.path(source_path, "orchestrate_updates.R"))
```

### 4. Run the pipeline

```r
results <- orchestrate_updates(
  input_file = input_file,
  base_path  = base_path,
  stata_path = "C:/Program Files/Stata18/StataMP-64.exe"  # omit to skip Stata
)
```

Set `stata_path = NULL` (or omit it) if you want to apply the code changes without running Stata. The updated `.do` file will still be created and written to disk.

### 5. Review the results

`orchestrate_updates()` prints a summary table to the console and returns a tibble with one row per survey:

| Column | Description |
|---|---|
| `country` | Country code |
| `year` | Survey year |
| `survey` | Survey abbreviation |
| `validation_passed` | `TRUE` / `FALSE` |
| `validation_errors` | Description of any validation failures |
| `execution_passed` | `TRUE` / `FALSE` (or `NA` if validation failed) |
| `execution_errors` | Description of any execution failures |

Inspect failed surveys, correct the input file or folder structure as needed, and re-run.

---

## Validation Checks

Before making any file changes, the pipeline checks the following for each survey:

- The survey-level folder exists under `base_path`
- At least one `_A_GLD` folder is present
- The latest `_A_GLD` folder contains a `Programs/` subfolder with exactly one `.do` file
- Every `var_name` in the input has matching `*<_varname_>` / `*</_varname_>` markers in the `.do` file
- The proposed code is not identical to what is already in the `.do` file (redundant update check)
- A `<_Version Control_>` / `</_Version Control_>` block exists in the `.do` file

If any check fails, that survey is skipped and all errors are recorded in the results table.

---

## Function Reference

| Function | File | Description |
|---|---|---|
| `orchestrate_updates()` | `orchestrate_updates.R` | Main entry point. Reads input, validates and executes updates for all surveys. |
| `validate_survey_combination()` | `validate_survey_combination.R` | Runs all pre-flight checks for a single survey. Returns a list with `passed`, `errors`, and `latest_gld`. |
| `execute_survey_updates()` | `execute_survey_updates.R` | Creates new versioned folder, applies code changes, updates Version Control block, and optionally runs Stata. |
| `read_updates()` | `helper_utilities.R` | Reads CSV or Excel input into a standardized tibble. |
| `build_survey_folder()` | `helper_utilities.R` | Constructs the expected folder path for a given country/year/survey. |
| `find_gld_folders()` | `helper_utilities.R` | Finds all `_A_GLD` subfolders within a survey folder. |
| `update_code_between_tags()` | `helper_utilities.R` | Replaces the content between a variable's marker tags in the `.do` file. |
| `update_version_control()` | `helper_utilities.R` | Appends a new entry to the Version Control block. |
