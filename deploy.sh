#!/bin/bash

# first export the variables presented by Jelastic after installing
# the kubernetes cluster

# export JELASTIC_K8S_URL="example.jelastic.com/api"
# export JELASTIC_K8S_TOKEN="examplelscbkshft486tro8723yiyfgy4token"

# workaround to not run into Helm (tiller) not being able to
# set up port forwarding. https://github.com/helm/helm/issues/1455#issuecomment-487205430
export HELM_HOST="localhost:44134"
tiller -listen ${HELM_HOST} -alsologtostderr >/dev/null 2>&1 &

# set up Jelastic kubectl environment
kubectl config set-cluster jelastic --server=${JELASTIC_K8S_URL} && \
kubectl config set-context jelastic --cluster=jelasticzz && \
kubectl config set-credentials user --token=${JELASTIC_K8S_TOKEN} && \
kubectl config set-context jelastic --user=user && \
kubectl config use-context jelastic

# install Garden.io
curl -sL https://get.garden.io/install.sh | bash

# initialize cluster tools
garden init

# install cluster requirements
garden plugins kubernetes cluster-init --env=remote

# now do th deploy, which will fail with a port forwarding error
garden deploy

# run into this issue:
# - https://github.com/helm/helm/issues/2463#issuecomment-517323123

# run garden deploy --log-level=silly to see the actual HTTP request failing
