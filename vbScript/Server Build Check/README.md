# PRE-INSTALLATION CHECKLIST FOR WINDOWS SERVER


This checklist can be used to validate the Windows Server infrastructure

## PART 1. EXCEL SPREADSHEET

* Open the file in Excel
* Right click on the aupr2ap198nabwi tab, and click on Move or Copy…
* Tick the Box: Create a Copy
* Select (move to end), then click on OK
* Right click on the aupr2ap198nabwi (2) tab, and click on Rename
* Populate the Expected Values (column B) from the information found in the detailed solution/design
* Click on the Export to CSV button, located in position A1 of the worksheet. 
* This will export the current worksheet to a file on your desktop, using the worksheet name as the filename (e.g. aupr2ap198nabwi.csv)
* Proceed to Part 2…



## PART 2. VBSCRIPT

* Copy the CSV file (e.g. aupr2ap198nabwi.csv) and VBScript (pre-install-checks.vbs) to a Temp folder on the windows server you wish to test )e.g. E:\Temp)
* RDP to the server you wish to test
* Create a shortcut to cmd.exe, then right click on the shortcut and choose Run as administrator , and use your own Admin credentials
* Change to the folder where the VBScript and CSV file are located, e.g. E:\Temp
* Where aupr2ap198nabwi  is the server you are logged in to, and the name of the CSV file
* The script will now execute, and display info and/or error messages to the console
* The Server Manager will launch to test your admin and/or the service account has admin rights
* Close the Server Manager  application, and the script will continue
* Once the script has finished, open the log file pre-install-checks.html ,  which will show all passes as GOOD, and any failures as ERROR

