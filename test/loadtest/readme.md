# Distributed load testing using Bedrock kubernetes Cluster and Locust

Load testing is crucial to any application's success. We have chosen to use Locust as a tool for facilitating the load testing of the solution you have deployed in Bedrock. In order to begin load testing your application, make sure you have a cluster to deploy the Locust load tester on. If you do not have a load-testing cluster, follow the directions in [azure-simple](../../cluster/environments/azure-simple/) and use that cluster when you execute the following steps.

## Setup

1. Clone or download `Bedrock` git repo and navigate to `test/loadtest` folder.
2. Update the `locust-tasks\tasks.py` file specific to however you would like your load test to be run. More details about how to write the tasks file can be found in the [Locust documentation](https://docs.locust.io/en/stable/writing-a-locustfile.html). All files in `locust-tasks` will be mounted to POD.
3. Build docker image and store it in your container registry such as docker or Azure Container Registry.
    * Make sure you are logged into Azure subscription

        ```az login```

	* Login to your desired Azure Container Registry using 
    
        ```az acr login --name <ACR_NAME>```

	* Build your image by running

        ```docker build . -t locust```        

	* Tag your image in order to push it up to the registry: 
    
        ```docker tag <IMAGE_HASH> <ACR_NAME>.azurecr.io/<DESIRED_CONTAINER_NAME>:<DESIRED_VERSION_NUMBER>```

	* Push to your registgry by running 
    
        ```docker push <ACR_NAME>.azurecr.io/loadtesting/<DESIRED_CONTAINER_NAME>:<DESIRED_VERSION_NUMBER>```

4. Deploy Locust onto your Cluster

    * Ensure that `kubectl` is set to connect to your load testing cluster.
    * Make script file executable

        ```chmod +x deploy_locust.sh```

    * Run `deploy_locust.sh` by specifying values for the following parameters. Here is an example:

        ```./deploy_locust.sh -r "myDockerRegistry/locust" -t "0.1.0" -h "http://servicetotest.com"  -w "7" ```

        | Parameter                    | Description                             | Required                                               |
        | ---------------------------- | ----------------------------------      | ----------------------------------------------------- |
        | `-r`           | Locust container image name             | yes                                 |
        | `-t`                  | Locust container image tag              | yes                                               |
        | `-s`          | Locust Container image registry secret for private repositories. For Azure Conatiner Registry, more details can be found on [this page](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks).  | No                                                |
        | `-h`  | load test target host                      | yes                             |
        | `-c`| name of the kubernetes configmap to create from `tasks.py` file in the loadtest folder. Default value is `locust-tasks-config`  | no |
        | `-w`        | Number of workers to run for load generation               | yes                                                   |
        | `-n`        | name of the kubernetes namespace to create and deploy locust. Default value is `load-test`               | no
        | `-k`        | API authentication key for the load test to authenticate with the target API. It will be set as a value for `API_AUTH_KEY` environment variable in the POD which can accessed by locust tasks it in the runtime.               | no
         | `-p`        | API authentication secret for the load test to authenticate with the target API. It will be set as a value for `API_AUTH_SECRET` environment variable in the POD which can accessed by locust tasks it in the runtime.               | yes, when `-k` argument is passed. Otherwise optional. 
    
5. Check your deployment
    * To see that your load test `locust` pods are running.
    
        ```kubectl get pods -n load-test --watch```

    * To see that your load test `locust` service is running and get the public ip.
    
        ```kubectl get svc locust-master-svc --watch -n load-test```
    * The locust interface should then be available at `<PUBLIC_IP>:8089`.

## Cleanup

1. Run the following command to delete kubernetes namespace and its resources:

    ```kubectl delete namespace load-test```
    

## Update your Load Tests

When you have already created your container and deployed your locust image to your cluster, you may want to change some of your load tests by editing the `tasks.py` file. After you edit your `tasks.py` file, follow steps in following sections:

1. Delete the deployment as described in [Cleanup](#cleanup) section
2. Redeploy `locust` from [step 4 in Setup](#Setup) section without rebuilding the docker image.
