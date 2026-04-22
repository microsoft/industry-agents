
$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

do {
    # Ask user which category for new module
    Write-Host ""
    Write-Host "Select category for new module:"
    
    # Get available categories
    $categories = Get-ModuleCategories -projectRoot $projectRoot
    
    if ($categories.Count -eq 0) {
        Write-Host "No categories found. Creating first category..." -ForegroundColor Yellow
        $ipType = Read-Host "Enter category name (lowercase-with-hyphens, e.g., 'cross-industry', 'government', 'healthcare')"
        $ipType = $ipType.ToLower() -replace '[^a-z0-9\-]', '-' -replace '-+', '-'
        $ipType = $ipType.Trim('-')
        
        $newCategoryPath = Join-Path $projectRoot $ipType
        New-Item -ItemType Directory -Path $newCategoryPath -Force | Out-Null
        Write-Host "Created new category: $ipType" -ForegroundColor Green
    } else {
        # Add option to create new category and exit option
        $categoryChoices = @($categories) + @("[Create new category]", "[Exit]")
        $selected = Select-ItemFromList -choices $categoryChoices
        
        if ($selected -eq "[Exit]") {
            Write-Host "Exiting..." -ForegroundColor Cyan
            break
        }
        
        if ($selected -eq "[Create new category]") {
            $ipType = Read-Host "Enter new category name (lowercase-with-hyphens, e.g., 'healthcare', 'finance')"
            $ipType = $ipType.ToLower() -replace '[^a-z0-9\-]', '-' -replace '-+', '-'
            $ipType = $ipType.Trim('-')
            
            $newCategoryPath = Join-Path $projectRoot $ipType
            if (-not (Test-Path $newCategoryPath)) {
                New-Item -ItemType Directory -Path $newCategoryPath -Force | Out-Null
                Write-Host "Created new category: $ipType" -ForegroundColor Green
            }
        } else {
            $ipType = $selected
        }
    }
    
    Write-Host "Creating module in category: $ipType" -ForegroundColor Cyan

$friendlyName = Read-Host "Enter module name (spaces allowed)"

# Clean up folder name: replace non-alphanum with dash, collapse multiple dashes, trim, lowercase
$solutionFolderName = $friendlyName -replace '[^a-zA-Z0-9]', '-'
$solutionFolderName = $solutionFolderName -replace '-+', '-'
$solutionFolderName = $solutionFolderName.Trim('-')
$solutionFolderName = $solutionFolderName.ToLower()

# PAC CLI project name (no spaces or special chars)
$pacFriendlyName = $friendlyName -replace '[^a-zA-Z0-9]', ''

# Build Proper-Cased, hyphenated name for the .cdsproj filename (e.g. "Knowledge Management" -> "Knowledge-Management")
$projectCasedHyphenName = $friendlyName -replace '[^a-zA-Z0-9]', '-'
$projectCasedHyphenName = $projectCasedHyphenName -replace '-+', '-'
$projectCasedHyphenName = $projectCasedHyphenName.Trim('-')

# Capitalize each token and join with hyphens
$tokens = $projectCasedHyphenName.Split('-') | Where-Object { $_ -ne '' }
$tokens = $tokens | ForEach-Object { if ($_.Length -gt 1) { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() } else { $_.ToUpper() } }
$projectCasedHyphenName = ($tokens -join '-')

# Solution unique name
$solutionUniqueName = $friendlyName -replace '[^a-zA-Z0-9\-]', ''
$solutionUniqueName = $solutionUniqueName.ToLower().Replace("-", "_")

$customizationPrefix = "appbase"
$publisherSchemaName = "appbase"
$publisherName = "App Base"
$friendlyPrefix = "App Base"
$pacFriendlyPrefix = "App-Base"

$solutionUniqueName = "${publisherSchemaName}_${solutionUniqueName}"

# Ensure the target folder exists
$baseFolderPath = Join-Path -Path "$PSScriptRoot\.." -ChildPath $ipType
if (-not (Test-Path $baseFolderPath)) {
    Write-Host "Creating $ipType folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $baseFolderPath -Force | Out-Null
}

# PAC CLI doesn't like hyphens in project names, so create with pacFriendlyName first, then rename
$tempSolutionPath = Join-Path -Path "$PSScriptRoot\.." -ChildPath "$ipType\$pacFriendlyName"
$solutionPath = Join-Path -Path "$PSScriptRoot\.." -ChildPath "$ipType\$solutionFolderName"

pac solution init --publisher-name $publisherSchemaName --publisher-prefix $customizationPrefix -o $tempSolutionPath

# Rename folder to lowercase if needed (Windows requires two-step rename for case-only changes)
if ($pacFriendlyName -cne $solutionFolderName) {
    $tempName = "$pacFriendlyName-temp-rename"
    Rename-Item $tempSolutionPath $tempName
    Rename-Item (Join-Path -Path "$PSScriptRoot\.." -ChildPath "$ipType\$tempName") $solutionFolderName
}

Update-SolutionName $solutionPath/src/Other/Solution.xml "$friendlyPrefix - $friendlyName"
Update-SolutionUniqueName $solutionPath/src/Other/Solution.xml $solutionUniqueName
Update-SolutionPublisherName $solutionPath/src/Other/Solution.xml $publisherName
Update-SolutionProjectManaged "${solutionPath}\${pacFriendlyName}.cdsproj"
$projFileName = "$pacFriendlyPrefix-$projectCasedHyphenName.cdsproj"
Rename-Item -Path "${solutionPath}\${pacFriendlyName}.cdsproj" -NewName $projFileName

$importAnswer = Read-Host "Build and import into environment as unmanaged solution (y/n)?"

if ($importAnswer -eq 'y') {
    # Use deployment configuration system like other scripts
    Write-Host ""
    $deploymentConfig = Select-Deployment
    
    Write-Host ""
    Write-Host "Connecting to tenant: $($deploymentConfig.Tenant)"
    Connect-DataverseTenant -authProfile $deploymentConfig.Tenant

    # Determine target environment based on module configuration
    $targetEnv = Get-ModuleDevelopmentEnvironment -ModuleName $solutionFolderName -DeploymentConfig $deploymentConfig

    Write-Host "Connecting to environment: $targetEnv"
    pac org select --environment $targetEnv
    
    # Use enhanced Deploy-Solution function
    Deploy-Solution $solutionPath -AutoConfirm
    
    Write-Host ""
    Write-Host "Module '$friendlyName' created and deployed successfully to $targetEnv!" -ForegroundColor Green
}

} while ($true)
