# Distributed Load Testing on Bedrock Kubernetes Clusters with Locust
Load testing is crucial to any application's success. We have chosen to use Locust as a tool for facilitating the load testing of the solution you have deployed in Bedrock. In order to begin load testing your application, make sure you have a _dedicated load testing cluster_ to deploy the Locust. If you do not have a _dedicated load testing cluster_, follow the directions in [azure-simple](../../cluster/environments/azure-simple/) and use that cluster when you execute the following steps.

## Setup

1. Clone or download `Bedrock` git repo and navigate to `test/loadtest` folder.
2. You must _update_ or _rewrite_ the `locust-tasks\tasks.py` file specific to your application/API scenarios to simulate in the load test. You can also create addiitonal python modules (`.py`) as necessary to organize the code and all files in the `locust-tasks` folder will be mounted to container.

    More details about how to write the load testing tasks file can be found in the [Locust documentation](https://docs.locust.io/en/stable/writing-a-locustfile.html).
    
3. Create docker image and upload it to any docker container registry that you’d prefer. 

	* Log in to the Docker public registry on your local machine:
        
        ```$ docker login```

    * Build your image and assign a name with `--tag` option:

        ```$ docker build . --tag=<image name>```. 
        
        For ex: ```$ docker build . --tag="locust"```        

	* Associate the local image with a repository on a registry:
    
        ```$ docker tag image <username>/<repository>:<tag>```

        For ex: ```$ docker tag locust mycr/locust:0.1.0```

	* Upload your tagged image to the repository:
    
        ```$ docker push username/repository:tag```

        For ex: ```$ docker push mycr/locust:0.1.0```

4. Deploy Locust onto your Cluster

    * Ensure that `kubectl` is set to connect to your load testing cluster.
    * Run `deploy_locust.sh` by specifying values for the following parameters. Here is an example:

        ```$ ./deploy_locust.sh -r "myDockerRegistry/locust" -t "0.1.0" -h "http://servicetotest.com"  -w "7" ```
        
        *if you get a permission error, make script file executable by running the following command.*

        ```$ chmod +x deploy_locust.sh```

        | Parameter                    | Description                             | Required                                               |
        | ---------------------------- | ----------------------------------      | ----------------------------------------------------- |
        | `-r`           | Locust container image name             | yes                                 |
        | `-t`                  | Locust container image tag              | yes                                               |
        | `-s`          | Locust Container image registry secret for private repositories. For Azure Conatiner Registry, more details can be found on [this page](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks).  | No                                                |
        | `-h`  | It is a root of the target application / service endpoint that will be load tested using this framework. The [`tasks.py` in step 2](#Setup) will define tasks using relative paths which route to be tested.              | yes                             |
        | `-c`| Name of the kubernetes configmap to create from `tasks.py` file in the loadtest folder. Default value is `locust-tasks-config`  | no |
        | `-w`        | Number of workers to run for load generation               | yes                                                   |
        | `-n`        | Name of the kubernetes namespace to create and deploy locust. Default value is `load-test`               | no
        | `-k`        | API authentication key for the load test to authenticate with the target API. It will be set as a value for `API_AUTH_KEY` environment variable in the POD which can accessed by locust tasks it in the runtime.               | yes, when `-p` argument is passed. Otherwise optional.
         | `-p`        | API authentication secret for the load test to authenticate with the target API. It will be set as a value for `API_AUTH_SECRET` environment variable in the POD which can accessed by locust tasks it in the runtime.               | yes, when `-k` argument is passed. Otherwise optional. 
    
5. Check your deployment
    * To see that your load test `locust` pods are running.
    
        ```$ kubectl get pods -n load-test --watch```

    * To see that your load test `locust` service is running and get the public ip.
    
        ```$ kubectl get svc locust-master-svc --watch -n load-test```
    * The locust interface should then be available at `<PUBLIC_IP>:8089`.

## Cleanup

1. Run the following command to delete kubernetes namespace and its resources:

    ```$ kubectl delete namespace load-test```
    

## Update your Load Tests

When you have already created your container and deployed your locust image to your cluster, you may want to change some of your load tests by editing the `tasks.py` file. After you edit your `tasks.py` file, follow steps in following sections:

1. Delete the deployment as described in [Cleanup](#cleanup) section
2. Redeploy `locust` from [step 4 in Setup](#Setup) section without rebuilding the docker image.
