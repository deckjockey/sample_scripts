Param(
  [string] $apiKey = "API-xxxxxxxxx",
  [string] $octopusURI = "http://localhost:8081",
  [string] $octopusDLL = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll",
  [string] $projectId = "Projects-4",
  [string] $version = "0.0.64"
)

Write-Output "================================================================================"
Write-Output " * Job parameters:"

$version = $env:version
$projectName = $env:projectName
write-output " --> projectName = $projectName"
write-output " --> version = $version"

# http://localhost:8081/api/projects/all
if ($projectName -eq "test") {
  $projectId = "Projects-21"
} 
write-output " --> projectId = $projectId"

$ErrorActionPreference = "Stop"

# You can this dll from your Octopus Server/Tentacle installation directory or from https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path $octopusDLL

$endpoint = new-object Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey 
$repository = new-object Octopus.Client.OctopusRepository $endpoint

$releases = $repository.Releases.FindMany({param($r) $r.ProjectId -eq $projectId})
$deleted = $false

foreach ($release in $releases)
{
    if ($release.Version -eq $version) {
        $release
        $repository.Releases.Delete($release)
        $deleted = $true
    } 
}

if ($deleted -eq $false) {
    write-Output "Release $version not found!"
} else {
    Write-Output "Release $version deleted."
}
