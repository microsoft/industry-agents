
$projectRoot = "$PSScriptRoot\.."
. "${projectRoot}\.scripts\Util.ps1"

$ipType = Select-ItemFromList "shared"
$baseFolder = "$projectRoot\$ipType"

Write-Host ""
$excludeFolders = "__pycache__", ".scripts"
$folderNames = Get-ChildItem -Path "$projectRoot\$ipType" -Directory -Exclude $excludeFolders | Select-Object -ExpandProperty Name
$module = Select-ItemFromList $folderNames

# Define the file path
$filePath = ".config\$module-settings.json"
pac solution create-settings --solution-folder "$baseFolder\$module" --settings-file $filePath

