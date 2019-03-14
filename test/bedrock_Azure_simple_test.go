package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestIT_Bedrock_AzureSimple_Test(t *testing.T) {
	t.Parallel()

	// Generate a random cluster name to prevent a naming conflict
	uniqueID := random.UniqueId()
	k8sName := fmt.Sprintf("gTestk8s-%s", uniqueID)
	k8sRG := k8sName + "-rg"
	dnsprefix := k8sName + "-dns"
	clientid := os.Getenv("ARM_CLIENT_ID")
	clientsecret := os.Getenv("ARM_CLIENT_SECRET")
	publickey := os.Getenv("public_key")
	subscriptionid := os.Getenv("ARM_SUBSCRIPTION_ID")
	tenantid := os.Getenv("ARM_TENANT_ID")
	sshkey := os.Getenv("ssh_key")

	// Specify the test case folder and "-var" options
	tfOptions := &terraform.Options{
		TerraformDir: "../cluster/environments/azure-simple",
		Vars: map[string]interface{}{
			"cluster_name":             k8sName,
			"resource_group_name":      k8sRG,
			"dns_prefix":               dnsprefix,
			"service_principal_id":     clientid,
			"service_principal_secret": clientsecret,
			"ssh_public_key":           publickey,
			"gitops_ssh_url":           "git@github.com:timfpark/fabrikate-cloud-native-materialized.git",
			"gitops_ssh_key":           sshkey,
			"tenant_id":                tenantid,
			"subscription_id":          subscriptionid,
		},
	}

	// Terraform init, apply, output, and destroy
	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	// Obtain Kube_config file from module output
	os.Setenv("KUBECONFIG", "../cluster/environments/azure-simple/output/bedrock_kube_config")
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
