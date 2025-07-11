## Best Practices for Uploading GLD Data to PRIMUS

In addition to strict PRIMUS rules, several workflow design choices implemented in the automation script serve as best practices. These are not enforced by the PRIMUS system itself, but are essential for avoiding upload issues, reducing reviewer confusion, and maintaining a robust, auditable process.

### 1. Classification of Upload Cases

The upload workflow categorizes each survey into one of four `case_type`s based on the differences between GLD and Datalibweb versions. These classifications guide whether to upload raw data, harmonized data, or both. While not required by PRIMUS, this classification ensures that:

- Version sequencing is respected,
- Raw data is uploaded only when needed, and
- The right upload logic is applied per survey.

This logic prevents accidental overwriting or skipped uploads due to incomplete prerequisites.

### 2. Creation of `.doc` Files for Oversized Datasets

When a survey folder exceeds the 1.5 GB size limit imposed by PRIMUS, the harmonized or raw data cannot be uploaded. Instead of skipping the upload entirely, the script creates a `.doc` file in the `Doc/Technical/` folder with the instructions on how to access the complete data.

This allows the folder to still be uploaded and registered in PRIMUS, preventing it from being misclassified as missing. Reviewers will see the explanatory `.doc` file and know that no action is required.

### 3. Zipping the Entire Folder

The script compresses the entire cleaned survey folder into a single `.zip` file (using `tar.exe`) before uploading. This is not required by PRIMUS but is considered best practice for several reasons:

- Uploading a single ZIP avoids managing individual file uploads.
- Ensures folder structure is preserved (`Data`, `Doc`, `Programs`).
- Simplifies automation and troubleshooting.

**Caveat:** Each file within the ZIP must still comply with PRIMUS rules (e.g., file naming, size limits, accepted formats).

### 4. Transaction Logging and Issue Tracking

The script maintains a central CSV log file named like `tranxids_YYYYMMDD_HHMMSS.csv`, which stores:

- `surveyid`
- `tranxid_harmonized`
- `tranxid_raw`
- `notes` or error messages (e.g., “File too large”, “Dataset not found”, “Upload successful”)

This log allows for:

- Tracking all transactions in a single, structured place.
- Reuse in the confirmation and approval phases.
- Debugging of issues in automated runs without needing to reprocess all surveys.

Additionally, Stata log files (`.log`) are generated per process if desired, ensuring full traceability.

### 5. Checks Performed Before Upload

Before uploading, the script performs a number of defensive checks to ensure data availability and structural integrity:

| Check Description           | Condition                                                 | Consequence                                                    |
|----------------------------|-----------------------------------------------------------|----------------------------------------------------------------|
| **Check for `.dta` file**  | The harmonized Stata data file must exist in the expected folder | If missing, the survey is skipped and logged as a missing dataset. Users should check if the data file is misplaced or uses an inconsistent name |
| **Check for `lstatus`**  | The `lstatus` variable should be present in the harmonized folder | If missing, not possible to create XML file and upload harmonized; thus, the survey is skipped and issue is logged. |
| **Folder size check**      | The total size of each folder must be under 1.5 GB        | If exceeded, the data is not uploaded and a `.doc` file is created to explain why |
| **Case logic check**       | Raw data is only uploaded for surveys requiring new or updated raw files | Avoids uploading unnecessary files                             |
| **GLD must have greater than or equal # of versions** | The number of versions found in GLD should be greater than in or equal to Datalibweb | If not, this may indicate a problem in GLD, such as accidental deletion or incomplete storage, and the upload is skipped or flagged |


### 6. One-at-a-time uploads for multiple updates

When multiple versions of a survey are missing in Datalibweb, PRIMUS enforces sequential versioning, meaning each version must be uploaded and approved in order. Attempting to upload a later version before its predecessor has been approved will result in a error flag.

To resolve this, our workflow implements a staggered approach. During each run, only the earliest version missing in Datalibweb is selected for upload. This avoids version sequencing violations and allows the approval process to catch up before subsequent uploads.

For example, suppose GLD contains versions V01 and V03, but only V01 is in Datalibweb. Since version V02 is missing, the program will upload V02 during this run. On the next run—after V02 has been approved—V03 will then be recognized as the next earliest missing version and will be uploaded.

### 7. Separating upload/confirm and approve

Uploading survey folders to PRIMUS takes time to complete, and attempting to confirm and approve them too soon can lead to errors. To prevent this, the upload and confirmation steps are performed on one day, and the approval step is run on a separate day. After each upload, the script generates a CSV log containing transaction IDs and status flags. To isolate only the successful uploads for approval, a filtered version of this log, excluding rows with errors, is saved as `latest.csv`. This file is then used in the next day’s run to approve the confirmed transactions then deleted as soon as approval is successful.








      
