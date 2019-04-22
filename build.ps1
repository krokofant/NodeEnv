$ErrorActionPreference = "Stop"

$xml = ([xml](Get-Content .\nodeenv.nuspec))
$id = $xml.package.metadata.id
$version = (Get-Date -Format "yyyy.M.d")
if ($env:TRAVIS_BUILD_NUMBER.Count -gt 0) {
    $version = "$version.$env:TRAVIS_BUILD_NUMBER" # travis
} elseif ($env:Build_BuildNumber.Count -gt 0) {
    $version = "$env:Build_BuildNumber" # azure pipeline
}

nuget.exe pack .\temp\nodeenv.nuspec -BasePath .\ -Version $version -OutputDirectory build -NoPackageAnalysis
$hash = (Get-FileHash ".\build\$id.$version.nupkg" -Algorithm SHA512).Hash.ToLower()
$hash | Out-File ".\build\$id.$version.nupkg.sha512"
Get-ChildItem .\build\*
