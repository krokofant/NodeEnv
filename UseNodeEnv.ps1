$packageVersion = "#PACKAGEVERSION#"
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

$relPath = Join-Path (Join-Path ($PSScriptRoot) .) "..\..\..\packages\NodeEnv.$packageVersion\"
$absPath = [System.IO.Path]::GetFullPath($relPath)

# Add npm folder to path
Add-EnvPath("$env:APPDATA\npm")

# Add NodeEnv folder to path
Add-EnvPath($absPath)
