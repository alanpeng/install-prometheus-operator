#!/bin/bash
set -e

PrometheusOperatorVersion=0.28.0
NAMESPACE=monitoring

rm -rf prometheus-operator-$PrometheusOperatorVersion
tar zxf ../../offline-files/sourcecode/offline-prometheus-operator-$PrometheusOperatorVersion.tar.gz
cd prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/

kctl() {
    kubectl --namespace "$NAMESPACE" "$@"
}

kubectl apply -f manifests/phase1

# Wait for CRDs to be ready.
printf "Waiting for Operator to register custom resource definitions..."
until kctl get customresourcedefinitions servicemonitors.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done
until kctl get customresourcedefinitions prometheuses.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done
until kctl get customresourcedefinitions alertmanagers.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done
until kctl get servicemonitors.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done
until kctl get prometheuses.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done
until kctl get alertmanagers.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done
echo 'Phase1 done!'

kubectl apply -f manifests/phase2

echo 'Phase2 done!'

cd ../../../
rm -rf prometheus-operator-$PrometheusOperatorVersion
