<#
.SYNOPSIS
Deploy all modules as managed solutions to a selected Dataverse tenant/environment.

.DESCRIPTION
This script connects to a Dataverse tenant and environment using the shared
functions in `Util.ps1`, then deploys every folder inside the `modules`
directory as a managed solution. The deployment order ensures `core` is
installed first, followed by `process-and-tasking`, and then the remaining
modules in alphabetical order.

.NOTES
Uses: Connect-DataverseTenant, Connect-DataverseEnvironment, Deploy-Solution
from `.scripts\Util.ps1` (same helpers used by `Ship-Module.ps1`).
#>

[CmdletBinding(SupportsShouldProcess=$true)]

$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

Write-Host "Connecting to Dataverse tenant and environment..." -ForegroundColor Cyan

# select deployment configuration
Write-Host ""
$deploymentConfig = Select-Deployment

# connect to the selected tenant
Write-Host ""
Write-Host "Connecting to tenant: $($deploymentConfig.Tenant)"
Connect-DataverseTenant -authProfile $deploymentConfig.Tenant

# allow user to select target environment from the deployment config
Write-Host ""
Write-Host "Available Environments:"
$envNames = $deploymentConfig.Environments.PSObject.Properties.Name
$selectedEnvKey = Select-ItemFromList $envNames
$targetEnv = $deploymentConfig.Environments.$selectedEnvKey

Write-Host ""
Write-Host "Connecting to environment: $targetEnv"
Connect-DataverseEnvironment -envName $targetEnv

# Discover all modules across category folders
Write-Host ""
Write-Host "Collecting modules from all categories..." -ForegroundColor Cyan

$allModulePaths = Get-AllModulePaths -projectRoot $projectRoot

if ($allModulePaths.Count -eq 0) {
    Write-Host "No modules found in the repository." -ForegroundColor Red
    return
}

# Ensure deployment order: core first, then process-and-tasking, then the rest
# Note: these can now be in different categories (e.g., cross-industry/core, government/gov-core)
$orderedFirst = @('cross-industry/core', 'cross-industry/process-automation')

# Build final list preserving the required order
$toDeploy = @()
foreach ($m in $orderedFirst) {
    if ($allModulePaths.ContainsKey($m)) {
        $toDeploy += $m
    } else {
        Write-Host "Note: ordered module '$m' not found; skipping." -ForegroundColor Yellow
    }
}

$remaining = $allModulePaths.Keys | Where-Object { $orderedFirst -notcontains $_ } | Sort-Object
$toDeploy += $remaining

Write-Host "Deployment order:" -ForegroundColor Green
$toDeploy | ForEach-Object { Write-Host " - $_" }

foreach ($moduleKey in $toDeploy) {
    Write-Host "`nDeploying module: $moduleKey" -ForegroundColor Cyan
    $modulePath = $allModulePaths[$moduleKey]
    if (-not (Test-Path $modulePath)) {
        Write-Host "Module folder missing: $modulePath" -ForegroundColor Yellow
        continue
    }
    
    $module = Split-Path $moduleKey -Leaf

    # Use Deploy-Solution helper from Util.ps1 (same as Ship-Module.ps1)
    # Guard against $PSCmdlet being $null (can happen when dot-sourced); default to proceeding
    $shouldProceed = $true
    if ($PSCmdlet) {
        $shouldProceed = $PSCmdlet.ShouldProcess($moduleKey, "Deploy managed solution")
    }

    if ($shouldProceed) {
        Deploy-Solution $modulePath -Managed -AutoConfirm
    }
}

Write-Host "All deployments processed." -ForegroundColor Green
