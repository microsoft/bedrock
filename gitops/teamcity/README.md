# TeamCity

TeamCity is a build management and continuous integration server developed by [JetBrains](https://www.jetbrains.com/teamcity/). TeamCity is available in the [Azure Marketplace](https://azuremarketplace.microsoft.com/en-en/marketplace/apps/jetbrains.teamcity?tab=Overview). 

Follow any of the following guides to run builds on TeamCity:

1. [Image Tag Release Pipeline](./ImageTagRelease.md)
2. [Manifest Generation Pipeline](./ManifestGeneration.md)

## Challenges with TeamCity

- Upgrading from one version to another is a time consuming task with TeamCity 
- Not free if you need more than 3 agents and over 100 builds
- Unintuitive user interface, less customizability, fewer hooks, less variables available as part of build processes (such as commit messages can't be fetched from a repo that triggered it)






