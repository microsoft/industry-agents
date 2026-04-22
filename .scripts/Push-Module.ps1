# Common Scripts Ready 

# local managed -> online environment as UNMANAGED to DEV environment
# use this script to deploy the latest umanaged solution to dev environment
# will not deploy the umanaged solution to the development environment, use Push-Module for that

$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

Write-Host "Warning - This operation will overwrite the unmanaged solution in your environment."
if ($true -eq (Confirm-Next "Proceed (y/n)?")) {

    # Modules are organized in category folders
    Write-Host ""

    # select deployment configuration once at the start
    Write-Host ""
    $deploymentConfig = Select-Deployment

    # connect to the selected tenant once
    Write-Host ""
    Write-Host "Connecting to tenant: $($deploymentConfig.Tenant)"
    Connect-DataverseTenant -authProfile $deploymentConfig.Tenant

    # Start the loop for module selection and deployment
    do {
        # ask for which module to push
        Write-Host ""
        Write-Host "Select module to push:"
        $moduleWithCategory = Select-ModuleWithCategory -projectRoot $projectRoot
        
        if ($null -eq $moduleWithCategory -or $moduleWithCategory -eq "") {
            break
        }
        
        $allModules = Get-AllModulePaths -projectRoot $projectRoot
        $modulePath = $allModules[$moduleWithCategory]
        $module = Split-Path $moduleWithCategory -Leaf

        if ($module -ne "") {
            # determine target environment based on module configuration
            $targetEnv = Get-ModuleDevelopmentEnvironment -ModuleName $module -DeploymentConfig $deploymentConfig

            # connect to the determined environment
            Write-Host ""
            Write-Host "Connecting to environment: $targetEnv"
            Connect-DataverseEnvironment -envName $targetEnv

            # deploy the solution
            Deploy-Solution $modulePath -AutoConfirm
        }
    } while ($module -ne "") # Continue looping until the input is an empty string

    Write-Host "Operation complete."
}
