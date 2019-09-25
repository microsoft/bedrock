#!/bin/bash

#Fill the variables!

#Let's defind some variables

# your Azure DevOps org in the form: https://dev.azure.com/org
export ORG=

#your Github user
export GH_USER=

#Azure DevOps project
export PROJECT=

export DATACENTER_LOCATION=

#Azure credentials able to create an AKS cluster
export ARM_TENANT_ID=
export ARM_SUBSCRIPTION_ID=
export ARM_CLIENT_SECRET=
export ARM_CLIENT_OBJECT_ID=
export ARM_CLIENT_ID=

#Storage account to store Terraform state
export ARM_BACKEND_STORAGE_NAME=
export ARM_BACKEND_STORAGE_KEY=
export ARM_BACKEND_STORAGE_CONTAINER=


#create Azure DevOps project
az devops project create $ORG --name $PROJECT

#create azure credentials variable group
az pipelines variable-group create --org $ORG -p $PROJECT --name azure_credentials --authorize true --variables dummy=true
AZURE_CRED_VG_ID=`az pipelines variable-group list -o tsv|grep azure_credentials| awk '{print $3}'`

create_azure_cred_vg_variable="az pipelines variable-group variable create --org ${ORG} -p ${PROJECT} --id ${AZURE_CRED_VG_ID} --secret true"

$create_azure_cred_vg_variable --name ARM_TENANT_ID --value $ARM_TENANT_ID
$create_azure_cred_vg_variable --name ARM_SUBSCRIPTION_ID --value $ARM_SUBSCRIPTION_ID
$create_azure_cred_vg_variable --name ARM_CLIENT_SECRET --value $ARM_CLIENT_SECRET
$create_azure_cred_vg_variable --name ARM_CLIENT_OBJECT_ID --value $ARM_CLIENT_OBJECT_ID
$create_azure_cred_vg_variable --name ARM_CLIENT_ID --value $ARM_CLIENT_ID
$create_azure_cred_vg_variable --name ARM_BACKEND_STORAGE_NAME --value $ARM_BACKEND_STORAGE_NAME
$create_azure_cred_vg_variable --name ARM_BACKEND_STORAGE_KEY --value $ARM_BACKEND_STORAGE_KEY
$create_azure_cred_vg_variable --name ARM_BACKEND_STORAGE_CONTAINER --value $ARM_BACKEND_STORAGE_CONTAINER

#create common variable group
az pipelines variable-group create --org $ORG -p $PROJECT --name common_bedrock --authorize true --variables dummy=true
COMMON_VG_ID=`az pipelines variable-group list -o tsv|grep common_bedrock| awk '{print $3}'`

create_common_vg_variable="az pipelines variable-group variable create --org ${ORG} -p ${PROJECT} --id ${COMMON_VG_ID} --secret true"

$create_common_vg_variable --name ALL_IT_TESTS --value false
$create_common_vg_variable --name AZ_COMMON_KV_TEST --value false
$create_common_vg_variable --name AZ_COMMON_MC_TEST --value false
$create_common_vg_variable --name AZ_SIMPLE_TEST --value true
$create_common_vg_variable --name DATACENTER_LOCATION --value $DATACENTER_LOCATION
$create_common_vg_variable --name GO111MODULE --value on

#create the Github Service endpoint
#your Github Token for Azure DevOps https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#sep-github
export AZURE_DEVOPS_EXT_GITHUB_PAT=

az devops service-endpoint github create--org $ORG -p $PROJECT  --name gh_badrock_sc --github-url https://github.com/${GH_USER}
GITHUB_SC_ID=`az devops service-endpoint list | grep gh_badrock_sc | awk '{print $1}'`

#create the pipeline
az pipelines create --org $ORG -p $PROJECT --name badrock --repository https://github.com/${GH_USER}/bedrock.git --yml-path azure-pipelines.yml --service-connection $GITHUB_SC_ID --skip-first-run --branch master

export PIPELINE_ID=`az pipelines list -o tsv | grep badrock | awk '{print $4}'`


#Now, to run successfully, you have to browse to the Pipeline, choose Settings->Variables and link the two Variable Groups just created to the pipeline.

