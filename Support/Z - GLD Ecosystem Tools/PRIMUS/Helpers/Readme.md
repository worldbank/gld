# Task 1 helper do files

This folder contains the do files used as building blocks of Task 1, which ultimately uploads all the needed surveys into PRIMUS.

## `get metadata.do`: Reconciling GLD and Datalibweb survey versions

The do file `get metadata.do` performs the following processes

### A. Extract Metadata from GLD Folder Structure

This block recursively scans the folder structure of the GLD directory to construct survey identifiers and extract version information:
- It parses the folder names into components: country code, survey year, survey short name, and master/alternative version codes.
- Raw folders are excluded because their counterparts in the Datalibweb cannot be identified. Thus, we assume that if a harmonized folder is missing, the raw is also not uploaded. This is consistent with the pre-PRIMUS workflow of GLD where both harmonized and raw are uploaded at the same time (i.e., even if a raw is available earlier, this is not uploaded until the harmonized data is not finalized). 
- When multiple versions are present, only the latest is kept for each unique survey. This will be matched later with the latest version in Datalibweb. All intermediate versions that require upload will be identified later in the do file, `upload sequence.do`

### B. Extract Metadata from Datalibweb

This block retrieves survey metadata from Datalibweb using the `datalibweb` Stata API and merges it with the GLD metadata:
- The merge identifies surveys that are in GLD but not in Datalibweb, and vice versa.
- Based on duplicate patterns and merge results, each survey is flagged for a potential action:
  - New upload
  - Version update
  - Error (present in Datalibweb but missing in GLD)

If no mismatches are detected, the script exits early, indicating Datalibweb is already up to date.


### C. Case Classification and Path Construction

After reconciliation, each unmatched or inconsistent survey is classified into one of four case types. These classifications determine the upload procedure required in PRIMUS.

#### Case Classification Table

| Case Type | Description |
|-----------|-------------|
| **1 – New upload** | The survey is present in GLD but not yet in Datalibweb. Both raw and harmonized data need to be uploaded. |
| **2 – Update harmonized data only** | The survey exists in both sources with the same master version (raw data), but the harmonized (alternative) version is newer in GLD. Only the harmonized file needs to be updated. |
| **3 – Update raw and harmonized data** | The survey exists in both sources, but both the raw (master) and harmonized (alternative) versions differ. A full re-upload of both components is required. |
| **4 – New upload of multiple versions** | A special variation of case 1 where upload is required for multiple versions of harmonized and/or raw folders. Example is when the latest in GLD is V02_M_V02_A_GLD, but first upload has not yet taken place.


### D. Excel Output

The final output is an Excel file containing three separate tabs that guide the PRIMUS upload process. The table below describes the purpose of each tab:

| Sheet Name | Description |
|------------|-------------|
| **Guide**  | Contains definitions and descriptions for all variables in the output file, serving as metadata for users. |
| **Main**   | The primary sheet listing all upload cases (new uploads and version updates), along with the constructed paths for raw and harmonized folders. |
| **Flags**  | A troubleshooting sheet listing unusual cases where a survey appears in Datalibweb but not in GLD, which may require manual review. |

The file is saved in the parent directory with the naming convention:  
`gld_dlw_reconcile_YYYY_MM_DD.xlsx`. Everytime the `get metadata.do` is run, the previous Excel output is deleted to ensure that only one version exists in the parent folder. 

## `create xml file.do`: Generate PRIMUS-Compatible XML Summary for GLD Uploads

The `primus_xml_gld` program is a function designed to generate an XML metadata file required by PRIMUS when uploading harmonized labor force surveys from the Global Labor Database (GLD). This XML file summarizes labor status (rates of employment, unemployment and non-labor force participation) derived from the microdata and follows the schema expected by the PRIMUS platform as provided [here](https://github.com/worldbank/primus/blob/master/Stata/plus/p/primus_xml.ado). The labor status variable `lstatus` is hardcoded, meaning that the function expects the variable to be there (as should be in the case of the GLD). If `lstatus` is not found, the code will be interrupted. 

### Syntax

```stata
primus_xml_gld [if] [in], xmlout(string) country(string) year(string) ///
    surveyid(string) filename(string) [byvar(varname) weightlist(varname)]
```

where:
- `xmlout` is the full file location where the xml file will be stored (this is defined in the next do file)
- `country` is the three-digit country code of the survey, which can be extracted from the surveyid
- `year` is the year of the survey in string format
- `surveyid` is the name of the survey following the World Bank naming convention (e.g., CMR_2010_EESI_V01_M_V01_A_GLD)
- `filename` is the full file location of the harmonized dataset from which the labor indicatirs will be calculated

## `upload sequence.do`: Uploading into PRIMUS

This Stata script automates the preparation and upload of Global Labor Database (GLD) survey data into PRIMUS. The workflow involves generating required metadata, managing versioning logic, compressing folders, verifying size constraints, and logging transactions for both raw and harmonized data.

---

### A. Prepare the Files

#### 1. Initialize Log File and Load Reconciliation Results

- A new CSV log file is created using a timestamped filename (`tranxids_YYYYMMDD_HHMMSS.csv`).
- The script locates the most recent reconciliation Excel file (`gld_dlw_reconcile_[Date].xlsx`) in the `${primusfolder}` directory and loads the "Main" sheet containing the upload plan.

#### 2. Handle Version Gaps (Intermediate Version Logic)

PRIMUS requires all sequential versions to be uploaded. This section fills in gaps the vintages. For example, if V01_M_V01_A_GLD is the latest in DLW and V01_M_V03_A_GLD for GLD, this expands the metadata to fill in the intermediate vintage V01_M_V02_A_GLD). It performs the following:

- Calculates version differences between GLD and Datalibweb.
- Expands the dataset to generate rows for any missing intermediate versions.
- Assigns updated `surveyid`, `veralt_gld`, and `vermast_gld` fields for these new rows.
- Updates folder paths dynamically to reflect new harmonized versions.

#### 3. Folder and Path Preparation

- Constructs the expected harmonized data folder path (`harmdir`) using survey metadata.
- Dynamically locates the root folder path and recalculates full paths for harmonized uploads.
- Classifies any newly added intermediate versions as `"2 - update harm"`.

#### 4. Setup for File Generation

- Creates folders for storing XML and ZIP files.
- Iterates over each row (survey) to:
  - Generate XML metadata files using the `primus_xml_gld` program
  - Use `robocopy` and `tar.exe` to selectively copy and compress allowed folders (i.e., `Data`, `Doc`, `Programs` are included, but GLD's `Work` folder is not). PRIMUS allows for expedient upload of a single zip file. 
  - Measure folder size using PowerShell to ensure it meets the 1.5 GB file size limit enforced by PRIMUS.
  - If over the limit:
    - Generates a Word file with instructions for users to request access via email.
    - Skips data upload while still creating metadata documentation.

#### 5. Special Handling for Raw Data (Cases 1, 3, and 4 Only)

- Compresses raw data folders separately if applicable.
- Excludes the `Data` subfolder when above the 1.5 GB limit to ensure PRIMUS acceptance.
- Creates a fallback `.doc` file explaining the data omission due to size constraints.


### B. Upload the Files to PRIMUS

This section executes the actual uploads via the PRIMUS Stata API.

#### 1. Harmonized File Upload

- Uses `primus upload` with `processid(14)` for harmonized datasets.
- First uploads the XML file, then attaches the ZIP file containing the harmonized data.
- If the transaction fails (e.g., duplicate entry), logs the error in the transaction CSV file and continues with the next survey.

#### 2. Raw File Upload (Conditional)

- For applicable case types (`1`, `3`, `4`), uploads the raw data using `processid(15)`.
- Logs transaction IDs separately for raw and harmonized uploads.
- Logs a note if upload fails or is skipped due to size.

#### 3. Logging Outcomes

Every upload attempt (success or failure) is recorded in the log file with the following logic:

| Condition                                       | Log Action                                                        |
|------------------------------------------------|--------------------------------------------------------------------|
| Successful upload (harm + raw)                 | Both transaction IDs logged with a success message                 |
| Successful upload (harm only)                  | Logs only harmonized transaction ID; marks raw as `NA`             |
| File too large (raw or harm)                   | Logs file size with explanatory note                               |
| Missing `.dta` or upload error                 | Logs as failed and continues processing other surveys              |

#### 4. Cleanup

- Temporary folders created for cleaned upload contents are deleted after use.
- ZIP files from the current round are cleared from the output folder to prevent clutter.


## `confirm upload.do`: Confirm PRIMUS Upload Transactions

This script finalizes GLD uploads into PRIMUS by confirming transaction records that were previously uploaded in draft status. After uploading data through PRIMUS, all datasets are initially stored as draft transactions. These drafts are not yet visible to PRIMUS reviewers and therefore must be explicitly confirmed to move them into reviewable status. This script automates that confirmation process.

This script is designed to:

- Load the list of transaction IDs created during the upload phase (from `upload sequence.do`);
- Loop through each row, confirming both harmonized and raw transactions;
- Export a fresh transaction file (`latest.csv`) that will serve as the basis for the **approval step** (Task 2).

  
