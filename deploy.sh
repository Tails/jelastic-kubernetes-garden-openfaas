#!/bin/bash

# first export the variables presented by Jelastic after installing
# the kubernetes cluster

# export JELASTIC_K8S_URL="example.jelastic.com/api"
# export JELASTIC_K8S_TOKEN="examplelscbkshft486tro8723yiyfgy4token"
echo "Jelastic Kubernetes URL: $JELASTIC_K8S_URL"
echo "Jelastic Kubernetes Access Token: $JELASTIC_K8S_TOKEN"

if [ -z "$JELASTIC_K8S_URL" ]
then
      exit "JELASTIC_K8S_URL env var not set!"
else if [ -z "$JELASTIC_K8S_TOKEN" ]
      exit "JELASTIC_K8S_TOKEN env var not set!"
fi

# workaround to not run into Helm (tiller) not being able to
# set up port forwarding. https://github.com/helm/helm/issues/1455#issuecomment-487205430
export HELM_HOST=":44134"
killall tiller
tiller -listen localhost:44134 -alsologtostderr >/dev/null 2>&1 &

# set up Jelastic kubectl environment
kubectl config set-cluster jelastic --server=${JELASTIC_K8S_URL} && \
kubectl config set-context jelastic --cluster=jelastic && \
kubectl config set-credentials user --token=${JELASTIC_K8S_TOKEN} && \
kubectl config set-context jelastic --user=user && \
kubectl config use-context jelastic

# install Garden.io
export PATH=$PATH:$HOME/.garden/bin
if [ -f "$HOME/.garden/bin/garden" ]; then
    echo "Garden.io found"
else
    curl -sL https://get.garden.io/install.sh | bash
fi

# initialize cluster tools
garden init && \

# install cluster requirements
garden plugins kubernetes cluster-init --env=remote && \

# now do the deploy, which will fail with a port forwarding error
garden deploy

# run into this issue:
# - https://github.com/helm/helm/issues/2463#issuecomment-517323123
#
# Running: ~/.garden/tools/kubectl/b57d7033ebdf2a5a/kubectl --context=jelastic --namespace=garden-system port-forward Deployment/garden-docker-registry 59826:5000
#
# Failed building hello-function. Here is the output:
# Could not query in-cluster registry: Error: Port forward exited with code 1 before establishing connection:
# error: error upgrading connection: Upgrade request required
#

# run verbose to see the actual HTTP POST request failing
# ~/.garden/tools/kubectl/b57d7033ebdf2a5a/kubectl -v=10 --context=jelastic --namespace=garden-system port-forward Deployment/garden-docker-registry 59826:5000

# clean up demo
killall tiller
