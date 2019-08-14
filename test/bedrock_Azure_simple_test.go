package test

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/otiai10/copy"
)

func TestIT_Bedrock_AzureSimple_Test(t *testing.T) {
	t.Parallel()

        fmt.Println("here 1")

	// Generate a random cluster name to prevent a naming conflict
	uniqueID := random.UniqueId()
	k8sName := fmt.Sprintf("gTestk8s-%s", uniqueID)

        fmt.Println("here 2")
	subnetPrefix := "10.10.1.0/24"
	addressSpace := "10.10.0.0/16"
	clientid := os.Getenv("ARM_CLIENT_ID")
	clientsecret := os.Getenv("ARM_CLIENT_SECRET")
	tenantId := os.Getenv("ARM_TENANT_ID")
	dnsprefix := k8sName + "-dns"
	k8sRG := k8sName + "-rg"
	location := os.Getenv("DATACENTER_LOCATION")
	publickey := os.Getenv("public_key")
	sshkey := os.Getenv("ssh_key")
	vnetName := k8sName + "-vnet"

        fmt.Println("here 3")
	//Copy env directories as needed to avoid conflicting with other running tests
	azureSimpleInfraFolder := "../cluster/test-temp-envs/azure-simple-" + k8sName
	copy.Copy("../cluster/environments/azure-simple", azureSimpleInfraFolder)

	//Create the resource group
        fmt.Println("here 4")
	cmd0 := exec.Command("az", "login", "--service-principal", "-u", clientid, "-p", clientsecret, "--tenant", tenantId)
	err0 := cmd0.Run()
	if err0 != nil {
		log.Fatal(err0)
		os.Exit(-1)
	}
	fmt.Println("here 4.5")
	cmd := exec.Command("az", "group", "create", "-n", k8sRG, "-l", location)
	err := cmd.Run()
	if err != nil {
		log.Fatal(err)
		os.Exit(-1)
	}
        fmt.Println("here 5")

	// Specify the test case folder and "-var" options
	tfOptions := &terraform.Options{
		TerraformDir: azureSimpleInfraFolder,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"address_space":            addressSpace,
			"cluster_name":             k8sName,
			"dns_prefix":               dnsprefix,
			"gitops_ssh_url":           "git@github.com:timfpark/fabrikate-cloud-native-manifests.git",
			"gitops_ssh_key":           sshkey,
			"resource_group_name":      k8sRG,
			"service_principal_id":     clientid,
			"service_principal_secret": clientsecret,
			"ssh_public_key":           publickey,
			"subnet_prefix":            subnetPrefix,
			"vnet_name":                vnetName,
		},
	}

	// Terraform init, apply, output, and destroy
	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	// Obtain Kube_config file from module output
	os.Setenv("KUBECONFIG", azureSimpleInfraFolder+"/output/bedrock_kube_config")
	kubeConfig := os.Getenv("KUBECONFIG")

	options := k8s.NewKubectlOptions("", kubeConfig)

	//Test Case 1: Verify Flux namespace
	fmt.Println("Test case 1: Verifying flux namespace")
	_flux, fluxErr := k8s.RunKubectlAndGetOutputE(t, options, "get", "po", "--namespace=flux")
	if fluxErr != nil || !strings.Contains(_flux, "flux") {
		t.Fatal(fluxErr)
	} else {
		fmt.Println("Flux verification complete")
	}
}
