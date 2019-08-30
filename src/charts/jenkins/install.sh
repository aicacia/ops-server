#!/bin/bash

dir=$(readlink -f "$(dirname "$0")")

source $dir/../../functions.sh

begin_readme_section "jenkins"

host="jenkins.$HOST"
secret_name=$(echo "$host" | sed -e 's/[_\.]/-/g')-tls

kubectl apply -f $dir/jenkins-persistent-volume.yaml
kubectl apply -f $dir/jenkins-persistent-volume-claim.yaml

if [[ "${cluster_type}" == "cluster" ]];
then
  helm install stable/jenkins \
  --name jenkins \
  --namespace ci \
  --values $dir/values.yaml \
  --set master.ingress.hostName=$host \
  --set master.ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=$ISSUER_NAME \
  --set master.ingress.tls[0].secretName=$secret_name \
  --set master.ingress.tls[0].hosts[0]=$host
else
  helm install stable/jenkins \
  --name jenkins \
  --namespace ci \
  --values $dir/values.yaml \
  --set master.ingress.hostName=$host
fi

wait_for_deployment "jenkins" "ci"

add_to_readme "host: ${host}"
add_to_readme "user: admin"
add_to_readme "password: $(kubectl get secret --namespace ci jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)"

end_readme_section "jenkins"