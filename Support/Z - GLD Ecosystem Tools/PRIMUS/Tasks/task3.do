/* TASK SET 3
This task cleans up the temp folder and log files\confirm
*/

* Folder names
global primusfolder "C:\Users\wb510859\OneDrive - WBG\PRIMUS"
global logfolder "C:\Users\wb510859\OneDrive - WBG\PRIMUS\log files"
global tempfolder "C:\Users\wb510859\OneDrive - WBG\PRIMUS\temp"

* Delete files older than 30 days in log files folder
shell powershell -command "Get-ChildItem -Path '${logfolder}' -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force"

* Delete files older than 30 days in temp folder
shell powershell -command "Get-ChildItem -Path '${tempfolder}' -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force"
