$ErrorActionPreference = "Stop"

$xml = ([xml](Get-Content .\nodeenv.nuspec))
$id = $xml.package.metadata.id
$version = (Get-Date -Format "yyyy.M.d")
if ($env:TRAVIS_BUILD_NUMBER.Count -gt 0) {
    $version = "$version.$env:TRAVIS_BUILD_NUMBER"
}

nuget pack -Version $version -OutputDirectory build -NoPackageAnalysis
$hash = (Get-FileHash ".\build\$id.$version.nupkg" -Algorithm SHA512).Hash.ToLower()
$hash | Out-File ".\build\$id.$version.nupkg.sha512"
Get-ChildItem .\build\*