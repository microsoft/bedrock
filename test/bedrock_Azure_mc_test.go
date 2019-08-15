package test

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/otiai10/copy"
)

func addIPandRGtoYAML(input string, ipaddress string, resourceGroup string) {
	file, err := ioutil.ReadFile(input)

	if err != nil {
		log.Fatalf("failed opening file: %s", err)
	}
	lines := strings.Split(string(file), "\n")
	for i, line := range lines {
		if strings.Contains(line, "loadBalancerIP") {
			lines[i] = "  loadBalancerIP: " + ipaddress
		} else if strings.Contains(line, "service.beta.kubernetes.io/azure-load-balancer-resource-group") {
			lines[i] = "    service.beta.kubernetes.io/azure-load-balancer-resource-group: " + resourceGroup
		}
	}
	output := strings.Join(lines, "\n")
	err = ioutil.WriteFile(input, []byte(output), 0644)
}

func TestIT_Bedrock_AzureMC_Test(t *testing.T) {
	t.Parallel()

	// Generate a common infra resources for integration use with azure multicluster environment
	uniqueID := strings.ToLower(random.UniqueId())
	k8sName := fmt.Sprintf("gtestk8s-%s", uniqueID)

	location := os.Getenv("DATACENTER_LOCATION")
	clientid := os.Getenv("ARM_CLIENT_ID")

	addressSpace := "10.39.0.0/16"
	subnetName := k8sName + "-subnet"
	vnetName := k8sName + "-vnet"

	kvName := k8sName + "-kv"
	kvRG := kvName + "-rg"

	//Generate common-infra backend for tf.state files to be persisted in azure storage account
	backendName := os.Getenv("ARM_BACKEND_STORAGE_NAME")
	backendKey := os.Getenv("ARM_BACKEND_STORAGE_KEY")
	backendContainer := os.Getenv("ARM_BACKEND_STORAGE_CONTAINER")
	backendTfstatekey := k8sName + "-tfstatekey"

	//Copy env directories as needed to avoid conflicting with other running tests
	azureCommonInfraFolder := "../cluster/test-temp-envs/azure-common-infra-" + k8sName
	copy.Copy("../cluster/environments/azure-common-infra", azureCommonInfraFolder)

	//Specify the test case folder and "-var" option mapping for the backend
	common_backend_tfOptions := &terraform.Options{
		TerraformDir: azureCommonInfraFolder,
		BackendConfig: map[string]interface{}{
			"storage_account_name": backendName,
			"access_key":           backendKey,
			"container_name":       backendContainer,
			"key":                  "common_" + backendTfstatekey,
		},
	}

	// Specify the test case folder and "-var" options
	common_tfOptions := &terraform.Options{
		TerraformDir: azureCommonInfraFolder,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"address_space":                  addressSpace,
			"keyvault_name":                  kvName,
			"global_resource_group_name":     kvRG,
			"global_resource_group_location": location,
			"service_principal_id":           clientid,
			"subnet_name":                    subnetName,
			"subnet_prefix":                  addressSpace,
			"vnet_name":                      vnetName,
		},
	}

	// Terraform init, apply, output, and destroy
	defer terraform.Destroy(t, common_tfOptions)
	terraform.Init(t, common_backend_tfOptions)
	terraform.Apply(t, common_tfOptions)

	// Multicluster & keyvault deployment vars
	tmName := k8sName + "-tm"
	clientsecret := os.Getenv("ARM_CLIENT_SECRET")

	dnsprefix := k8sName + "-dns"
	tm_dnsprefix := uniqueID + "tmdns"

	k8s_eastRG := k8sName + "-east-rg"
	k8s_westRG := k8sName + "-west-rg"
	k8s_centralRG := k8sName + "-central-rg"
	k8s_globalRG := k8sName + "-global-rg"

	cluster_location1 := "westus2"
	cluster_location2 := "eastus2"
	cluster_location3 := "centralus"

	publickey := os.Getenv("public_key")
	sshkey := os.Getenv("ssh_key")

	agent_vm_count := "3"
	agent_vm_size := "Standard_D2s_v3"

	//Copy env directories as needed to avoid conflicting with other running tests
	azureMultipleClustersFolder := "../cluster/test-temp-envs/azure-multiple-clusters-" + k8sName
	copy.Copy("../cluster/environments/azure-multiple-clusters", azureMultipleClustersFolder)

	//Specify the test case folder and "-var" options
	tfOptions := &terraform.Options{
		TerraformDir: azureMultipleClustersFolder,
		Vars: map[string]interface{}{
			"cluster_name":             k8sName,
			"agent_vm_count":           agent_vm_count,
			"agent_vm_size":            agent_vm_size,
			"dns_prefix":               dnsprefix,
			"service_principal_id":     clientid,
			"service_principal_secret": clientsecret,
			"ssh_public_key":           publickey,
			"gitops_ssh_url":           "git@github.com:timfpark/fabrikate-cloud-native-manifests.git",
			"gitops_ssh_key":           sshkey,
			"gitops_poll_interval":     "5m",
			"keyvault_name":            kvName,
			"keyvault_resource_group":  kvRG,

			"traffic_manager_profile_name":            tmName,
			"traffic_manager_dns_name":                tm_dnsprefix,
			"traffic_manager_resource_group_name":     k8s_globalRG,
			"traffic_manager_resource_group_location": location,

			"west_resource_group_name":     k8s_westRG,
			"west_resource_group_location": "westus2",
			"gitops_west_path":             "",

			"east_resource_group_name":     k8s_eastRG,
			"east_resource_group_location": "eastus2",
			"gitops_east_path":             "",

			"central_resource_group_name":     k8s_centralRG,
			"central_resource_group_location": "centralus",
			"gitops_central_path":             "",
		},
	}

	//Terraform init, apply, output, and destroy
	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	westCluster_out := cluster_location1 + "_" + k8sName + "_kube_config"
	eastCluster_out := cluster_location2 + "_" + k8sName + "_kube_config"
	centralCluster_out := cluster_location3 + "_" + k8sName + "_kube_config"

	//Obtain Kube_config file from module outputs of each cluster region
	os.Setenv("WEST_KUBECONFIG", azureMultipleClustersFolder+"/output/"+westCluster_out)
	os.Setenv("EAST_KUBECONFIG", azureMultipleClustersFolder+"/output/"+eastCluster_out)
	os.Setenv("CENTRAL_KUBECONFIG", azureMultipleClustersFolder+"/output/"+centralCluster_out)

	//Test Case 1: Verify Flux namespace in West Region
	kubeConfig := os.Getenv("WEST_KUBECONFIG")
	options := k8s.NewKubectlOptions("", kubeConfig)

	fmt.Println("Test case 1-3: Verifying flux namespace in all 3 cluster regions")
	_flux, fluxErr := k8s.RunKubectlAndGetOutputE(t, options, "get", "po", "--namespace=flux")
	if fluxErr != nil || !strings.Contains(_flux, "flux") {
		t.Fatal(fluxErr)
	} else {
		fmt.Println("Flux verification for West Cluster complete")
	}

	//Test Case 2: Verify Flux namespace in East Region
	kubeConfig2 := os.Getenv("EAST_KUBECONFIG")
	options2 := k8s.NewKubectlOptions("", kubeConfig2)

	_flux2, fluxErr2 := k8s.RunKubectlAndGetOutputE(t, options2, "get", "po", "--namespace=flux")
	if fluxErr2 != nil || !strings.Contains(_flux2, "flux") {
		t.Fatal(fluxErr2)
	} else {
		fmt.Println("Flux verification for East Cluster complete")
	}

	//Test Case 3: Verify Flux namespace in Central Region
	kubeConfig3 := os.Getenv("CENTRAL_KUBECONFIG")
	options3 := k8s.NewKubectlOptions("", kubeConfig3)

	_flux3, fluxErr3 := k8s.RunKubectlAndGetOutputE(t, options3, "get", "po", "--namespace=flux")
	if fluxErr3 != nil || !strings.Contains(_flux3, "flux") {
		t.Fatal(fluxErr3)
	} else {
		fmt.Println("Flux verification for Central Cluster complete")
	}

	//Test Case 4: Verify keyvault namespace flex in West Region
	fmt.Println("Test case 4: Verifying flexvolume and kv namespace in West Region")
	_flex, flexErr := k8s.RunKubectlAndGetOutputE(t, options, "get", "po", "--namespace=kv")
	if flexErr != nil || !strings.Contains(_flex, "keyvault-flexvolume") {
		t.Fatal(flexErr)
	} else {
		fmt.Println("Flexvolume verification for West Region complete")
	}

	//Test Case 5: Verify keyvault namespace flex in East Region
	fmt.Println("Test case 5: Verifying flexvolume and kv namespace in East Region")
	_flex, flexErr2 := k8s.RunKubectlAndGetOutputE(t, options2, "get", "po", "--namespace=kv")
	if flexErr2 != nil || !strings.Contains(_flex, "keyvault-flexvolume") {
		t.Fatal(flexErr2)
	} else {
		fmt.Println("Flexvolume verification East Region complete")
	}

	//Test Case 6: Verify keyvault namespace flex in Central Region
	fmt.Println("Test case 6: Verifying flexvolume and kv namespace in Central Region")
	_flex, flexErr3 := k8s.RunKubectlAndGetOutputE(t, options3, "get", "po", "--namespace=kv")
	if flexErr3 != nil || !strings.Contains(_flex, "keyvault-flexvolume") {
		t.Fatal(flexErr3)
	} else {
		fmt.Println("Flexvolume verification Central Region complete")
	}

	//Obtain public IP addresses for all 3 clusters
	westIP_address_file := terraform.Output(t, tfOptions, "west_publicIP")
	eastIP_address_file := terraform.Output(t, tfOptions, "east_publicIP")
	centralIP_address_file := terraform.Output(t, tfOptions, "central_publicIP")

	westIP, err := ioutil.ReadFile(azureMultipleClustersFolder + "/output/" + westIP_address_file)
	if err != nil {
		panic(err)
	}
	eastIP, err2 := ioutil.ReadFile(azureMultipleClustersFolder + "/output/" + eastIP_address_file)
	if err2 != nil {
		panic(err2)
	}
	centralIP, err3 := ioutil.ReadFile(azureMultipleClustersFolder + "/output/" + centralIP_address_file)
	if err3 != nil {
		panic(err3)
	}

	fmt.Println("West Cluster IP: " + string(westIP))
	fmt.Println("East Cluster IP: " + string(eastIP))
	fmt.Println("Central Cluster IP: " + string(centralIP))

	//Deploy app to all 3 clusters
	configFile := "azure-vote.yaml"

	addIPandRGtoYAML(configFile, string(westIP), k8s_westRG)
	k8s.KubectlApply(t, options, configFile)
	addIPandRGtoYAML(configFile, string(eastIP), k8s_eastRG)
	k8s.KubectlApply(t, options2, configFile)
	addIPandRGtoYAML(configFile, string(centralIP), k8s_centralRG)
	k8s.KubectlApply(t, options3, configFile)

	//Test Case 7: Validate Traffic Manager
	testTM_URL := "http://" + tm_dnsprefix + ".trafficmanager.net"

	// It can take several minutes or so for the app to be deployed, so retry a few times
	maxRetries := 60
	timeBetweenRetries := 5 * time.Second

	//Verify that we get a 200 OK response and response text contains `Cats` otherwise clean up AKS load balancer and destroy resources
	//Bedrock is using the azure-vote.yaml service that provisions a stateless simple voting app using redis on all clusters
	_reqErr := http_helper.HttpGetWithRetryWithCustomValidationE(t, testTM_URL, nil, maxRetries, timeBetweenRetries, func(status int, body string) bool {
		return status == 200 && strings.Contains(body, `"Cats"`)
	})

	if _reqErr != nil {
		fmt.Println("Error validating Traffic Manager - Removing cluster load balancer and Destroying resources")
		_clean, cleanErr := k8s.RunKubectlAndGetOutputE(t, options, "delete", "service", "azure-vote-front")
		if cleanErr != nil || !strings.Contains(_clean, "delete") {
			t.Fatal(cleanErr)
		} else {
			fmt.Println("Clean verification for West Cluster complete")
		}
		_clean2, cleanErr2 := k8s.RunKubectlAndGetOutputE(t, options2, "delete", "service", "azure-vote-front")
		if cleanErr2 != nil || !strings.Contains(_clean2, "delete") {
			t.Fatal(cleanErr2)
		} else {
			fmt.Println("Clean verification for East Cluster complete")
		}
		_clean3, cleanErr3 := k8s.RunKubectlAndGetOutputE(t, options3, "delete", "service", "azure-vote-front")
		if cleanErr3 != nil || !strings.Contains(_clean3, "delete") {
			t.Fatal(cleanErr3)
		} else {
			fmt.Println("Clean verification for Central Cluster complete")
		}
		//Sleep job for 2 minutes while load balancer deallocates
		time.Sleep(120 * time.Second)
		t.Fatal(cleanErr)
	} else {
		fmt.Println("Traffic Manager Validation successful")
	}
	//Clean up Cluster load balancers
	fmt.Println("Removing cluster load balancer and Destroying resources")
	_clean, cleanErr := k8s.RunKubectlAndGetOutputE(t, options, "delete", "service", "azure-vote-front")
	if cleanErr != nil || !strings.Contains(_clean, "delete") {
		t.Fatal(cleanErr)
	} else {
		fmt.Println("Clean verification for West Cluster complete")
	}
	_clean2, cleanErr2 := k8s.RunKubectlAndGetOutputE(t, options2, "delete", "service", "azure-vote-front")
	if cleanErr2 != nil || !strings.Contains(_clean2, "delete") {
		t.Fatal(cleanErr2)
	} else {
		fmt.Println("Clean verification for East Cluster complete")
	}
	_clean3, cleanErr3 := k8s.RunKubectlAndGetOutputE(t, options3, "delete", "service", "azure-vote-front")
	if cleanErr3 != nil || !strings.Contains(_clean3, "delete") {
		t.Fatal(cleanErr3)
	} else {
		fmt.Println("Clean verification for Central Cluster complete")
	}
	//Sleep job for 2 minutes while load balancer deallocates
	time.Sleep(120 * time.Second)
}
