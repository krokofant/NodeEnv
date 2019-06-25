$ErrorActionPreference = "Stop"

$nodeVersion = @($env:NODEVERSION, "v10.15.3") | Where-Object { -not ($_ -eq $null) } | Select-Object -First 1
$prettierVersion = @($env:PRETTIERVERSION, "1.16.4") | Where-Object { -not ($_ -eq $null) } | Select-Object -First 1

if (-not (Test-Path "$PSScriptRoot\temp")) { mkdir "$PSScriptRoot\temp" }

### NodeJS
Write-Host "Downloading nodejs $nodeVersion"
$nodeUrl = "https://nodejs.org/dist/$nodeVersion/node-$nodeVersion-win-x64.zip"
$client = New-Object System.Net.WebClient
$client.DownloadFile($nodeUrl, "nodejs.zip")
Write-Host "Extracting nodejs"
if ((Get-Command 7z -ErrorAction Ignore)) {
    7z.exe x -otemp .\nodejs.zip -r
}
else {
    Expand-Archive -Path .\nodejs.zip -DestinationPath .\temp
}
Get-ChildItem .\temp\node-v* | Rename-Item -NewName node

### Prettier
Write-Host "Downloading prettier $prettierVersion"
$prettierUrl = "https://registry.npmjs.org/prettier/-/prettier-$prettierVersion.tgz"
$client.DownloadFile($prettierUrl, "prettier.tgz")
tar.exe xzvf .\prettier.tgz -C temp
Rename-Item .\temp\package -NewName prettier
Move-Item .\temp\prettier .\temp\node\node_modules\
Copy-Item .\prettier.cmd .\temp\node\

# Update nuspec with dep version information
(Get-Content .\nodeenv.nuspec).Replace(
    '$nodeVersion$', $nodeVersion
).Replace(
    '$prettierVersion$', $prettierVersion
) | Out-File .\temp\nodeenv.nuspec
