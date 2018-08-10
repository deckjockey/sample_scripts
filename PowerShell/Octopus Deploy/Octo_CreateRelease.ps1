Param(
  [string] $apiKey = "API-xxxxxxxxxxx",
  [string] $octopusURI = "http://localhost:8081",
  [string] $octopusDLL = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll",
  [string] $projectId = "Projects-4",
  [string] $version = "0.0.64",
  [string] $ReleaseNotes = "the release notes"
)

Write-Output "================================================================================"
Write-Output " * Job parameters:"

$version = $env:version
$projectName = $env:projectName
$ReleaseNotes = $env:ReleaseNotes
write-output " --> version = $version"
write-output " --> projectName = $projectName"
write-output " --> ReleaseNotes = $ReleaseNotes"

# http://localhost:8081/api/projects/all
if ($projectName -eq "test") {
  $projectId = "Projects-21"
} 
write-output " --> projectId = $projectId"

$ErrorActionPreference = "Stop"

# You can get this dll from your Octopus Server/Tentacle installation directory or from https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path $octopusDLL

$header = @{ "X-Octopus-ApiKey" = $apiKey }

if (!$ReleaseNotes) {
  if (Test-Path -Path "F:\ReleaseNotes.txt") {
    Write-Output "  --> Release Notes created from steps..."
    $ReleaseNotes = Get-Content "F:\ReleaseNotes.txt" -raw 
    Write-Output " --> ReleaseNotes = $ReleaseNotes"
    # Release notes read from a file
    $body = @{
      ProjectId = $projectId
      ChannelId = ""
      Version = $version
      ReleaseNotes =  [System.IO.File]::ReadAllText("F:\ReleaseNotes.txt")
      SelectedPackages = @(
        @{
          StepName = ""
          Version = ""
        }
      )
    }
    Remove-Item -Path "F:\ReleaseNotes.txt" -Force -ErrorAction SilentlyContinue
  }
} else {
  # Release notes provided as parameter
  $body = @{
    ProjectId = $projectId
    ChannelId = ""
    Version = $version
    ReleaseNotes = $ReleaseNotes
    SelectedPackages = @(
      @{
        StepName = ""
        Version = ""
      }
    )
  }
}

try
{
  Invoke-WebRequest $octopusURI/api/releases?ignoreChannelRules=false -Method POST -Headers $header -Body ($body | ConvertTo-Json)
}
catch
{
  $Result = $_.Exception.Response.GetResponseStream()
  $Reader = New-Object System.IO.StreamReader($result)
  $ResponseBody = $Reader.ReadToEnd();
  $Response = $ResponseBody | ConvertFrom-Json
  $Response.Errors
}
