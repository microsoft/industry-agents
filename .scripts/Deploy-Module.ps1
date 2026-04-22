# Common Scripts Ready 

# local managed -> online environment as managed to downstream environments
# use this script to deploy the latest managed solution to downstream environments
# will not deploy the umanaged solution to the development environment, use Push-Module for that

$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

# Get the full config to access module configurations
$fullConfig = Get-DeploymentConfig
$currentTenant = $null

# Start the loop for module selection and deployment
do {
    # Modules are organized in category folders
    Write-Host ""
    Write-Host "Select module to deploy:"
    $moduleWithCategory = Select-ModuleWithCategory -projectRoot $projectRoot
    
    if ($null -eq $moduleWithCategory -or $moduleWithCategory -eq "") {
        break
    }
    
    $allModules = Get-AllModulePaths -projectRoot $projectRoot
    $modulePath = $allModules[$moduleWithCategory]
    $module = Split-Path $moduleWithCategory -Leaf

    if ($module -ne "") {
        Write-Host ""
        Write-Host "Deploying module: $module" -ForegroundColor Cyan

        # Get module configuration
        $moduleConfig = if ($fullConfig.Modules.$module) {
            $fullConfig.Modules.$module
        } else {
            $fullConfig.DefaultModule
        }
        
        # Get the deployment (tenant) for this module
        $deploymentConfig = $fullConfig.Deployments.($moduleConfig.Tenant)
        
        # Connect to tenant if not already connected or if tenant changed
        if ($currentTenant -ne $moduleConfig.Tenant) {
            Write-Host ""
            Write-Host "Connecting to tenant: $($deploymentConfig.Tenant)" -ForegroundColor Cyan
            Connect-DataverseTenant -authProfile $deploymentConfig.Tenant
            $currentTenant = $moduleConfig.Tenant
        }

        # Get deployment targets for this module
        $deploymentTargets = Get-ModuleDeploymentTargets -ModuleName $module -DeploymentConfig $deploymentConfig
        
        $firstDeploy = $true
        foreach ($targetEnv in $deploymentTargets) {
            Write-Host ""
            Write-Host "Deploying to: $targetEnv" -ForegroundColor Cyan
            pac org select --environment $targetEnv
            
            if ($firstDeploy) {
                # Build on first deployment
                Deploy-Solution $modulePath -Managed -AutoConfirm
                $firstDeploy = $false
            } else {
                # Skip build for subsequent deployments
                Deploy-Solution $modulePath -Managed -SkipBuild -AutoConfirm
            }
        }

        Write-Host ""
        Write-Host "Completed deployment of module: $module" -ForegroundColor Green
    }
} while ($module -ne "") # Continue looping until the input is an empty string

Write-Host "All deployments complete." -ForegroundColor Green