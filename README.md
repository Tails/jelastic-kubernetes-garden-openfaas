# Deploying OpenFaas project to Jelastic Kubernetes using Garden.io
This is taken from the Garden.io examples repository (https://github.com/garden-io/garden/tree/master/examples/openfaas).
It is an example project of an OpenFaaS environment with a function.
It uses the Garden.io environment to build and deploy services to
a Jelastic Kubernetes cluster.

This repository is intended to show where errors occur with the Jelastic cluster
that do not appear when deploying the project to a different host, i.e. Google Cloud.

## Setup

1. Deploy Jelastic Kubernetes cluster as described here: https://docs.jelastic.com/kubernetes-cluster-installation

2. Note the environment URL and the token that are presented:

``` bash
export JELASTIC_K8S_URL="example.jelastic.com/api"
export JELASTIC_K8S_TOKEN="examplelscbkshft486tro8723yiyfgy4token"
```

3. change the ```defaultHostname: jelastic-kubernetes-garden-openfaas.fr-1.paas.massivegrid.net``` value in garden.yml to the URL set in step 2. (TODO: use string template referencing the env var)

4. Run ```./deploy.sh```

This will:

- install the Garden.io orchestrator
- start a local Tiller instance in the background
- configure kubectl to use the Jelastic cluster
- let Garden configure the cluster
- let Garden _try_ to deploy the example app, but fail

5. We should be able to run ```garden call hello-container/hello```, but we won't get there.

## Debugging the 'Error: forwarding ports: Upgrade request failed' error

Run ```garden deploy --log-level=silly``` to see the raw HTTP calls done to the Jelastic Kubernetes cluster that fail. Note that this failing API call seems to bypass the Ingress. I've tried this setup with all the three types of Ingresses supported by Jelastic, but it made no difference since the problem call goes straight for the API.

``` bash
# error
Failed building hello-function. Here is the output:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Could not query in-cluster registry: Error: Port forward exited with code 1 before establishing connection:

error: error upgrading connection: Upgrade request required
```

After running:

``` bash
.garden/tools/kubectl/b57d7033ebdf2a5a/kubectl --context=jelastic --namespace=garden-system port-forward Deployment/garden-docker-registry 56235:5000
```

## TODO: how to show Kubernetes logs for this API request?
