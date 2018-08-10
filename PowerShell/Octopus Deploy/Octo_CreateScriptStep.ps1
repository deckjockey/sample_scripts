Param(
  [string] $apiKey = "API-xxxxxxxxx",
  [string] $octopusURI = "http://localhost:8081",
  [string] $octopusDLL = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll",
  [string] $projectId = "Projects-21",
  [string] $stepName = "run a script",
  [string] $targetRole = "App-Server",
  [string] $scriptBody = "Write-Host 'Hello world'"
)

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
$scriptAction.ActionType = "Octopus.Script"
$scriptAction.Name = $stepName
$scriptAction.Properties.Add("Octopus.Action.Script.ScriptBody", $scriptBody)

$step.Actions.Add($scriptAction)

$process.Steps.Add($step)

$repository.DeploymentProcesses.Modify($process)
