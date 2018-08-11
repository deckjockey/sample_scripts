# Octopus Deploy Automation Scripts


A collection of scripts, using either the Octopus DLL Client or REST API, to automate the process of creating artifacts in Octopus Deploy:

## Octo_AddSteps.ps1

* Uses Octopus.Client.dll
* Adds steps to a release, based on supplied parameters such as Uninstall packages, Install packages from a jenkins job, including release notes
* Calls other scripts (listed below) as required 


## Octo_CreateManualStep.ps1

* Uses Octopus.Client.dll
* Will add a manual intervention step to the process, with the name and instructions supplied as parameters

## Octo_CreateRelease.ps1

* Uses REST API
* Will create a new release in a project, with the version number and release notes provided as a parameter 

## Octo_CreateScriptStep.ps1

* Uses Octopus.Client.dll
* Will add a powershell script step to the process, with the name and details supplied as parameters


## Octo_CreateStepBasedOnStepTemplate.ps1

* Uses Octopus.Client.dll
* Will add a script step from a template to the process, with the template name, step name and choco package details supplied as parameters


## Octo_DeleteRelease.ps1

* Uses Octopus.Client.dll
* Will delete a release from a project, with the project name and release version supplied as parameters 

## Octo_DeleteSteps.ps1	initial version	a day ago

* Uses Octopus.Client.dll
* Will delete all process steps from a project, with the project name supplied as a parameter

## Octo_GetLastSuccessfulForProjectAndEnvironment.ps1

* Uses Octopus.Client.dll
* Display the last successful release version for a given project and environment

