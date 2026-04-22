# Generate the Schema File via the Configuration Migration Tool
# pac tool cmt

# Select the table(s) and field(s) that you want to include in the export

# Save the schema file under a folder in sample-data

$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

# Select deployment configuration
Write-Host ""
$deploymentConfig = Select-Deployment

# Connect to the selected tenant
Write-Host ""
Write-Host "Connecting to tenant: $($deploymentConfig.Tenant)" -ForegroundColor Cyan
Connect-DataverseTenant -authProfile $deploymentConfig.Tenant

# Select module for data export
Write-Host ""
Write-Host "Select module for data export:"
$moduleWithCategory = Select-ModuleWithCategory -projectRoot $projectRoot

if ($null -eq $moduleWithCategory -or $moduleWithCategory -eq "") {
    Write-Host "No module selected. Exiting." -ForegroundColor Yellow
    return
}

$allModules = Get-AllModulePaths -projectRoot $projectRoot
$baseModulePath = $allModules[$moduleWithCategory]
$module = Split-Path $moduleWithCategory -Leaf

# Determine target environment based on module configuration
$targetEnv = Get-ModuleDevelopmentEnvironment -ModuleName $module -DeploymentConfig $deploymentConfig

# Connect to the determined environment
Write-Host ""
Write-Host "Connecting to environment: $targetEnv" -ForegroundColor Cyan
Connect-DataverseEnvironment -envName $targetEnv

$sampleDataPath = Join-Path $baseModulePath "sample-data"

# Ensure the sample-data directory exists
if (-not (Test-Path $sampleDataPath)) {
    New-Item -ItemType Directory -Path $sampleDataPath -Force
    Write-Host "Created directory: $sampleDataPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "Exporting data for module: $module" -ForegroundColor Cyan
pac data export --schemaFile "$sampleDataPath/schema.xml" --dataFile "$sampleDataPath/data.zip" -o

Write-Host ""
Write-Host "Data export complete!" -ForegroundColor Green