# Bedrock Releases

Bedrock uses Terraform scripts for deployment of infrastructure.  In these scripts, remote references from the Bedrock environments are made to modules in the Bedrock repository.  In order to provide consistent references for deployments, releases are being introduced to Bedrock.  Each release will have consistent remote references to the modules within that release and `master` will continue to reference master.  `master` will evolve as work is performed.  When a release is deemed necessary, a new one will be generated.  In general, the guideline for creating releases falls under:

- Major functionality (like a new environment) is added
- When versions of providers are updated for new functionality
- Any major change to existing environments
- Tooling is added or updated

The plan for Bedrock is to release 1.0 as an end of life for support of Terraform 0.11.  Post 1.0, Bedrock will move to supporting Terraform 0.12 and up.

## Fixed Release References

As mentioned, releases will reference fixed references for remote resources.  If you look within the various cluster environments, this is handled by updating the `source` for remote modules to resemble the following:

```
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/keyvault"
```

The `?ref=master` specifies the remote branch or tag to reference.  In this case, that is `master`, but releases will be specific to the release.

## Release Process

To facilitate releases and making sure references to remote sources are properly handled, there is a script `tools/bedrock_terraform_release.sh`.  The script takes in a version number for the release, updates the remote references, then creates a branch with the version number as a name.

The script takes the following arguments:

- `-r` (optional) repository to reference
- `-c` (optional) current version to create the release off of, this should be a branch of the `current version` name
- `-v` the version number for the branch
- `-s` (optional) will cause the working directory *not* to be deleted

Running the script resembles:

```bash

$ ./tools/bedrock_terraform_release.sh -v 0.1.0
Cloning into 'bedrock'...
remote: Enumerating objects: 20, done.
remote: Counting objects: 100% (20/20), done.
remote: Compressing objects: 100% (17/17), done.
remote: Total 2806 (delta 9), reused 6 (delta 3), pack-reused 2786
Receiving objects: 100% (2806/2806), 36.34 MiB | 5.27 MiB/s, done.
Resolving deltas: 100% (1467/1467), done.
M	cluster/common/velero/main.tf
M	cluster/environments/azure-common-infra/keyvault.tf
M	cluster/environments/azure-common-infra/main.tf
M	cluster/environments/azure-common-infra/vnet.tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/aks-centralus.tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/aks-eastus.tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/aks-westus.tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/api-management.tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/main.tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/trafficmanager.tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/waf-centralus..tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/waf-eastus.tf
M	cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/waf-westus.tf
M	cluster/environments/azure-multiple-clusters/aks-centralus.tf
M	cluster/environments/azure-multiple-clusters/aks-eastus.tf
M	cluster/environments/azure-multiple-clusters/aks-westus.tf
M	cluster/environments/azure-multiple-clusters/main.tf
M	cluster/environments/azure-multiple-clusters/trafficmanager.tf
M	cluster/environments/azure-simple/main.tf
M	cluster/environments/azure-single-keyvault-cosmos-mongo-db-simple/main.tf
M	cluster/environments/azure-single-keyvault/main.tf
M	cluster/environments/azure-velero-restore/main.tf
Switched to a new branch '0.1.0'
[0.1.0 8c5695d] create branch for 0.1.0
 22 files changed, 56 insertions(+), 56 deletions(-)
Username for 'https://github.com': jmspring
Password for 'https://jmspring@github.com': 
Counting objects: 22, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (8/8), done.
Writing objects: 100% (22/22), 964 bytes | 964.00 KiB/s, done.
Total 22 (delta 22), reused 0 (delta 0)
remote: Resolving deltas: 100% (22/22), completed with 22 local objects.
remote: 
remote: Create a pull request for '0.1.0' on GitHub by visiting:
remote:      https://github.com/microsoft/bedrock/pull/new/0.1.0
remote: 
To https://github.com/jmspring/release-test.git
 * [new branch]      0.1.0 -> 0.1.0
Branch '0.1.0' set up to track remote branch '0.1.0' from 'origin'.
branch for 0.1.0 created
removing tmp directory
```

Once the branch is created, the release can be created following the instructions [here](https://help.github.com/en/articles/creating-releases).