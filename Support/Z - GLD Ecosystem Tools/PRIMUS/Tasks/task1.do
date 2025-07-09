/* TASK SET 1
1. Identify the surveys needed to upload/update
2. Upload the surveys
3. Confirm the upload										*/
version 18 

* == > User input required <== *
* Define the location of the folders where either data or helper do files are being read from, or where outputs will be stored.
* Please use backward slash because forward slashes creates issue with Windows commands
global primusfolder "C:\Users\\`c(username)'\WBG\GLD - Current Contributors\510859_AS\PRIMUS"
global gldfolder "C:\Users\\`c(username)'\WBG\GLD - GLD"
global logfolder "C:\Users\\`c(username)'\WBG\GLD - Current Contributors\510859_AS\PRIMUS\log files"
* == > End user input  <== * (from here is all should work automatically if all paths correct)

display "${primusfolder}"

* File size limit
scalar filelimit = 1.0

* Sample restriction
global includepanels = "No"

global datestamp = subinstr("`=c(current_date)'", " ", "_", .)  
global timestamp = subinstr("`=c(current_time)'", ":", "-", .)  

* Create a log file
capture log close
log using "${logfolder}/task1_${datestamp}_${timestamp}.log"
set trace on
* Identify surveys need to upload/update
do "${primusfolder}/Do files/get metadata.do"

* Load the create xml function
do "${primusfolder}/Do files/create xml file.do"

* Upload the surveys
do "${primusfolder}/Do files/upload sequence.do"

* Confirm the uploads
do "${primusfolder}/Do files/confirm upload.do"

log close

set trace off
