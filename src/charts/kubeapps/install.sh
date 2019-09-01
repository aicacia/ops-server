#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=kube-public

source $dir/../../functions.sh

begin_readme_section "kubeapps"

host="kubeapps.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

kubectl create serviceaccount kubeapps-operator --namespace=${tiller_namespace}
kubectl create clusterrolebinding kubeapps-operator --clusterrole=cluster-admin --serviceaccount=${tiller_namespace}:kubeapps-operator

secret_token=$(kubectl get secret -n ${tiller_namespace} $(kubectl get serviceaccount kubeapps-operator -n ${tiller_namespace} -o jsonpath='{.secrets[].name}') -o jsonpath='{.data.token}' | base64 --decode)

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install bitnami/kubeapps \
    --name kubeapps \
    --namespace ${namespace} \
    --values $dir/values.yaml \
    --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
    --set ingress.certManager=true \
    --set ingress.hosts[0].name=${host} \
    --set ingress.hosts[0].tls=true \
    --set ingress.hosts[0].tlsSecret=$secret_name \
    --set tillerProxy.host=tiller-deploy.${tiller_namespace}:44134 \
    --set apprepository.initialRepos[3].url=${chartmuseum_url} \
    --set apprepository.initialRepos[3].username=${chartmuseum_user} \
    --set apprepository.initialRepos[3].password=${chartmuseum_password}

  kubeapps_url="https://${host}"  
else
  helm install bitnami/kubeapps \
    --name kubeapps \
    --namespace ${namespace} \
    --values $dir/values.yaml \
    --set ingress.hosts[0].name=${host} \
    --set tillerProxy.host=tiller-deploy.${tiller_namespace}:44134 \
    --set apprepository.initialRepos[3].url=${chartmuseum_url} \
    --set apprepository.initialRepos[3].username=${chartmuseum_user} \
    --set apprepository.initialRepos[3].password=${chartmuseum_password}

  kubeapps_url="https://${host}"  
fi

add_variable "kubeapps_url" ${kubeapps_url}

add_to_readme "url: ${kubeapps_url}"
add_to_readme "secret token: ${secret_token}"

wait_for_deployment "kubeapps" ${namespace}

end_readme_section "kubeapps"