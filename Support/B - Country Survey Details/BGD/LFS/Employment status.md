# Coding `empstat` in the BGD LFS

The employment status categories in the Bangladesh LFS vary over the years. The table below lists down the employment status categories used in each survey, and the check mark ✓ identifies the GLD `empstat` category to which they were mapped. 

There are a few considerations in this mapping. First, unpaid family worker was no longer used beginning in the 2013 survey, and this is replaced by "contributing family worker". 
By removing the qualifier, "unpaid" for family workers, the mapping in the GLD becomes less obvious. This renaming of status was introduced by the [International Classification of Status of Employment (ICSE)
1993](Utilities/icse93.pdf). Under ILO's definition (see below), contributing family workers are considered "unpaid"

<img src="Utilities/def_cfw.PNG" alt="BGD_divisions" width="600" height="200">


| **BGD LFS employment   status** | **Paid employee** | **Non-paid employee** | **Employer** | **Self-employed** | **Not classificable** |
|---|:---:|:---:|:---:|:---:|:---:|
| **2005** |  |  |  |  |  |
| 1. regular paid employee | ✓ |  |  |  |  |
| 2. employer |  |  | ✓ |  |  |
| 3. self-employed |  |  |  | ✓ |  |
| 4. unpaid family worker |  | ✓ |  |  |  |
| 5. irregular paid worker | ✓ |  |  |  |  |
| 6. day labor (agriculture) | ✓ |  |  |  |  |
| 7. day labor (non-agriculture) | ✓ |  |  |  |  |
| 8. domestic worker (maid servant) | ✓ |  |  |  |  |
| 9. paid/unpaid apprentice |  |  |  |  | ✓ |
| 10. others |  |  |  |  | ✓ |
| **2010** |  |  |  |  |  |
| 1. regular paid employee | ✓ |  |  |  |  |
| 2. employer |  |  | ✓ |  |  |
| 3. self employed (agri) |  |  |  | ✓ |  |
| 4. self employed (non-agri) |  |  |  | ✓ |  |
| 5. unpaid family worker |  | ✓ |  |  |  |
| 6. irregular paid worker | ✓ |  |  |  |  |
| 7. day labourer (agri) | ✓ |  |  |  |  |
| 8. day labourer (non-agri) | ✓ |  |  |  |  |
| 9. servant | ✓ |  |  |  |  |
| **2013** |  |  |  |  |  |
| 1. employer |  |  | ✓ |  |  |
| 2. self employed (agri) |  |  |  | ✓ |  |
| 3. self-employed (non-agriculture) |  |  |  |  | ✓ |
| 4. contributing family helper |  | ✓ |  |  |  |
| 5. employee | ✓ |  |  |  |  |
| 6. day labour (agriculture) | ✓ |  |  |  |  |
| 7. day labour (non-agriculture) | ✓ |  |  |  |  |
| 8. apprentice |  |  |  |  | ✓ |
| 9. domestic worker | ✓ |  |  |  |  |
| 99. others |  |  |  |  | ✓ |
