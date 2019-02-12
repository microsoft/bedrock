package test

import (
        "fmt"
		"testing"
		"os"
		"os/exec"

        "github.com/gruntwork-io/terratest/modules/random"
        "github.com/gruntwork-io/terratest/modules/terraform"
        "github.com/gruntwork-io/terratest/modules/k8s"
    )

func TestIT_BedrockExample(t *testing.T) {
	t.Parallel()

	// Generate a random cluster name to prevent a naming conflict
	uniqueID := random.UniqueId()
	k8sName := fmt.Sprintf("gTestk8s-%s", uniqueID)
	k8sRG := k8sName + "-rg"
	dnsprefix := k8sName + "-dns"
	clientid := os.Getenv("clientID")
	clientsecret := os.Getenv("clientSecret")
	publickey := os.Getenv("publicKey")

	// Specify the test case folder and "-var" options
	tfOptions := &terraform.Options{
		TerraformDir: "../cluster/environments/azure/aks",
		Vars: map[string]interface{}{
			"cluster_name": k8sName,
			"resource_group_name":k8sRG,
			"dns_prefix":dnsprefix,
			"service_principal_id":clientid,
			"service_principal_secret" :clientsecret,
			"ssh_public_key" :publickey,
			"gitops_url":"git@github.com:timfpark/fabrikate-cloud-native-materialized.git",
			"gitops_ssh_key" :publickey,
		},

	}

	// Terraform init, apply, output, and destroy
	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	cmd := exec.Command("export", "KUBECONFIG", "../cluster/environments/azure/aks/output/kube_config")
    //kubeConfig := os.Environ("KUBECONFIG")
	kubeConfig := os.Getenv("KUBECONFIG")


	//kubeConfig := terraform.Output(t, tfOptions, "kube_config")
	//kubeConfig, err := ioutil.ReadFile("../cluster/environments/azure/aks/output/kube_config")

    fmt.Print(string(kubeConfig))

	options := k8s.NewKubectlOptions(kubeConfig, "")

	//kubeCommand := strings.ToLower("get", "services")

	k8s.RunKubectlAndGetOutputE(t, options, "get", "credentials")

}

		