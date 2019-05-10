package test

import (
        "fmt"
        "os"
        "strings"
        "testing"
        "time"
        "io/ioutil"
        "log"
        "context"
        "github.com/Azure/go-autorest/autorest/azure/auth"
        "github.com/Azure/azure-sdk-for-go/profiles/preview/preview/apimanagement/mgmt/apimanagement"
        "github.com/gruntwork-io/terratest/modules/k8s"
        "github.com/gruntwork-io/terratest/modules/random"
        "github.com/gruntwork-io/terratest/modules/terraform"
   
)

func addIPtoYAMLAPIM(input string, ipaddress string) {
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

func TestIT_Bedrock_AzureMC_APIM_Test(t *testing.T) {
        //t.Parallel()

        //Generate a random cluster name to prevent a naming conflict and map variables to tfvars
        uniqueID := strings.ToLower(random.UniqueId())
        k8sName := fmt.Sprintf("gtestk8s-%s", uniqueID)
        tmName := k8sName + "-tm"

        clientid := os.Getenv("ARM_CLIENT_ID")
        clientsecret := os.Getenv("ARM_CLIENT_SECRET")
        tenantid := os.Getenv("ARM_TENANT_ID")
        subscriptionid := os.Getenv("ARM_SUBSCRIPTION_ID")


        ctx := context.Background()

        dnsprefix := k8sName + "-dns"
        tm_dnsprefix := uniqueID + "tmdns"

        k8s_eastRG := k8sName + "-east-rg"
        k8s_westRG := k8sName + "-west-rg"
        k8s_centralRG := k8sName + "-central-rg"
        k8s_globalRG := k8sName + "-global-rg"
        // update based on Terraform variable
        resourcegroupname := k8s_globalRG //"apimgmtresgrp5"
        apiname := "Voting"
        apiservicename := "apimgmt-tm"

        location := os.Getenv("DATACENTER_LOCATION")
        cluster_location1 :="westus"
        cluster_location2 :="eastus"
        cluster_location3 :="centralus"

        publickey := os.Getenv("public_key")
        sshkey := os.Getenv("ssh_key")
        tfOptions := &terraform.Options{
                TerraformDir: "../cluster/environments/azure-multiple-clusters-waf-tm-apimgmt",
                Vars: map[string]interface{}{
                        "cluster_name": k8sName,
                        "agent_vm_count":       3,
                        "dns_prefix":   dnsprefix,
                        "service_principal_id": clientid,
                        "service_principal_secret":     clientsecret,
                        "ssh_public_key":       publickey,
                        "gitops_ssh_url":       "git@github.com:timfpark/fabrikate-cloud-native-manifests.git",
                        "gitops_ssh_key":       sshkey,
                        "gitops_poll_interval": "5m",

                        "traffic_manager_profile_name": tmName,
                        "traffic_manager_dns_name":     tm_dnsprefix,
                        "traffic_manager_resource_group_name":  k8s_globalRG,
                        "traffic_manager_resource_group_location":      location,

                        "west_resource_group_name":     k8s_westRG,
                        "west_resource_group_location": "westus",
                        "gitops_west_path":     "",

                        "east_resource_group_name":     k8s_eastRG,
                        "east_resource_group_location": "eastus",
                        "gitops_east_path":     "",

                        "central_resource_group_name":  k8s_centralRG,
                        "central_resource_group_location":      "centralus",
                        "gitops_central_path":  "",
                },
        }

        //Terraform init, apply, output, and destroy
       
        terraform.InitAndApply(t, tfOptions)

        westCluster_out :=      cluster_location1 + "-" + k8sName + "_kube_config"
        eastCluster_out :=      cluster_location2 + "-" + k8sName + "_kube_config"
        centralCluster_out:=    cluster_location3 + "-" + k8sName + "_kube_config"

        //Obtain Kube_config file from module outputs of each cluster region
        os.Setenv("WEST_KUBECONFIG", "../cluster/environments/azure-multiple-clusters-waf-tm-apimgt/output/"+westCluster_out)
        os.Setenv("EAST_KUBECONFIG", "../cluster/environments/azure-multiple-clusters-waf-tm-apimgt/output/"+eastCluster_out)
        os.Setenv("CENTRAL_KUBECONFIG", "../cluster/environments/azure-multiple-clusters-waf-tm-apimgt/output/"+centralCluster_out)

        //Test Case 1: Verify Flux namespace in West Region
        kubeConfig := os.Getenv("WEST_KUBECONFIG")
        options := k8s.NewKubectlOptions("", kubeConfig)

        fmt.Println("Test case 1-3: Verifying flux namespace in all 3 cluster regions")
        fmt.Println("Testing Multiple Geo Clusters with API Management")
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

        westIP, err := ioutil.ReadFile("../cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/output/"+westIP_address_file)
        if err != nil {
        panic(err)
        }
        eastIP, err2 := ioutil.ReadFile("../cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/output/"+eastIP_address_file)
        if err2 != nil {
        panic(err2)
       }
        centralIP, err3 := ioutil.ReadFile("../cluster/environments/azure-multiple-clusters-waf-tm-apimgmt/output/"+centralIP_address_file)
        if err3 != nil {
        panic(err3)
        }

        fmt.Println("West Cluster IP: "+string(westIP))
        fmt.Println("East Cluster IP: "+string(eastIP))
        fmt.Println("Central Cluster IP: "+string(centralIP))

        //Deploy app to all 3 clusters
        configFile := "azure-vote.yaml"

        addIPtoYAMLAPIM(configFile, string(westIP))
        k8s.KubectlApply(t, options, configFile)
        addIPtoYAMLAPIM(configFile, string(eastIP))
        k8s.KubectlApply(t, options2, configFile)
        addIPtoYAMLAPIM(configFile, string(centralIP))
		k8s.KubectlApply(t, options3, configFile)
		
        // Test Case 4: Validate API Management - API created for Voting
        if len(clientid) > 0 {
                log.Printf("Setting client ID")
                os.Setenv("AZURE_CLIENT_ID",clientid)
        }
        if len(clientsecret) > 0 {
                log.Printf("Setting client secret")
                os.Setenv("AZURE_CLIENT_SECRET",clientsecret)
        }
        if len(tenantid)>0 {
                log.Printf("Setting Tenant ID")
                os.Setenv("AZURE_TENANT_ID",tenantid)
        }
        if len(subscriptionid)>0{
               log.Printf("Setting Subscription ID")
               os.Setenv("AZURE_SUBSCRIPTION_ID",subscriptionid)
        }
        apim :=  apimanagement.NewAPIClient(subscriptionid)
        authorizer, err := auth.NewAuthorizerFromEnvironment()
        if err == nil {
                apim.Authorizer = authorizer
        } else {
                t.Log("Couldnt find environment variables for client credentials, initiatig Azure CLI ...")
                authorizer, err1 := auth.NewAuthorizerFromCLI()
                if err1 == nil {
                        apim.Authorizer = authorizer
                }
        }
        apicontract,err := apim.Get(ctx, resourcegroupname,apiservicename,apiname)

        if err != nil {
                fmt.Println("Error validating API Management - Removing cluster load balancer and Destroying resources")
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
                
                name :=  *apicontract.Name
                fmt.Println("Test Passed API created  ")
                fmt.Println(name)
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
        defer terraform.Destroy(t, tfOptions)
        //Sleep job for 2 minutes while load balancer deallocates
        time.Sleep(120 * time.Second)
}
