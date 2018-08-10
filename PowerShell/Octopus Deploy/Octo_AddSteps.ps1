Param(
  [string] $apiKey = "API-xxxxxxxxx",
  [string] $octopusURI = "http://localhost:8081",
  [string] $octopusDLL = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll",
  [string] $projectName = "test"
)

Write-Output "================================================================================"
Write-Output " * Job parameters:"

$projectName = $env:projectName
$UnInstallPackages = $env:UnInstallPackages
$InstallPackages = $env:InstallPackages
$ReleaseNotes = $env:ReleaseNotes
$jobtargetRole = $env:targetRole 
write-output " --> projectName = $projectName"
write-output " --> UnInstallPackages = $UnInstallPackages"
write-output " --> InstallPackages = $InstallPackages"
write-output " --> ReleaseNotes = $ReleaseNotes"
write-output " --> jobtargetRole = $jobtargetRole"

$ErrorActionPreference = "Stop"

Write-Output "================================================================================"
Write-Output " * Getting package parameters:"

$CreateStepBasedOnStepTemplate_command = ".\Octo_CreateStepBasedOnStepTemplate.ps1"
$CreateManualStep_command = ".\Octo_CreateManualStep.ps1"

$DbBackup = $false
$StopServicesPreInstall = $false
$StartServicesPostInstall = $false
$SystemSpecificRules = $false
$SettlementRules = $false
$LoadHotFixes = $false
$RestartServicesPostRules = $false
$SystemSpecificRulesVersion = "N/A"
$SettlementRulesVersion = "N/A"
$SystemSpecificRulesPackage = "N/A"
$SystemSpecificRulesLongVersion = "N/A"
$FullRelease = $false
$DefaultUnInstallPackagesProcessed = $false
$DefaultUnInstallFullProcessed  = $false
$MutipleFullReleases = $false

write-output " --> DbBackup = $DbBackup"
write-output " --> StopServicesPreInstall = $StopServicesPreInstall"
write-output " --> StartServicesPostInstall = $StartServicesPostInstall"

if ($ReleaseNotes) {
    $ReleaseNotesProvided = $true
} else {
    $ReleaseNotesProvided = $false
    $ReleaseNotes = "**This release contains the following steps:** `r`n`r`n" 
}

if ($UnInstallPackages -or $InstallPackages) {

    Write-Output "================================================================================"
    if ($UnInstallPackages) {
        Write-Output " * Packages to be uninstalled:" 
        $UnInstallPackages = $UnInstallPackages.Split("`n")
        Write-Output " --> Package count = $($UnInstallPackages.Count)"

         foreach ($package in $UnInstallPackages) {
           $package = $package.Split(" ")
           $packagename = $package[0]
           $packageversion = $package[1]
           Write-Output "   --> Package name = $($packagename) , Package version = $($packageversion)"
         }
    } else {
        Write-Output " * No Packages provided to be uninstalled.  Packages provided to be installed will be uninstalled in reverse order."
        $DefaultUnInstallPackages =  $InstallPackages.Split("`n`r")
        if ($DefaultUnInstallPackages) {
            foreach ($package in $DefaultUnInstallPackages) {
              $package = $package.Split(" ")
              $packagename = $package[0]
              $packageversion = $package[1]
              if ($packagename -like '*-full') { 
                  $FullRelease = $true
              }
            }
            [array]::Reverse($DefaultUnInstallPackages)
            Write-Output " * Packages to be uninstalled:" 
            $DefaultUnInstallPackages
        }
    }

    Write-Output "================================================================================"
    if ($InstallPackages) {
        Write-Output " * Packages to be installed:" 
        $InstallPackages = $InstallPackages.Split("`n`r")
        Write-Output " --> Package count = $($InstallPackages.Count)"

        foreach ($package in $InstallPackages) {
          $package = $package.Split(" ")
          $packagename = $package[0]
          $packageversion = $package[1]
          if ($packagename) {
            Write-Output "   --> Package name = '$($packagename)' , Package version = '$($packageversion)'"
            Write-output "https://artifactory/api/storage/REPO/$($packagename).$($packageversion).nupkg?properties=nuget.tags"
            F:\curl.exe -s -u user:apikey -X GET "https://artifactory/api/storage/REPO/$($packagename).$($packageversion).nupkg?properties=nuget.tags" -k -o "$($packagename).$($packageversion).json"
            Write-Output " * Reading deployment file: $($packagename).$($packageversion).json"
            $deploymentObject = Get-Content -Raw -Path "$($packagename).$($packageversion).json" | ConvertFrom-Json
            Remove-Item -Path "$($packagename).$($packageversion).json"
            $deploymenttags = $deploymentObject.properties.'nuget.tags' | Out-String 
            $deploymenttags = $deploymenttags.Split(" ")
            if ($deploymenttags.count -eq 7) {

                # DbBackup:YES or NO
                $deploymenttags[0]
                $tag = $deploymenttags[0].Split(":")
                if ($tag[1].Length -gt 2) {
                    if ($tag[1].SubString(0,3) -eq "YES") {
                        $DbBackup = $true
                    }
                }
                # StopServicesPreInstall:YES or NO
                $deploymenttags[1]
                $tag = $deploymenttags[1].Split(":")
                if ($tag[1].Length -gt 2) {
                    if ($tag[1].SubString(0,3) -eq "YES") {
                        $StopServicesPreInstall = $true
                    }
                }
                # StartServicesPostInstall:YES or NO
                $deploymenttags[2]
                $tag = $deploymenttags[2].Split(":")
                if ($tag[1].Length -gt 2) {
                    if ($tag[1].SubString(0,3) -eq "YES") {
                        $StartServicesPostInstall = $true
                    }
                }               
            } else {
                throw "Missing tags in package!"

            }
          }
        }

        if ($StartServicesPostInstall -eq $true) {
        # set to false if services are being restarted after install, as the hotfixes will be loaded anyway
        $LoadHotFixes = $false
        } else { 
           $LoadHotFixes = $true
        }
    
        Write-Output "================================================================================"
        Write-Output "   --> DbBackup is now $($DbBackup)"
        Write-Output "   --> StopServicesPreInstall is now $($StopServicesPreInstall)"
        Write-Output "   --> StartServicesPostInstall is now $($StartServicesPostInstall)"

    } else {
        Write-Output " * No Packages to be installed"
    }

} else {
    Write-Output " * No packages to be uninstalled/installed"
}

Write-Output "================================================================================"
Write-Output " * Add steps to release process:"

if ($StopServicesPreInstall -eq $true) {
    Write-Output "  --> Create step to Stop Services on web server..."
    $env:stepTemplateName = $env:StopServicesStepTemplate
    $env:stepName = $env:StopServicesStepTemplate
    $env:ChocolateyPackageId = ""
    $env:ChocolateyPackageVersion = ""
    Write-Output $CreateStepBasedOnStepTemplate_command
    . $CreateStepBasedOnStepTemplate_command 
    if ($ReleaseNotesProvided -eq $false) {
        $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
    }

    Write-Output "  --> Create step to Stop Service on web server..."
    $env:stepTemplateName = $env:WindowsServiceStopStepTemplate
    $env:stepName = $env:WindowsServiceStopStepTemplate
    $env:ChocolateyPackageId = ""
    $env:ChocolateyPackageVersion = ""
    Write-Output $CreateStepBasedOnStepTemplate_command
    . $CreateStepBasedOnStepTemplate_command 
    if ($ReleaseNotesProvided -eq $false) {
        $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
    }    
}

if ($DbBackup -eq $true) {
    Write-Output "  --> Create step to Backup database..."
    $env:stepTemplateName = $env:SQLBackupDatabaseStepTemplate
    $env:stepName = $env:SQLBackupDatabaseStepTemplate
    $env:ChocolateyPackageId = ""
    $env:ChocolateyPackageVersion = ""
    Write-Output $CreateStepBasedOnStepTemplate_command
    . $CreateStepBasedOnStepTemplate_command 
    if ($ReleaseNotesProvided -eq $false) {
        $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
    }        
}

if ($UnInstallPackages) {
    Write-Output "  --> Create steps to uninstall packages..."
    Write-Output " * Packages to be uninstalled:" 
    $UnInstallPackages = $UnInstallPackages.Split("`n")
    Write-Output " --> Package count = $($UnInstallPackages.Count)"
    foreach ($package in $UnInstallPackages) {
        $package = $package.Split(" ")
        $packagename = $package[0]
        Write-Output "   --> Package name = $($packagename)"
        $env:stepTemplateName = $env:ChocolateyUninstallPackageStepTemplate
        $env:stepName = "Chocolatey - Uninstall Package - $($packagename)"
        $env:ChocolateyPackageId = $packagename
        $env:ChocolateyPackageVersion = ""
        Write-Output $CreateStepBasedOnStepTemplate_command
        . $CreateStepBasedOnStepTemplate_command 
        if ($ReleaseNotesProvided -eq $false) {
            $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
        }        
    }
} else {
    if ($env:ChocolateyUninstallPackageStepTemplate -eq "Delete Folder and Service") {
        Write-Output "  --> Create step to Manually Delete Folder and Service..."
        $env:stepTemplateName = $env:ChocolateyUninstallPackageStepTemplate
        $env:stepName = $env:ChocolateyUninstallPackageStepTemplate
        $env:ChocolateyPackageId = ""
        $env:ChocolateyPackageVersion = ""
        Write-Output $CreateStepBasedOnStepTemplate_command
        . $CreateStepBasedOnStepTemplate_command 
        if ($ReleaseNotesProvided -eq $false) {
            $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
        }        
    } else {
        if ($DefaultUnInstallPackages) {
            Write-Output "  --> Create default steps to uninstall packages..."
            Write-Output " * Packages to be uninstalled:" 
            $DefaultUnInstallPackages = $DefaultUnInstallPackages.Split("`n")
            Write-Output " --> Package count = $($DefaultUnInstallPackages.Count)"
            if ($DefaultUnInstallPackagesProcessed -eq $false -and $FullRelease -eq $true) {
                $env:stepTemplateName = $env:DeleteUpdatePackagesfromChocolateyStepTemplate
                $env:stepName = $env:DeleteUpdatePackagesfromChocolateyStepTemplate
                Write-Output $CreateStepBasedOnStepTemplate_command
                . $CreateStepBasedOnStepTemplate_command
                $DefaultUnInstallPackagesProcessed = $true
                if ($ReleaseNotesProvided -eq $false) {
                    $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
                }
            }
            foreach ($package in $DefaultUnInstallPackages) {
                $package = $package.Split(" ")
                $packagename = $package[0]
                Write-Output "   --> Package name = $($packagename)"
                if ($packagename -like '*-update-*') {  
                    if ($DefaultUnInstallPackagesProcessed -eq $false -and $FullRelease -eq $true) {
                        $env:stepTemplateName = $env:DeleteUpdatePackagesfromChocolateyStepTemplate
                        $env:stepName = $env:DeleteUpdatePackagesfromChocolateyStepTemplate
                        Write-Output $CreateStepBasedOnStepTemplate_command
                        . $CreateStepBasedOnStepTemplate_command
                        $DefaultUnInstallPackagesProcessed = $true
                        if ($ReleaseNotesProvided -eq $false) {
                            $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
                        }
                    }
                } elseif ($packagename -like '*-full') {
                    if ($DefaultUnInstallFullProcessed -eq $false -and $FullRelease -eq $true) {
                        $env:stepTemplateName = $env:ChocolateyUninstallPackageStepTemplate
                        $env:stepName = "Chocolatey - Uninstall Package - $($packagename)"
                        $env:ChocolateyPackageId = $packagename
                        $env:ChocolateyPackageVersion = ""
                        Write-Output $CreateStepBasedOnStepTemplate_command
                        . $CreateStepBasedOnStepTemplate_command 
                        $DefaultUnInstallFullProcessed = $true
                        if ($ReleaseNotesProvided -eq $false) {
                            $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
                        }   
                    }
                } else {
                    $env:stepTemplateName = $env:ChocolateyUninstallPackageStepTemplate
                    $env:stepName = "Chocolatey - Uninstall Package - $($packagename)"
                    $env:ChocolateyPackageId = $packagename
                    $env:ChocolateyPackageVersion = ""
                    Write-Output $CreateStepBasedOnStepTemplate_command
                    . $CreateStepBasedOnStepTemplate_command 
                    if ($ReleaseNotesProvided -eq $false) {
                        $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
                    }                    
                }
            }
        }
    }
}

if ($InstallPackages) {
    Write-Output "  --> Create steps to install packages..."
    Write-Output " * Packages to be installed:" 
    $InstallPackages = $InstallPackages.Split("`n")
    Write-Output " --> Package count = $($InstallPackages.Count)"
    foreach ($package in $InstallPackages) {
        $package = $package.Split(" ")
        $packagename = $package[0]
        $packageversion = $package[1]
        Write-Output "   --> Package name = $($packagename) , Package version = $($packageversion)"
        if ($packagename -like '*-full') {
            if ($MutipleFullReleases -eq $true) {
                $env:stepTemplateName = $env:ChocolateyInstallPackageStepTemplate
                $env:stepName = "Chocolatey - Force Install Package - $($packagename) $($packageversion)"
                $env:ChocolateyPackageId = $packagename
                $env:ChocolateyPackageVersion = $packageversion
                $env:ChocolateyForce = '-f'
            } else {
                $MutipleFullReleases = $true
                $env:stepTemplateName = $env:ChocolateyInstallPackageStepTemplate
                $env:stepName = "Chocolatey - Install Package - $($packagename) $($packageversion)"
                $env:ChocolateyPackageId = $packagename
                $env:ChocolateyPackageVersion = $packageversion
                $env:ChocolateyForce = ''
            }
        } else {
            $env:stepTemplateName = $env:ChocolateyInstallPackageStepTemplate
            $env:stepName = "Chocolatey - Install Package - $($packagename) $($packageversion)"
            $env:ChocolateyPackageId = $packagename
            $env:ChocolateyPackageVersion = $packageversion
            $env:ChocolateyForce = ''
        }
        Write-Output $CreateStepBasedOnStepTemplate_command
        . $CreateStepBasedOnStepTemplate_command 
        if ($ReleaseNotesProvided -eq $false) {
            $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
        } 
    }
}

if ($StartServicesPostInstall -eq $true) {
    Write-Output "  --> Create step to Start Services on web server..."
    $env:stepTemplateName = $env:StartServicesStepTemplate
    $env:stepName = $env:StartServicesStepTemplate
    $env:ChocolateyPackageId = ""
    $env:ChocolateyPackageVersion = ""
    Write-Output $CreateStepBasedOnStepTemplate_command
    . $CreateStepBasedOnStepTemplate_command 
    if ($ReleaseNotesProvided -eq $false) {
        $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
    }    

    Write-Output "  --> Create step to Start Service on web server..."
    $env:stepTemplateName = $env:WindowsServiceStartStepTemplate
    $env:stepName = $env:WindowsServiceStartStepTemplate
    $env:ChocolateyPackageId = ""
    $env:ChocolateyPackageVersion = ""
    Write-Output $CreateStepBasedOnStepTemplate_command
    . $CreateStepBasedOnStepTemplate_command 
    if ($ReleaseNotesProvided -eq $false) {
        $ReleaseNotes = "$($ReleaseNotes) 1. $($env:stepName) `r`n" 
    }    
}


if ($ReleaseNotesProvided -eq $false) {
    Write-Output "================================================================================"
    Write-Output "  --> Release Notes created from steps..."
    $ReleaseNotes | Out-File -filepath "F:\ReleaseNotes.txt"
    $ReleaseNotes
}

Write-Output "================================================================================"

