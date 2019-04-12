package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"
	"io/ioutil"
	"log"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/http-helper"
)

func addIPtoYAML(input string, ipaddress string) {
	file, err := ioutil.ReadFile(input)

	if err != nil {
		log.Fatalf("failed opening file: %s", err)
	}
	lines := strings.Split(string(file), "\n")
	for i, line := range lines{
		if strings.Contains(line, "loadBalancerIP"){
			lines[i] = "  loadBalancerIP: " + ipaddress
		}
	}
	output := strings.Join(lines, "\n")
	err = ioutil.WriteFile(input, []byte(output), 0644)
}

func TestIT_Bedrock_AzureMC_Test(t *testing.T) {
	t.Parallel()

	//Generate a random cluster name to prevent a naming conflict and map variables to tfvars
	uniqueID := strings.ToLower(random.UniqueId())
	k8sName := fmt.Sprintf("gtestk8s-%s", uniqueID)
	tmName := k8sName + "-tm"

	clientid := os.Getenv("ARM_CLIENT_ID")
	clientsecret := os.Getenv("ARM_CLIENT_SECRET")

	dnsprefix := k8sName + "-dns"
	tm_dnsprefix := uniqueID + "tmdns"

	k8s_eastRG := k8sName + "-east-rg"
	k8s_westRG := k8sName + "-west-rg"
	k8s_centralRG := k8sName + "-central-rg"
	k8s_globalRG := k8sName + "-global-rg"

	location := os.Getenv("DATACENTER_LOCATION")
	cluster_location1 :="westus2"
	cluster_location2 :="eastus2"
	cluster_location3 :="centralus"

	publickey := os.Getenv("public_key")
	sshkey := os.Getenv("ssh_key")

	//Specify the test case folder and "-var" options
	tfOptions := &terraform.Options{
		TerraformDir: "../cluster/environments/azure-multiple-clusters",
		Vars: map[string]interface{}{
			"cluster_name":            					k8sName,
			"agent_vm_count":							3,
			"dns_prefix":               				dnsprefix,
			"service_principal_id":     				clientid,
			"service_principal_secret":					clientsecret,
			"ssh_public_key":           				publickey,
			"gitops_ssh_url": 							"git@github.com:timfpark/fabrikate-cloud-native-manifests.git",
			"gitops_ssh_key":           				sshkey,
			"gitops_poll_interval": 					"5m",

			"traffic_manager_profile_name": 			tmName,
			"traffic_manager_dns_name": 				tm_dnsprefix,
			"traffic_manager_resource_group_name": 		k8s_globalRG,
			"traffic_manager_resource_group_location": 	location,

			"west_resource_group_name": 				k8s_westRG,
			"west_resource_group_location": 			"westus2",
			"gitops_west_path": 						"",

			"east_resource_group_name": 				k8s_eastRG,
			"east_resource_group_location": 			"eastus2",
			"gitops_east_path": 						"",

			"central_resource_group_name": 				k8s_centralRG,
			"central_resource_group_location": 			"centralus",
			"gitops_central_path": 						"",
		},
	}

	//Terraform init, apply, output, and destroy
	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)

	westCluster_out	:= 		cluster_location1 + "-" + k8sName + "_kube_config"
	eastCluster_out	:= 		cluster_location2 + "-" + k8sName + "_kube_config"
	centralCluster_out:= 	cluster_location3 + "-" + k8sName + "_kube_config"
	
	//Obtain Kube_config file from module outputs of each cluster region
	os.Setenv("WEST_KUBECONFIG", "../cluster/environments/azure-multiple-clusters/output/"+westCluster_out)
	os.Setenv("EAST_KUBECONFIG", "../cluster/environments/azure-multiple-clusters/output/"+eastCluster_out)
	os.Setenv("CENTRAL_KUBECONFIG", "../cluster/environments/azure-multiple-clusters/output/"+centralCluster_out)

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

	//Obtain public IP addresses for all 3 clusters
	westIP_address_file := terraform.Output(t, tfOptions, "west_publicIP")
	eastIP_address_file := terraform.Output(t, tfOptions, "east_publicIP")
	centralIP_address_file := terraform.Output(t, tfOptions, "central_publicIP")

	westIP, err := ioutil.ReadFile("../cluster/environments/azure-multiple-clusters/output/"+westIP_address_file)
	if err != nil {
        panic(err)
	}
	eastIP, err2 := ioutil.ReadFile("../cluster/environments/azure-multiple-clusters/output/"+eastIP_address_file)
	if err2 != nil {
        panic(err2)
	}
	centralIP, err3 := ioutil.ReadFile("../cluster/environments/azure-multiple-clusters/output/"+centralIP_address_file)
	if err3 != nil {
        panic(err3)
	}

	fmt.Println("West Cluster IP: "+string(westIP))
	fmt.Println("East Cluster IP: "+string(eastIP))
	fmt.Println("Central Cluster IP: "+string(centralIP))

	//Deploy app to all 3 clusters
	configFile := "azure-vote.yaml"

	addIPtoYAML(configFile, string(westIP))	
	k8s.KubectlApply(t, options, configFile)
	addIPtoYAML(configFile, string(eastIP))	
	k8s.KubectlApply(t, options2, configFile)
	addIPtoYAML(configFile, string(centralIP))	
	k8s.KubectlApply(t, options3, configFile)

	//Test Case 4: Validate Traffic Manager
	testTM_URL := "http://" + tm_dnsprefix + ".trafficmanager.net"

	// It can take several minutes or so for the app to be deployed, so retry a few times
	maxRetries := 60
	timeBetweenRetries := 5 * time.Second

	//Verify that we get a 200 OK response and response text contains `Cats` otherwise clean up AKS load balancer and destroy resources
	//Bedrock is using the azure-vote.yaml service that provisions a stateless simple voting app using redis on all clusters
	_reqErr := http_helper.HttpGetWithRetryWithCustomValidationE(t, testTM_URL, maxRetries, timeBetweenRetries, func(status int, body string) bool {
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
