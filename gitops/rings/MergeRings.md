# Merge Rings

If you would like to have a procedure in place for merging a ring into master without overwriting the ring rules in master, you can follow the guide below. The idea here is to run a task in every time a pull request is created from a branch to master, that updates the ring configuration to match master and removes any changes that are being merged to update the ring configuration in master. This way a developer who intends to merge a feature into branch master after testing their ring does not accidentally end up overwriting the main production ring (master ring).

## Steps to add task to merge rings into master

Assuming that you've already followed the guide to setup the initial rings infrastructure, navigate to the `Edit pipeline` page for the SRC to ACR pipeline. We will add a task here that should only execute for a pull request. 

```yaml
- bash: |
    git checkout $BRANCH_NAME
    git checkout origin/master $RING_CONFIG
    git add $RING_CONFIG
    git config --global user.email $EMAIL
    git config --global user.name "Azure DevOps Bot"
    git commit -m "Updating the ring config to match master"
    proto="$(echo $SRC_REPO | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    url="$(echo ${SRC_REPO/$proto/})"
    git remote set-url origin https://$ACCESS_TOKEN@$url
    git push origin $BRANCH_NAME
  displayName: Update ring.yaml to master on PR
  condition: eq(variables['Build.Reason'], 'PullRequest')
  env:
    BRANCH_NAME: $(System.PullRequest.SourceBranch)
    SRC_REPO: $(SRC_REPO)
    RING_CONFIG: $(RING_CONFIG)
    EMAIL: $(EMAIL)
    ACCESS_TOKEN: $(ACCESS_TOKEN)
```

This requires you to add the following environment variables in the pipeline:
- `RING_CONFIG`: Set this to the path to the file/directory where the ring configuration is located, for example `ring/config/common.yaml`
- `SRC_REPO`: Set this to the URL of the source repository in https format, such as `https://github.com/bnookala/hello-rings.git` 
- `ACCESS_TOKEN`: Set this to the access token that has rights to the source repository. 
- `EMAIL`: Set this to your email address

