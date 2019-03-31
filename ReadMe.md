![Prettier version](https://img.shields.io/npm/v/prettier.svg?label=Latest%20prettier)

# Node.js for .NET projects via NuGet

This NuGet package includes a globally installed [Prettier](https://prettier.io/) to be able to format files out of the box.

## Build your own

To specify a Node.js version or a prettier version you have two options:

1. Override the default in `GetDependencies.ps1`
2. Specify through environment variables
   - `$env:NODEVERSION = "v10.15.3"`
   - `$env:PRETTIERVERSION = "1.16.4"`

To build you need to download the dependencies via `GetDependencies.ps1` and then build with `build.ps1`.

## TODO

1. Azure Artifacts instructions
