![Prettier version](https://img.shields.io/npm/v/prettier.svg?label=Latest%20prettier)

<h1 align="center">🚀 Node.js for .NET projects via NuGet 👷</h1>

This NuGet package includes a globally installed [Prettier](https://prettier.io/) to be able to format files out of the box.

- [Build your own](#build-your-own)
- [Azure Pipeline / Artifacts](#azure-pipeline--artifacts)
  - [Download dependencies](#download-dependencies)
  - [Build](#build)
  - [Publish as build artifact](#publish-as-build-artifact)
  - [Publish as Azure Artifact](#publish-as-azure-artifact)
- [Dynamically use the latest NodeEnv](#dynamically-use-the-latest-nodeenv)
- [Opt-in script for Prettier pre-commit hook](#opt-in-script-for-prettier-pre-commit-hook)

## Build your own

To specify a Node.js version or a prettier version you have two options:

1. Override the default in `GetDependencies.ps1`
2. Specify through environment variables
   - `$env:NODEVERSION = "v10.15.3"`
   - `$env:PRETTIERVERSION = "1.16.4"`

To build you need to download the dependencies via `GetDependencies.ps1` and then build with `build.ps1`.

## Azure Pipeline / Artifacts

Task definitions for use with Azure Pipeline.

Set your _Build number format_ to `$(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)` to adhere to NodeEnv versioning.

Specify environment variables `NODEVERSION` and `PRETTIERVERSION` to override the repo default versions.

### Download dependencies

```yaml
steps:
  - task: PowerShell@2
    displayName: "Download dependencies"
    inputs:
      targetType: filePath
      filePath: "./$(System.DefaultWorkingDirectory)/GetDependencies.ps1"
```

### Build

```yaml
steps:
  - task: PowerShell@2
    displayName: Build
    inputs:
      targetType: filePath
      filePath: "./$(System.DefaultWorkingDirectory)/build.ps1"
```

### Publish as build artifact

```yaml
steps:
  - task: PublishBuildArtifacts@1
    displayName: "Publish Artifact: NodeEnv"
    inputs:
      PathtoPublish: "$(System.DefaultWorkingDirectory)/build"
      ArtifactName: NodeEnv
```

### Publish as Azure Artifact

```yaml
steps:
  - task: NuGetCommand@2
    displayName: "NuGet push"
    inputs:
      command: push
      packagesToPush: "$(System.DefaultWorkingDirectory)/**/*.nupkg;!$(System.DefaultWorkingDirectory)/**/*.symbols.nupkg"
      publishVstsFeed: "[your-feed-id]"
    condition: and(succeeded(), in(variables['system.debug'], 'false'))
```

## Dynamically use the latest NodeEnv

Save this as a PowerShell script and use it to enter the NodeEnv. Adjust the path to _packages_ to your own specification.

```powershell
$pathToLatestNodeEnv = Get-ChildItem $PSScriptRoot\..\..\..\packages\NodeEnv.* |
    Sort-Object -Property @{Expression = {[Version]$_.Name.Substring(8)}} |
    Select-Object -Last 1 -ExpandProperty FullName

function Add-EnvPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $Path) {
        $env:Path = "$Path;$env:PATH"
    }
}

# Add npm folder to path
Add-EnvPath("$env:APPDATA\npm")

# Add NodeEnv folder to path
Add-EnvPath($pathToLatestNodeEnv)
```

## Opt-in script for Prettier pre-commit hook

Usage: `[RepositoryRoot]/.powershell/pre-commit.ps1`

```powershell
# This should be called from a pre-commit hooks with the following contents
#region precommit hook contents
# #!/bin/sh
# cd $(git rev-parse --show-toplevel)/.powershell
# powershellPath="c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
# if [ -f $powershellPath ]; then
#     $powershellPath -ExecutionPolicy Bypass -NoProfile -Command '.\pre-commit.ps1'
# fi
#endregion

param (
    [switch]$AddHooks = $false
 )

 if($AddHooks) {
	'#!/bin/sh
cd $(git rev-parse --show-toplevel)/.powershell
powershellPath="c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
if [ -f $powershellPath ]; then
    $powershellPath -ExecutionPolicy Bypass -NoProfile -Command ".\pre-commit.ps1"
fi' | Set-Content $PSScriptRoot\..\.git\hooks\pre-commit
    Exit 0
 }

function ExitIfMissingCommand ($s) { if (!(Get-Command "$s" -ErrorAction SilentlyContinue)) { Exit 0 } }

# Set location to repo root
Set-Location $PSScriptRoot\..\

# Get the files which are staged and matching prettier targets
$files = (git diff --cached --name-only --diff-filter=ACM "*.js" "*.ts") | Where-Object { $_ -match "src/notSoPrettyFiles" }

# Enter a node environment with prettier
& .powershell\UseNodeEnv.ps1

ExitIfMissingCommand "prettier"

# Don't continue if no targets found
if ($files.Count -eq 0) { Exit 0 }

& prettier $files --write # prettify the files
& git add $files # stage the files again
```
