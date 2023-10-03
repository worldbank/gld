{smcl}
{* 03 Oct 2023}{...}
{hline}
help for {hi:gldpanel_append_check}
{hline}

{title:Overview}

{pstd}{cmd:gldpanel_append_check} is tailored for users appending datasets, especially from the Global Labor Database (GLD). It ensures data type consistency across datasets, highlighting data type disparities and missing variables across survey years, making appending seamless. Additionally, the program flags variables that might be present in certain datasets but absent in others, indicating potential data inconsistencies or coding gaps. For best results, datasets should align with the filelist format.{p_end}

{title:Preliminary Checks}

{phang2}Data in Memory: The program checks if there's data in memory. If not, it alerts with exit code (198).
{phang2}Filelist Format Verification: Validates if the dataset follows the filelist format. If not, prompts the user to execute the filelist command.{p_end}

{title:Data Initialization}

{phang2}Full Name Generation: Checks for a 'fullname' variable (a blend of directory and file names) and creates one if absent.
{phang2}Year Extraction: Extracts the survey year from filenames, if not already done. This year is pivotal for subsequent steps.{p_end}

{title:Data Type Consistency and Missingness Checks}

{phang2}Data Type Verification: The program identifies disparities in data types across survey years and alerts if needed.
{phang2}Variable Availability: Highlights if specific variables are present in certain years but absent in others.{p_end}

{title:Notes for Users}

{phang2}Required Data Format: Ensure datasets are in the filelist format. Running the filelist command beforehand is recommended.
{phang2}Understanding Outputs: The program provides consistent feedback during its run. It flags any irregularities or potential issues ensuring data accuracy and coherence.{p_end}

{title:Conclusion}

{pstd}The {cmd:gldpanel_append_check} acts as a pivotal tool for appending datasets. By recognizing mismatches in data types and missing variables, it aids users in rectifying problems before they become significant, ensuring data stability and reliability.{p_end}

