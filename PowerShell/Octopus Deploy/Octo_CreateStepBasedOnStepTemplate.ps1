Param(
  [string] $apiKey = "API-xxxxxxxx",
  [string] $octopusURI = "http://localhost:8081",
  [string] $octopusDLL = "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll",
  [string] $projectName = "test",
  [string] $stepTemplateName = "Chocolatey - Install Package",
  [string] $stepName = "Chocolatey - Install Package (7zip.install)",
  [string] $targetRole = "App-Server",
  [string] $ChocolateyPackageId = "7zip.install",
  [string] $ChocolateyPackageVersion = "18.5"
)

Write-Output "================================================================================"
Write-Output " * Job parameters:"

$projectName = $env:projectName
$stepTemplateName = $env:stepTemplateName
$stepName = $env:stepName
$targetRole = $env:targetRole
$ChocolateyPackageId = $env:ChocolateyPackageId
$ChocolateyPackageVersion = $env:ChocolateyPackageVersion
$ChocolateyForce = $env:ChocolateyForce
write-output " --> projectName = $projectName"
write-output " --> stepTemplateName = $stepTemplateName"
write-output " --> stepName = $stepName"
write-output " --> targetRole = $targetRole"
write-output " --> ChocolateyPackageId = $ChocolateyPackageId"
write-output " --> ChocolateyPackageVersion = $ChocolateyPackageVersion"
write-output " --> ChocolateyForce = $ChocolateyForce"

$ErrorActionPreference = "Stop"

# You can this dll from your Octopus Server/Tentacle installation directory or from https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path $octopusDLL

$endpoint = New-Object Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey 
$repository = New-Object Octopus.Client.OctopusRepository $endpoint

$project = $repository.Projects.FindByName($projectName)
$process = $repository.DeploymentProcesses.Get($project.DeploymentProcessId)

$actionTemplate = $repository.ActionTemplates.FindByName($stepTemplateName)

$step = New-Object Octopus.Client.Model.DeploymentStepResource
$step.Name = $stepName
$step.Condition = [Octopus.Client.Model.DeploymentStepCondition]::Success
$step.Properties["Octopus.Action.TargetRoles"] = $targetRole

$action = New-Object Octopus.Client.Model.DeploymentActionResource
$action.Name = $stepName
$action.ActionType = $actionTemplate.ActionType

#Generic properties
foreach ($property in $actionTemplate.Properties.GetEnumerator()) {
    $action.Properties[$property.Key] = $property.Value
}

$action.Properties["Octopus.Action.Template.Id"] = $actionTemplate.Id
$action.Properties["Octopus.Action.Template.Version"] = $actionTemplate.Version

#Step template specific properties
foreach ($parameter in $actionTemplate.Parameters) {
    if ($parameter.Name -eq "ChocolateyPackageId") {
        $action.Properties[$parameter.Name] = $ChocolateyPackageId
    }
    if ($parameter.Name -eq "ChocolateyPackageVersion") {
        $action.Properties[$parameter.Name] = $ChocolateyPackageVersion
    }
    if ($parameter.Name -eq "ChocolateyForce") {
        $action.Properties[$parameter.Name] = $ChocolateyForce
    }    
}

$step.Actions.Add($action)
$process.Steps.Add($step)

Write-Output "Created Step:"
$step

$repository.DeploymentProcesses.Modify($process)
