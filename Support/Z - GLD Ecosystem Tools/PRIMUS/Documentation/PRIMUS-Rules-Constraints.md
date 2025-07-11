# PRIMUS Rules and Constraints

PRIMUS has a set of rules and constraints that users need to consider when uploading data. These are organized into four categories for clarity.

---

## A. Upload Cycle

| Rule | Description |
|------|-------------|
| **1. Draft mode** | • All data uploads are initially stored in draft mode. <br> • They must be confirmed before reviewers can see them. |
| **2. Two-step workflow** | • Uploading is followed by an explicit confirm step (`primus action, decision(confirm)`). <br> • Then, a separate approval step is required. (`primus action, decision(approve)`) |
| **3. Separate processes** | • Harmonized and raw data must be uploaded under different process IDs. <br> • For GLD, process ID 14 is for harmonized files and 15 is for raw. |
| **4. XML file required for harmonized uploads** | • An XML file containing the values of pre-selected indicators is required for each vintage of the harmonized file, even if indicator values did not change. |


## B. Transaction ID Handling

| Rule | Description |
|------|-------------|
| **1. Transaction IDs required for confirmation and approval** | • Transaction IDs generated upon upload must be retained in order to confirm or approve the transaction in the future. |
| **2. Re-use of transaction IDs is possible** | • Transaction IDs can be re-used such that two separate uploads are represented by one transaction ID. <br> • This is relevant for uploading harmonized files because XML upload is separate from all other files. In the code, one transaction ID is used to uniquely correspond to an upload type (harmonized or raw) and the country-year-survey. |

## C. Version Sequencing

| Rule | Description |
|------|-------------|
| **1. Sequential versions required** | • PRIMUS enforces sequential version uploads. <br> • If version 3 for the harmonized is available but earlier versions were not uploaded, users are required to backfill earlier vintages (e.g., upload of V03, requires V01 and V02) despite being out of date. |
| **2. Master version sequencing** | • A slightly different rule applies to the sequencing of the master version. <br> • Uploading the raw file for version 1 (e.g., `V01_M`) is not required when uploading its harmonized counterpart. <br> • However, if the harmonized file is based on version 2 of the master (e.g., `V02_M_V01_A_GLD`), then both version 1 and version 2 of the master (`V01_M` and `V02_M`) must be uploaded first, in order, before uploading the harmonized file. |

## D. Folder Size and Structure

| Rule | Description |
|------|-------------|
| **1. Folder size limit** | • PRIMUS does not accept folder uploads larger than 1.5 GB. <br> • This applies separately to raw and harmonized folders. <br> • If the folder size exceeds this limit, the script skips uploading the `Data` folder and creates a `.doc` file explaining how to request the full dataset via email. This still allows the survey ID to be registered in PRIMUS and Datalibweb. |
| **2. Only specific sub-folders allowed** | • Only `Data`, `Doc`, and `Programs` folders are accepted in PRIMUS. <br> • The GLD folder structure includes a `Work` folder that is not accepted by PRIMUS and must be excluded from the uploaded ZIP file. |
| **3. Accepted file types by folder** | • PRIMUS restricts uploads to specific file extensions by folder and type. See tables below for allowed formats for **harmonized** and **raw** uploads. |

### Accepted File Types – Harmonized Uploads

| Folder Path              | Accepted Extensions                          |
|--------------------------|----------------------------------------------|
| `Data/Harmonized`        | `dta`                                        |
| `Doc/Questionnaires`     | `csv`, `doc`, `docx`, `pdf`, `rar`, `xls`, `xlsx`, `zip` |
| `Doc/Technical`          | `csv`, `doc`, `docx`, `dta`, `log`, `pdf`, `rar`, `xls`, `xlsx`, `zip` |
| `Programs`               | `do`                                         |

### Accepted File Types – Raw Uploads

| Folder Path              | Accepted Extensions                          |
|--------------------------|----------------------------------------------|
| `Data/Original`          | `csv`, `dat`, `dbf`, `dct`, `do`, `dta`, `log`, `rar`, `sav`, `xls`, `xlsx`, `zip` |
| `Data/Stata`             | `dta`                                        |
| `Doc/Questionnaires`     | `doc`, `docx`, `pdf`, `rar`, `xlsx`, `zip`   |
| `Doc/Technical`          | `csv`, `doc`, `docx`, `log`, `pdf`, `rar`, `xls`, `xlsx`, `zip` |
| `Programs`               | `do`                                         |
