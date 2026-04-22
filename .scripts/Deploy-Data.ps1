# Deploy-Data.ps1
#
# Purpose:
#   Interactive helper to import sample data for a selected module into Dataverse
#   using the Power Platform CLI (pac). The script connects to the tenant and
#   environment, then asks which module to import sample data from. It expects
#   a `sample-data` folder within each module that contains a `data.zip` file.
#
# Usage:
#   From the repository root run: .\.scripts\Deploy-Data.ps1
#
# Assumptions:
#   - Helper functions are defined in `.scripts\Util.ps1` for authentication
#     and module selection.
#   - The repository contains category folders (cross-industry, government)
#     with module subfolders that include `sample-data`.
#   - `pac` (Power Platform CLI) is installed and available on PATH.
#   - A deployment configuration file exists at `.config\deployments.json`
#     containing tenant and environment information.

$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

# Select deployment configuration
Write-Host ""
$deploymentConfig = Select-Deployment

# Connect to the selected tenant
Write-Host ""
Write-Host "Connecting to tenant: $($deploymentConfig.Tenant)" -ForegroundColor Cyan
Connect-DataverseTenant -authProfile $deploymentConfig.Tenant

# Allow user to select target environment from the deployment config
Write-Host ""
Write-Host "Available Environments:"
$envNames = $deploymentConfig.Environments.PSObject.Properties.Name
$selectedEnvKey = Select-ItemFromList $envNames
$targetEnv = $deploymentConfig.Environments.$selectedEnvKey

# Connect to the selected environment
Write-Host ""
Write-Host "Connecting to environment: $targetEnv" -ForegroundColor Cyan
Connect-DataverseEnvironment -envName $targetEnv

# Get all available module paths once
$allModules = Get-AllModulePaths -projectRoot $projectRoot

while ($true) {
    # Select module for data import
    Write-Host ""
    Write-Host "Select module to import data from (or cancel to exit):"
    $moduleWithCategory = Select-ModuleWithCategory -projectRoot $projectRoot

    if ($null -eq $moduleWithCategory -or $moduleWithCategory -eq "") {
        Write-Host "Exiting data import." -ForegroundColor Yellow
        break
    }

    $baseModulePath = $allModules[$moduleWithCategory]
    $module = Split-Path $moduleWithCategory -Leaf
    $sampleDataPath = Join-Path $baseModulePath "sample-data"
    $dataZipPath = Join-Path $sampleDataPath "data.zip"

    # Check if sample data exists
    if (-not (Test-Path $dataZipPath)) {
        Write-Host "Warning: No data.zip found at $sampleDataPath" -ForegroundColor Yellow
        Write-Host "Skipping import for module: $module" -ForegroundColor Yellow
        continue
    }

    Write-Host ""
    Write-Host "Importing data for module: $module" -ForegroundColor Cyan
    pac data import --data $dataZipPath --verbose

    Write-Host ""
    Write-Host "Data import complete for module: $module" -ForegroundColor Green
}

Write-Host ""
Write-Host "All data imports complete." -ForegroundColor Green