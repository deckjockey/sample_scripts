# Windows Server Scripts

A collection of scripts to perform various support functions in a Windows Server with Powershell

## compliant.ps1

* This script will check that each server listed in the file: computers.txt	, has the Windows patches install as listed in the file: KBs.txt	

## createIndex.ps1

* This script will create an Index.html file, by searching through a directory and finding all files with the HTML extension


## CSVtoHTML.ps1

* This script will read a CSV file, and convert it to a HTML table, with rows highlighted using Javascript based on a cell value


## dotnet_version.ps1

* This script will check the registry entries, and display the current version of DotNet installed


## IEversion.ps1

* This script will check the registry entries, and display the current version of Internet Explorer installed


## ListADGroup.ps1

* This script will display a list of all users/sub-groups in an AD group using LDAP connection, by the group name provided


## ListADGroupByDN.ps1

* This script will display a list of all users/sub-groups in an AD group using LDAP connection, by the DN provided


## ListADUser.ps1

* This script will display a list of all groups a user is a member of, using LDAP connection


