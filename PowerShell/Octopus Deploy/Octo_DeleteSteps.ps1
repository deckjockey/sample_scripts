Param(
  [string] $apiKey = "API-xxxxxx",
  [string] $octopusURI = "http://localhost:8081",
  [string] $octopusDLL = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll",
  [string] $projectName = "test"
)

Write-Output "================================================================================"
Write-Output " * Job parameters:"

$projectName = $env:projectName
write-output " --> projectName = $projectName"

$ErrorActionPreference = "Stop"

# You can this dll from your Octopus Server/Tentacle installation directory or from https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path $octopusDLL

$endpoint = new-object Octopus.Client.OctopusServerEndpoint $octopusURI, $apiKey 
$repository = new-object Octopus.Client.OctopusRepository $endpoint

$project = $repository.Projects.FindByName($projectName)
$process = $repository.DeploymentProcesses.Get($project.DeploymentProcessId)

$measure = $process.Steps | measure
$counter = $measure.Count
Write-Output "There were $counter steps found" 

if ($counter -gt 0) {
    foreach ($_ in 1..$counter){
        $step = $process.Steps | Select-Object -first 1
        $step
        Write-Output "Deleting step from deployment..."
        $process.Steps.Remove($step);
        Write-Output " "
    }
    $repository.DeploymentProcesses.Modify($process);
}

Write-Output "================================================================================"
