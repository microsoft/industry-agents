# Common Scripts Ready

# Synchronizes changes from the online environment down to your local copy

$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

# select deployment configuration first
Write-Host ""
$deploymentConfig = Select-Deployment

# connect to the selected tenant
Write-Host ""
Write-Host "Connecting to tenant: $($deploymentConfig.Tenant)"
Connect-DataverseTenant -authProfile $deploymentConfig.Tenant

# Modules are organized in category folders
Write-Host ""
Write-Host "Select module to sync:"
$moduleWithCategory = Select-ModuleWithCategory -projectRoot $projectRoot

if ($null -eq $moduleWithCategory) {
    Write-Host "No module selected. Exiting." -ForegroundColor Yellow
    return
}

$allModules = Get-AllModulePaths -projectRoot $projectRoot
$modulePath = $allModules[$moduleWithCategory]
$module = Split-Path $moduleWithCategory -Leaf

# determine target environment based on module configuration
$targetEnv = Get-ModuleDevelopmentEnvironment -ModuleName $module -DeploymentConfig $deploymentConfig

# connect to the determined environment
Write-Host ""
Write-Host "Connecting to environment: $targetEnv"
Connect-DataverseEnvironment -envName $targetEnv

Sync-Module $modulePath
# Build-Solution "$baseFolder\$module"

# & "${PSScriptRoot}/../.venv/Scripts/python.exe" "${PSScriptRoot}/create_erd.py" $module
