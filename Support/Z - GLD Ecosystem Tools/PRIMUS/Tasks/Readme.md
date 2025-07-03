# Tasks

The integration process is organized into three separate tasks stored as Stata `.do` files, each corresponding to a scheduled task. These will be executed automatically using a task scheduler on different dates or triggers, depending on the workflow. 

### Task 1 – Upload and Confirm

This task is responsible for identifying GLD surveys that have not yet been uploaded or updated in Datalibweb and initiating their transfer through PRIMUS. It involves a series of structured sub-tasks that ensure data is compliant with PRIMUS protocols and correctly registered in the system. The `task1.do` is a master do file involving a set of sub-processes, which are described further in the [do file folder](https://github.com/giofsantos11/gld-1/tree/primus/Support/Z%20-%20GLD%20Ecosystem%20Tools/PRIMUS/Do%20files). It begins by setting the parameters, such as the location of the important folders, the inclusion of panel data, and the file size restrictions. Then, it proceeds with the following processes:

**a. Reconciling GLD and Datalibweb survey inventory**  
The first step involves comparing the set of harmonized surveys available on the GLD server with those already available on Datalibweb. This reconciliation identifies any missing surveys or surveys that have been updated in GLD but not yet uploaded to PRIMUS, and flags them for upload.

**b. Preparing data for upload**  
This sub-task ensures that each dataset meets PRIMUS’s technical requirements. This includes validating version sequencing (e.g., a version 2 cannot be uploaded if version 1 is missing), filtering out non-compliant folders (e.g., GLD’s internal `work` folder is excluded), and ensuring the total file size does not exceed 1.5 GB. In addition, an XML file is generated for each dataset, containing summary indicators of the harmonized microdata and key metadata required by PRIMUS. The process also includes automated checks for missing data, upload errors, and other flags, all of which are documented in a log file along with the transaction IDs assigned by PRIMUS for traceability.

**c. Confirming the data in PRIMUS**  
In the PRIMUS workflow, each uploaded dataset must go through two stages of clearance: **confirmation** and **approval**. According to PRIMUS documentation, confirmation is the first step in the vetting process and signifies that the data upload is complete and technically sound. While in most workflows this is done by designated reviewers, in the case of GLD, this step is embedded in the harmonization and validation process itself. Therefore, confirmation in PRIMUS is treated as a formal registration of a dataset that is already validated.

After confirmation, the dataset must be **approved** for it to be published on Datalibweb. Approval typically requires reviewers to inspect the files and replicate summary statistics using the uploaded XML and data. However, because data upload takes time to complete fully, trying to approve a dataset immediately after upload can cause errors or incomplete validation. To address this, approval is handled separately in **Task 2**. Task 1 is therefore limited to initiating the upload and confirming the transaction once all technical checks have passed.

  
### Task 2 – Approve for Datalibweb 

This follow-up task is run after Task 1. It reviews the uploaded transactions and automatically approves them in PRIMUS. Once approved, the data becomes visible and accessible in Datalibweb for authorized users.
  
### Task 3 – Cleanup 

This task removes log files and temporary working files generated during Task 1. It helps maintain a clean working environment and ensures that unnecessary files do not accumulate over time.
