#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

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
else
  helm install stable/docker-registry \
    --name docker-registry \
    --namespace ci \
    --values $dir/values.yaml \
    --set ingress.hosts[0]=$host \
    --set secrets.htpasswd=$DOCKER_HTPASSWD
fi

wait_for_deployment "docker-registry" "ci"

add_to_readme "host: ${host}"

end_readme_section "docker-registry"