# A guide to the GLD quality checks

This is a guide to the quality checks for the Global Labor Database (GLD). After reading it, users should be able to:

- understand what the quality checks evaluate and how they work
- run the checks by themselves on a newly harmonized file, and
-  read and interpret the output

The guide devotes a major section to each of the learning objectives. We begin, however, with a discussion of the [overall checks template](Template_Q_Checks.do).

## Overall quality checks template

The overall quality checks template (shown below) is the only do-file the user needs to interact with regularly. It defines al relevant arguments and calls the do-files that run the five blocks into which the quality checks are divided.

<br></br>
![screenshot of checks template](utilities/template_pic.png)
<br></br>

The quality checks template proceeds in three steps. Step 1 readies Stata by cleaning up any data that may still be stored in the memory. Step 2 defines the arguments. It is the only section requiring user input. Users need to define three `globals`.

- `helper`: Define the path to the folder that contains all the files that run the quality checks (here, folder [Helper_programs_1.4](Helper_programs_1.4)). It is recommended to have this be a central place so it applies to all surveys and can easily be updated if the quality checks are amended.
- `mydata`: Define the path to the harmonized data the user wishes to check.
- `output`: Define the path to the folder the user wants the output to be stored in. It is recommended to make this the `CCC_YYYY_SURV_V0#_M_V0#_A_GLD/Work/Output` folder for consistency so other users may always know where to find the checks output.

Step 3 simply calls the do files from the helper path running the checks. This step no longer requires user involvement.
