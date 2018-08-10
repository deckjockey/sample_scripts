##CONFIG
$OctopusURL = "http://localhost:8081" #Octopus URL
$OctopusAPIKey = "API-xxxxxxxx" #Octopus API Key

Write-Output "================================================================================"
Write-Output " * Job parameters:"

$version = $env:version
$projectName = $env:projectName
write-output " --> projectName = $projectName"
write-output " --> version = $version"

$projectName = "test"
$EnvironmentID = "Environments-1"

# http://localhost:8081/api/projects/all
if ($projectName -eq "test") {
  $projectId = "Projects-21"
}

##PROCESS##
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

#$ProjectDashboardReleases = (Invoke-WebRequest $OctopusURL/api/progression/$projectId -Method Get -Headers $header).content | ConvertFrom-Json
#$LastSuccessfullRelease = $ProjectDashboardReleases.Releases.Deployments.$EnvironmentId | ?{$_.state -eq "Success"} | select -First 1
#$LastSuccessfullRelease.ReleaseVersion

$ProjectDashboardReleases = (Invoke-WebRequest $OctopusURL/api/progression/$projectId -Method Get -Headers $header).content | ConvertFrom-Json
foreach ($Release in $ProjectDashboardReleases.Releases.Release  ) {
    $Release.Version
}
