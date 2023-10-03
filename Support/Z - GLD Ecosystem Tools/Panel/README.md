## Introduction to GLD Panel Diagnostic Tools

### GLD Panel Construction Workflow
The process of panel data analysis is a meticulous endeavor, and our package is tailored to streamline this workflow. The journey begins with **appending**, where users can seamlessly extract the most recent versions of surveys from the GLD folder. This step emphasizes ensuring a consistent data format across surveys and promptly flags any variables that reappear in multiple surveys. As the process progresses to the **construction of key variables**, emphasis is placed on generating essential variables such as `panel`, `visit_no`, `hhid_panel`, and `pid_panel`. This stage also warrants checks for internal consistency, for instance, verifying the relationship between variables like `wave` and `visit_no`. Additionally, it's essential to look out for any ID re-usage across non-consecutive survey years. The final phase revolves around **panel quality check**, where the data's integrity is held to the highest standard. It involves a thorough examination of discrepancies in time-invariant variables, assessing the plausible origins of these mismatches, and a comprehensive measurement of attrition.

### Appending
Within the appending category, there's the `append_check` program. This serves as a post-command for the `filelist`. Its primary function is to identify and notify users about inconsistencies in data types and any missing variables across surveys.

### Panel Construction
For those working on constructing panels, two programs are particularly of note:
- `gldpanel_wave_visit_check` checks the uniqueness of the visit number for every wave. It ensures that each visit number corresponds to only one wave. There are future developments in the pipeline for this tool, including the addition of checks to ensure that there's a monotonic relationship between the wave number and visit number.
- `gldpanel_id_check` examines the use of individual and household IDs. Specifically, it identifies instances where an ID has been used in non-subsequent survey years or multiple times within a single survey year.

### Panel Quality Check
Ensuring the quality of panels is crucial, and the package offers several programs for this purpose:
- `gldpanel_issue_check` is a visual tool that produces bar charts detailing the size of mismatches by age and/or sex. This can help in quickly pinpointing demographic segments where data might have inconsistencies.
- `gldpanel_check_source` takes this a step further by generating bar charts that aim to identify potential causes of these mismatches.
- Lastly, `gldpanel_attrition` aids in the analysis of data attrition. It creates bar charts that present different attrition measures, providing insights into how much data might be lost or overlooked over time and across different survey iterations.

### Package installation

To install the package, users need to type the following in the Stata command bar:

```
net install gld_panel_tools, replace from("https://github.com/worldbank/gld/edit/panels/Support/Z%20-%20GLD%20Ecosystem%20Tools/Panel")
```
