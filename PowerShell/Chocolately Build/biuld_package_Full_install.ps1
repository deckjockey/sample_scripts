Write-Output "================================================================================"
Write-Output " * Job parameters:"

$name = $env:PackageName
$template = $env:template
$packageversion = $env:packageversion
$maintainername = $env:maintainername
$installFile = $env:installFile
$installertype = $env:installertype
$workspace = $env:WORKSPACE
$wordfile = "README.docx"
$GitHubFolder = $env:GitHubFolder

write-output " --> name = $name"
write-output " --> template = $template"
write-output " --> GitHubFolder = $GitHubFolder"
write-output " --> packageversion = $packageversion"
write-output " --> maintainername = $maintainername"
write-output " --> installFile = $installFile"
write-output " --> installertype = $installertype"
write-output " --> workfile = $wordfile"
write-output " --> workspace = $workspace"

if (Test-Path -Path $wordfile) {
    # file exists
} else {
   throw "ERROR: README.docx is missing, please upload the release notes in the job parameters"
}

Write-Output "================================================================================"
Write-Output " * Check for existing Choco package files:"

write-output " --> $workspace\$GitHubFolder\README.md"
#Check in package scripts exists, if they do, raise error and quit
if (Test-Path -Path $workspace\$GitHubFolder\README.md) {
    throw "ERROR: README.md file already exists!"
}

write-output " --> $workspace\$GitHubFolder\$name.nuspec"
#Check if package scripts exists, if they do, raise error and quit
if (Test-Path -Path $workspace\$GitHubFolder\$name.nuspec) {
    throw "ERROR: nuspec file already exists!"
}

write-output " --> $workspace\$GitHubFolder\tools\chocolateyInstall.ps1"
#Check in package scripts exists, if they do, raise error and quit
if (Test-Path -Path $workspace\$GitHubFolder\tools\chocolateyInstall.ps1) {
    throw "ERROR: tools\chocolateyInstall.ps1 file already exists!"
}

write-output " --> $workspace\$GitHubFolder\tools\chocolateyuninstall.ps1"
#Check in package scripts exists, if they do, raise error and quit
if (Test-Path -Path $workspace\$GitHubFolder\tools\chocolateyuninstall.ps1) {
    #throw "ERROR: tools\chocolateyuninstall.ps1 file already exists!"
}

Write-Output "================================================================================"
Write-Output " * Checking deployment.json file exists and creating tags:"
write-output " --> $workspace\$GitHubFolder\deployment.json"
#Check that deployment.json file exists, if not, raise error and quit
if (-Not (Test-Path -Path $workspace\$GitHubFolder\deployment.json)) {
    throw "ERROR: $($GitHubFolder)\deployment.json file is missing!"
} else {
  Write-Output " --> Reading file: $GitHubFolder\deployment.json"
  $deploymentObject = Get-Content -Raw -Path $workspace\$GitHubFolder\deployment.json | ConvertFrom-Json
  $deploymentObject.deployment
  Write-Output " --> Creating Release / Deployment tags:"
  # Is a backup of the  database required before the deployment of any packages?
  $DbBackup = ($deploymentObject.deployment |? tag -eq DbBackup).value
  $DbBackup = "DbBackup:" + $DbBackup
  Write-Output "   --> $DbBackup"
  # Do the  services need to be stopped before the deployment of any packages?
  $StopServicesPreInstall = ($deploymentObject.deployment |? tag -eq StopServicesPreInstall).value
  $StopServicesPreInstall = "StopServicesPreInstall:" + $StopServicesPreInstall
  Write-Output "   --> $StopServicesPreInstall"
  # Do the  services need to be starter after the deployment of any packages?
  $StartServicesPostInstall = ($deploymentObject.deployment |? tag -eq StartServicesPostInstall).value
  $StartServicesPostInstall = "StartServicesPostInstall:" + $StartServicesPostInstall
  Write-Output "   --> $StartServicesPostInstall" 
}

Write-Output "================================================================================"
Write-Output " * Extract EXE file 7z files:"
Copy-Item "$workspace\$GitHubFolder\tools\*.7z.*" "$workspace" -force -passthru
Remove-Item "$workspace\$GitHubFolder\tools\*.7z.*" -force
& "c:\Program Files\7-Zip\7z.exe" e -y "$workspace\*.7z.001"
#Check if EXE file was extracted, else raise error and quit
if (Test-Path -Path $installFile) {
  Write-Output "Copying $installFile to $workspace\$GitHubFolder\tools"
  Copy-Item $installFile "$workspace\$GitHubFolder\tools" -force -passthru
} else {
  throw "ERROR: $installFile is missing!" 
}

Write-Output "================================================================================"
Write-Output " * Create package from template:"

#copy template from Templates folder to C:\ProgramData\chocolatey\Templates
write-output " --> copy $template folder from workspace to C:\ProgramData\chocolatey\Templates"
Copy-Item ".\Templates\$template" "C:\ProgramData\chocolatey\Templates" -recurse -force -passthru

$artifactoryName = $name.ToLower()
write-output " --> choco new $name --template $template --version=$packageversion --maintainer=$maintainername installertype=$installertype maintainerrepo=https://artifactory/REPO/$artifactoryName.$packageversion.nupkg!/README.md DbBackup=$DbBackup StopServicesPreInstall=$StopServicesPreInstall StartServicesPostInstall=$StartServicesPostInstall --acceptlicense --force FullEXEFilename=$installFile"
# Generate *.nuspec, tools\chocolateyInstall.ps1 and tools\chocolateyuninstall.ps1 files using template
C:\ProgramData\chocolatey\choco.exe new $name `
    --template $template `
    --version=$packageversion `
    --maintainer=$maintainername `
    installertype=$installertype `
    maintainerrepo=https://artifactory/REPO/$artifactoryName.$packageversion.nupkg!/README.md `
    DbBackup=$DbBackup `
    StopServicesPreInstall=$StopServicesPreInstall `
    StartServicesPostInstall=$StartServicesPostInstall `
    --acceptlicense --force `
    FullEXEFilename=$installFile

if (Test-Path -Path $workspace\$name\$name.nuspec) {
   # File got created ok
} else {
   throw "ERROR: nuspec file is missing!"
}

write-output " --> copy new package install scripts to existing location"
Copy-Item "$workspace\$name\*" "$workspace\$GitHubFolder" -recurse -force -passthru

write-output " --> Delete temporary package files"
Remove-Item -Path "$workspace\$name" -Recurse -Force

write-output " --> convert word docx to README.md"
F:\Progra~1\Jenkins\Pandoc\pandoc.exe -f docx -t markdown -o $workspace\$GitHubFolder\README.md $wordfile
Remove-Item -Path $wordfile -Force 

write-output " -->  choco pack $workspace\$GitHubFolder\$name.nuspec"
C:\ProgramData\chocolatey\choco.exe pack "$workspace\$GitHubFolder\$name.nuspec" 

write-output " --> Delete temporary package files"
Remove-Item "$workspace\$installFile" -Force
Copy-Item "$workspace\*.7z.*" "$workspace\$GitHubFolder\tools" -force -passthru
Remove-Item "$workspace\*.7z.*" -Force
Remove-Item -Path "$workspace\$name" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$workspace\$GitHubFolder\tools\$installFile" -force

if (Test-Path -Path "$name.$packageversion.nupkg") {
   # File got created ok
} else {
   throw "ERROR: nupkg file is missing exists!"
}

write-output " -->  choco.exe push --source=https://artifactory/api/nuget/REPO --apikey=user:key $name.nupkg"
C:\ProgramData\chocolatey\choco.exe push --source=https://artifactory/api/nuget/REPO --apikey=user:key $name.nupkg 
write-output " -->  delete nupkg file from local host"
Remove-Item -Path "$name.$packageversion.nupkg" -Force 

Write-Output "================================================================================"
