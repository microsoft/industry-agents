# Common Scripts Ready 

# Builds the module only, does not deploy

$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

# Modules are organized in category folders
Write-Host ""
Write-Host "Select module to build:"
$moduleWithCategory = Select-ModuleWithCategory -projectRoot $projectRoot

if ($null -eq $moduleWithCategory) {
    Write-Host "No module selected. Exiting." -ForegroundColor Yellow
    return
}

$allModules = Get-AllModulePaths -projectRoot $projectRoot
$modulePath = $allModules[$moduleWithCategory]

$originalDir = Get-Location
Set-Location $modulePath
dotnet build
Set-Location $originalDir

# & "${PSScriptRoot}/../.venv/Scripts/python.exe" "${PSScriptRoot}/create_erd.py" $module