#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../../functions.sh

begin_readme_section "chartmuseum"

host="chartmuseum.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/chartmuseum \
  --name chartmuseum \
  --namespace ci \
  --values $dir/values.yaml \
  --set env.secret.BASIC_AUTH_USER=$CHART_USER \
  --set env.secret.BASIC_AUTH_PASS=$CHART_PASS \
  --set ingress.hosts[0].name=$host \
  --set ingress.hosts[0].tls=true \
  --set ingress.hosts[0].tlsSecret=$secret_name \
  --set ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME

  add_to_readme "${host}"
else
  helm install stable/chartmuseum \
  --name chartmuseum \
  --namespace ci \
  --values $dir/values.yaml \
  --set env.secret.BASIC_AUTH_USER=$CHART_USER \
  --set env.secret.BASIC_AUTH_PASS=$CHART_PASS \
  --set ingress.hosts[0].name=$host
fi

wait_for_deployment "chartmuseum-chartmuseum" "ci"

add_to_readme "host: ${host}"
add_to_readme "user: ${CHART_USER}"
add_to_readme "passwird: ${CHART_PASS}"

helm plugin install https://github.com/chartmuseum/helm-push
helm repo add chartmuseum http://$host
helm push --help

end_readme_section "chartmuseum"