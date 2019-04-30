# Best Practices with Bedrock and GitOps

Consider these best practices a work in progress as we learn more about highly repeatable deployments in Kubernetes.

## TLDR
+ Use the high-level definition repo as application configuration as code
+ Use Bedrock deployment templates as your declarative infrastructure as code.
+ All operational changes are made by pull request
+ Don't publish changes to the cluster by hand or via CI tools (helm/tiller)
+ Practice container image promotion. 
    + Build once and promote to environments via testing gates
+ Promotion is configured in high level definition

## Securing the Bedrock GitOps Workflow
In a production scenario it can be tempting to modify Kubernetes resource directly on the cluster via `kubectl`, kubernetes dashboard, or helm via tiller. Some thoughts running through an operator's head may include:
+ Time is of the essence, I must make changes directly on the cluster. 
+ The gitops workflow is too cumbersome, I will make changes directly to the manifest yaml repository

At the moment these thoughts can seem reasonable; in the long run they can be disastrous. The reason for this is that GitOps is centered around a single interface and tooling infrastructure. Git's version control system is the basis for all configuration. Any configuration scenario that circumvents git in GitOps loses out on the ability to roll back changes and audit logs. Moreover the ability to detect changes and automate actions (such as alerts) is compromised. 

### Branch Policies
Enforcing branch policies on your repo is a good practice in general. With regards to GitOps some behaviors we highly reccomend enabling are:
+ No pushes to master with PR 
+ PR approvers should be system administrators or operators
+ Automated gating checks on PR

Links to how to set up branch policies on some git repository providers:
+ [Azure Dev Ops](https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops)
+ [GitHub](https://help.github.com/en/articles/configuring-protected-branches)

### Rollbacks
Sometimes changes to your application configuration can yield undesired results. Having the ability to easily rollback to a previous state application code configuration is a must have. We recommend a few options to accomplish rollbacks:
+ Create a new commit to your high-level deployment repo to reverse rollback application changes
    + This is probably the easiest and most straightforward approach. 
+ Use `git reset --hard (COMMIT_ID)` command to revert the undesired `COMMIT_ID`
    + This will alter the history of your git repo and might not be the most transparent approach as to what actually may have happened on your cluster.
+ Use `git revert HEAD` to create a new commit with the inverse of the last commit
    + This command allows you to see that a something was reverted in the git history

### Rollback Scenarios
+ Rolling back a promoted container
    + _Coming soon_
+ Multi-cluster rollbacks
    + _Coming soon_
+ Ensuring created cluster resources are removed
    + _Coming soon_

## GitOps Checklist
- [ ] Are you using branch policies on your high-level definition and manifest repos?
- [ ] Are you practicing container promotion?
- [ ] Are you locking high-level definition subcomponents to a version?
- [ ] Is your manifest repo locked down from developers and operators?
- [ ] Are you alerting on deployment synchronizer (flux) metrics?

_More to come_