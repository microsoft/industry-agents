# Common Scripts Ready

# Synchronizes the latest solution from the online environment and deploys it to downstream environments
# This script combines Sync-Module and Deploy-Module functionality

$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

# Get the full config to access module configurations
$fullConfig = Get-DeploymentConfig

# Start the loop for module selection and deployment
do {
    # Modules are organized in category folders
    Write-Host ""
    Write-Host "Select module to sync and deploy:"
    $moduleWithCategory = Select-ModuleWithCategory -projectRoot $projectRoot
    
    if ($null -eq $moduleWithCategory -or $moduleWithCategory -eq "") {
        break
    }
    
    $allModules = Get-AllModulePaths -projectRoot $projectRoot
    $modulePath = $allModules[$moduleWithCategory]
    $module = Split-Path $moduleWithCategory -Leaf

    if ($module -ne "") {
        Write-Host ""
        Write-Host "Processing module: $module" -ForegroundColor Cyan

        # Get module configuration
        $moduleConfig = if ($fullConfig.Modules.$module) {
            $fullConfig.Modules.$module
        } else {
            $fullConfig.DefaultModule
        }
        
        # Get the deployment (tenant) for this module
        $deploymentConfig = $fullConfig.Deployments.($moduleConfig.Tenant)
        
        # Connect to tenant for syncing
        Write-Host ""
        Write-Host "Connecting to tenant: $($deploymentConfig.Tenant)" -ForegroundColor Cyan
        Connect-DataverseTenant -authProfile $deploymentConfig.Tenant

        # Determine source environment for sync based on module configuration
        $sourceEnv = Get-ModuleDevelopmentEnvironment -ModuleName $module -DeploymentConfig $deploymentConfig
        
        # Connect to the source environment and sync
        Write-Host ""
        Write-Host "Syncing from environment: $sourceEnv" -ForegroundColor Cyan
        Connect-DataverseEnvironment -envName $sourceEnv
        
        Sync-Module $modulePath

        Write-Host ""
        Write-Host "Sync complete. Starting deployment..." -ForegroundColor Green

        # Get deployment targets for this module
        $deploymentTargets = Get-ModuleDeploymentTargets -ModuleName $module -DeploymentConfig $deploymentConfig
        
        if ($null -eq $deploymentTargets -or $deploymentTargets.Count -eq 0) {
            Write-Host "No deployment targets configured for module: $module" -ForegroundColor Yellow
        } else {
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
            Write-Host "Completed sync and deployment of module: $module" -ForegroundColor Green
        }
    }
} while ($module -ne "") # Continue looping until the input is an empty string

Write-Host "All sync and deploy operations complete." -ForegroundColor Green
