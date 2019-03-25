$xml = ([xml](Get-Content .\nodeenv.nuspec))
$nodeVersion = @($env:NODEVERSION, "v10.15.3") | Where-Object { -not ($_ -eq $null) }
$prettierVersion = @($env:PRETTIERVERSION, "1.16.4") | Where-Object { -not ($_ -eq $null) }

if(-not (Test-Path "$PSScriptRoot\temp")) { mkdir "$PSScriptRoot\temp" }

### NodeJS
Write-Host "Downloading nodejs"
$nodeUrl = "https://nodejs.org/dist/$nodeVersion/node-$nodeVersion-win-x86.zip"
$nodeSave = "nodejs.zip"
$client = new-object System.Net.WebClient
$client.DownloadFile($nodeUrl, $nodeSave)
Write-Host "Extracting nodejs"
# Expand-Archive -Path .\nodejs.zip -DestinationPath .\temp
.\7za.exe x -otemp .\nodejs.zip -r
Get-ChildItem .\temp\node-v* | Rename-Item -NewName node

### Prettier
Write-Host "Listing prettier versions:"
npm view prettier versions
Write-Host "Downloading prettier"
npm pack prettier@"$prettierVersion"
tar xzvf (Get-ChildItem .\prettier-*) -C temp
Rename-Item .\temp\package -NewName prettier
Move-Item .\temp\prettier .\temp\node\node_modules\
Copy-Item .\prettier.cmd .\temp\node\
