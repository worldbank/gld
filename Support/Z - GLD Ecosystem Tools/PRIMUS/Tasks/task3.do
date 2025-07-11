/* TASK SET 3
This task cleans up the temp folder and log files\confirm
*/

* == > User input required <== *
* Define the location of the folders where either data or helper do files are being read from, or where outputs will be stored.
* Please use backward slash because forward slashes creates issue with Windows commands
global primusfolder "C:\Users\\`c(username)'\WBG\GLD - Current Contributors\510859_AS\PRIMUS"
global gldfolder "C:\Users\\`c(username)'\WBG\GLD - GLD"
global logfolder "C:\Users\\`c(username)'\WBG\GLD - Current Contributors\510859_AS\PRIMUS\log files"
* == > End user input  <== * (from here is all should work automatically if all paths correct)

* Delete files older than 30 days in log files folder
shell powershell -command "Get-ChildItem -Path '${logfolder}' -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force"

* Delete files older than 30 days in temp folder
shell powershell -command "Get-ChildItem -Path '${tempfolder}' -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force"
