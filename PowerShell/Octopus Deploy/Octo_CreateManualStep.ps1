Param(
  [string] $apiKey = "API-xxxxxxx",
  [string] $octopusURI = "http://localhost:8081",
  [string] $octopusDLL = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll",
  [string] $projectId = "Projects-21",
  [string] $stepName = "Manual intervention",
  [string] $targetRole = "",
  [string] $instructions = "instructions go here"
)

Write-Output "================================================================================"
Write-Output " * Job parameters:"

$projectName = $env:projectName
$stepName = $env:stepName
$targetRole = $env:targetRole
$instructions = $env:instructions
write-output " --> projectName = $projectName"
write-output " --> stepName = $stepName"
write-output " --> targetRole = $targetRole"
write-output " --> instructions = $instructions"

# http://localhost:8081/api/projects/all
if ($projectName -eq "test") {
  $projectId = "Projects-21"
} 
write-output " --> projectId = $projectId"

# You can this dll from your Octopus Server/Tentacle installation directory or from https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path $octopusDLL

$endpoint = New-Object Octopus.Client.OctopusServerEndpoint $octopusURI,$apiKey 
$repository = New-Object Octopus.Client.OctopusRepository $endpoint

$project = $repository.Projects.Get($projectId)
$process = $repository.DeploymentProcesses.Get($project.DeploymentProcessId)

$step = New-Object Octopus.Client.Model.DeploymentStepResource
$step.Name = $stepName
$step.Condition = [Octopus.Client.Model.DeploymentStepCondition]::Success
$step.Properties.Add("Octopus.Action.TargetRoles", $targetRole)

$scriptAction = New-Object Octopus.Client.Model.DeploymentActionResource
$scriptAction.ActionType = "Octopus.Manual"
$scriptAction.Name = $stepName
$scriptAction.Properties.Add("Octopus.Action.Manual.Instructions", $instructions)

$step.Actions.Add($scriptAction)

$process.Steps.Add($step)

$repository.DeploymentProcesses.Modify($process)
