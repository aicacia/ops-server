#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1

source $dir/../../functions.sh

begin_readme_section "docker-registry"

host="registry.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/docker-registry \
  --name docker-registry \
  --namespace ci \
  --values $dir/values.yaml \
  --set ingress.hosts[0]=$host \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set ingress.tls[0].hosts[0]=$host \
  --set ingress.tls[0].secretName=$secret_name \
  --set secrets.htpasswd=$DOCKER_HTPASSWD

  docker_url="https://${host}"
else
  helm install stable/docker-registry \
    --name docker-registry \
    --namespace ci \
    --values $dir/values.yaml \
    --set ingress.hosts[0]=$host \
    --set secrets.htpasswd=$DOCKER_HTPASSWD

  docker_url="http://${host}"
fi

add_variable "docker_url" ${docker_url}

add_to_readme "url: ${docker_url}"

wait_for_deployment "docker-registry" "ci"

end_readme_section "docker-registry"