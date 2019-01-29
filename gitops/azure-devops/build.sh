cd /home/vsts/work/1/s/

# If the version number is not provided, then download the latest
if [ -z "$VERSION" ]
then
    VERSIONS=$(curl -s https://api.github.com/repos/Microsoft/fabrikate/tags)
    LATEST_RELEASE=$(echo $VERSIONS | grep "name" | head -1)
    VERSION_TO_DOWNLOAD=`echo "$LATEST_RELEASE" | cut -d'"' -f 4`
else
    echo "Fabrikate Version: $VERSION"
    VERSION_TO_DOWNLOAD=$VERSION
fi

echo "RUN HELM INIT"
helm init
echo "HELM ADD INCUBATOR"
helm repo add $HELM_CHART_REPO $HELM_CHART_REPO_URL

echo "Downloading Fabrikate..."
echo "Latest Fabrikate Version: $VERSION_TO_DOWNLOAD"
wget "https://github.com/Microsoft/fabrikate/releases/download/$VERSION_TO_DOWNLOAD/fab-v$VERSION_TO_DOWNLOAD-linux-amd64.zip"
unzip fab-v$VERSION_TO_DOWNLOAD-linux-amd64.zip -d fab
export PATH=$PATH:/home/vsts/work/1/s/fab
fab install

fab generate prod
echo "FAB GENERATE PROD COMPLETED"
ls -a

# If generated folder is empty, quit
# In the case that all components are removed from the source hld, 
# generated folder should still not be empty
if find "/home/vsts/work/1/s/generated" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    echo "Manifest files have been generated"
else
    echo "Manifest files could not be generated, quitting"
    exit 1
fi

# Clone the destination repo
cd /home/vsts/work/1/s/
echo "GIT CLONE"
git clone https://github.com/$AKS_MANIFEST_REPO.git
repo_url=https://github.com/$AKS_MANIFEST_REPO.git

# Extract repo name from url
repo=${repo_url##*/}
echo "REPO:$repo"
repo_name=${repo%.*}
echo "REPO_NAME:$repo_name"
cd $repo_name

echo "GIT CHECKOUT"
git checkout master
echo "GIT STATUS"
git status
echo "Copy yaml files to repo directory..."
rm -rf prod/
cp -r /home/vsts/work/1/s/generated/* .
ls /home/vsts/work/1/s/$repo_name
echo "GIT ADD"
git add *

# Set git identity 
git config user.email "admin@azuredevops.com"
git config user.name "Automated Account"

echo "GIT COMMIT"
git commit -m "Updated k8s manifest files post commit: $COMMIT_MESSAGE"
echo "GIT STATUS" 
git status
echo "GIT PULL" 
git pull
echo "GIT PUSH"
git push https://$ACCESS_TOKEN@github.com/$AKS_MANIFEST_REPO.git
echo "GIT STATUS"
git status
