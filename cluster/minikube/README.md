# Minikube Cluster Deployment

## Getting Started

Beyond the [base requirements](../README.md) for Bedrock, we also need to install a hypervisor, Docker Desktop, and Minikube locally. This will done by altering a simple script file.

## Installing Docker

Install the correct version of [Docker Desktop](https://www.docker.com/products/docker-desktop) for your operating system. Once installed, make sure to start Docker Desktop.

## Installing Minikube

### Mac

Install [Homebrew](https://brew.sh/).

In the terminal, install Minikube by typing:

```bash
$ brew cask install virtualbox
```

In the terminal, install Minikube by typing:

```bash
$ brew cask install minikube
```

Start minikube by typing (this will take a while as Minikube downloads the VM):

```bash
$ minikube start
```

Check the status to make sure everything looks ok:

```bash
$ minikube status
host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at {ip address}
```

### Windows

[Enable](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v) the Hyper-V hypervisor.

In the Hyper-V administration tool, create a virtual switch (which creates a network) for minikube to operate on.

Open an administrative Powershell, and install [Chocolatey](https://chocolatey.org/).

In an administrative Powershell, install Minikube by typing:

```powershell
PS C:\> choco install minikube kubernetes-cli
```

Start minikube by typing (this will take a while as Minikube downloads the VM):

```powershell
PS C:\> minikube start --vm-driver hyperv --hyperv-virtual-switch "{the name of your switch}"
```

Check the status to make sure everything looks ok:

```powershell
PS C:\> minikube status
host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at {ip address}
```

## Setting Up Gitops Repository for Flux

Flux watches a Git repository containing the resource manifests that should be deployed into the Kubernetes cluster, and, as such, we need to configure that repo and give Flux permissions to access it at cluster creation time.

1.  Create the repo to use for Gitops (this example will assume that you are using Github, but Gitlab and Azure Devops are also supported).
2.  Create/choose a SSH key pair that will be given permission to do read/write access to the repository. **Do not enter a passphrase** when creating a SSH key, as Flux will be unable to sign with a passphrase protected private key. You can create an ssh key pair with the following:

```bash
$ ssh-keygen -b 2048 -t rsa -f gitops_repo_key
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in gitops_repo_key.
Your public key has been saved in gitops_repo_key.pub.
The key fingerprint is:
SHA256:DgAbaIRrET0rM/U5PIT0mcBFVMW/AQ9sRJ/TsdcmmFA
The key's randomart image is:
+---[RSA 2048]----+
|o+Bo=+..*+..E.   |
|oo Xo.o  *..ooo .|
|..+ B+. . =+oo..o|
|.= . B     +. .o |
|. +   + S   o    |
|       o   .     |
|        .        |
|                 |
|                 |
+----[SHA256]-----+
$ ls -l gitops_repo_key*
-rw-------  1 jims  staff  1823 Jan 24 16:28 gitops_repo_key
-rw-r--r--  1 jims  staff   398 Jan 24 16:28 gitops_repo_key.pub
```

3.  Add the SSH key to the repository

Flux requires read and write access to the resource manifest git repository. For Github, the process to add a deploy key is documented
[here](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/).

## Creating a Cluster Environment

The typical way to create a new environment is to start from an existing template. For Minikube, we currently have the following templates:

- [Minikube](../environments/minikube): Single cluster deployment with Flux

So, for example, to create a cluster environment based on the `minikube` template, copy it to a new subdirectory with the name of your cluster:

```bash
$ cp -r cluster/environments/minikube cluster/environments/<cluster name>
```

With this new environment created, edit `environments/<cluster name>/deploy_minikube.sh` and update the following variables (where neccessary):

- `GITOPS_SSH_URL`: The git repo that contains the resource manifests that should be deployed in the cluster in ssh format (eg. `git@github.com:timfpark/fabrikate-cloud-native-manifests.git`). This repo must have a deployment key configured to accept changes from `gitops_ssh_key_path` (see [Configuring Gitops Repository for Flux](#setting-up-gitops-repository-for-flux) for more details).
- `GITOPS_SSH_BRANCH`: Which branch of the gitops repo to monitor for changes.
- `GITOPS_SSH_KEY_PATH`: Path to the *private key file* that was configured above to work with the Gitops repository.
- `FLUX_REPO_URL`: the URL of Flux, usually [here](https://github.com/weaveworks/flux.git).
- `REPO_ROOT_DIR`: subdirectory used to pull Flux into, usuall *repo-root*.

## Deploying Cluster

Bedrock requires a bash shell for the executing the automation. Currently MacOSX, Ubuntu, and the Windows Subsystem for Linux (WSL) are supported.

Then, from the directory of the cluster you defined above (eg. `environments/<cluster name>`), run:

```bash
$ ./deploy_minikube.sh
```
