#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")
cluster_name=$1
namespace=ci

source $dir/../../functions.sh

begin_readme_section "chartmuseum"

host="chartmuseum.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/chartmuseum \
  --version 2.3.2 \
  --name chartmuseum \
  --namespace ${namespace} \
  --values $dir/values.yaml \
  --set env.secret.BASIC_AUTH_USER=$CHART_MUSEUM_USER \
  --set env.secret.BASIC_AUTH_PASS=$CHART_MUSEUM_PASS \
  --set ingress.hosts[0].name=$host \
  --set ingress.hosts[0].tls=true \
  --set ingress.hosts[0].tlsSecret=$secret_name \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME
  
  chartmuseum_url="https://${host}"
else
  helm install stable/chartmuseum \
  --version 2.3.2 \
  --name chartmuseum \
  --namespace ${namespace} \
  --values $dir/values.yaml \
  --set env.secret.BASIC_AUTH_USER=$CHART_MUSEUM_USER \
  --set env.secret.BASIC_AUTH_PASS=$CHART_MUSEUM_PASS \
  --set ingress.hosts[0].name=$host

  chartmuseum_url="http://${host}"
fi

add_variable "chartmuseum_url" ${chartmuseum_url}
add_variable "chartmuseum_user" ${CHART_MUSEUM_USER}
add_variable "chartmuseum_password" ${CHART_MUSEUM_PASS}

add_to_readme "url: ${chartmuseum_url}"
add_to_readme "user: ${CHART_MUSEUM_USER}"
add_to_readme "password: ${CHART_MUSEUM_PASS}"

wait_for_deployment "chartmuseum-chartmuseum" ${namespace}

helm plugin install https://github.com/chartmuseum/helm-push
helm repo add chartmuseum ${chartmuseum_url} --username="${CHART_MUSEUM_USER}" --password="${CHART_MUSEUM_PASS}"
helm push --help

end_readme_section "chartmuseum"