#!/bin/bash
set -e

MyImageRepositoryIP=192.168.9.20
MyImageRepositoryProject=library
PrometheusOperatorVersion=0.29.0

if [ -f ./v$PrometheusOperatorVersion.tar.gz ];then
  echo "File already exists. No need to copy again."
else
  cp  ../../offline-files/sourcecode/prometheus-operator-v$PrometheusOperatorVersion-origin.tar.gz ./v$PrometheusOperatorVersion.tar.gz
fi

rm -rf prometheus-operator-$PrometheusOperatorVersion
rm -f offline-prometheus-operator-$PrometheusOperatorVersion.tar.gz
tar zxf v$PrometheusOperatorVersion.tar.gz

cd prometheus-operator-$PrometheusOperatorVersion
sed -i "s/quay.io\/coreos/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "quay.io/coreos" ./ |grep .yaml)
sed -i "s/quay.io\/prometheus/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "quay.io/prometheus" ./ |grep .yaml)
sed -i "s/grafana\/grafana/$MyImageRepositoryIP\/$MyImageRepositoryProject\/grafana/g" $(grep -lr "grafana/grafana" ./ |grep .yaml)
sed -i "s/gcr.io\/google_containers/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "gcr.io/google_containers" ./ |grep .yaml)
sed -i "s/gcr.io\/symbolic-datum-552/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "gcr.io/symbolic-datum-552" ./ |grep .yaml)

# For offline deploy
cd ..
rm -f temp.txt
cp -p append-lines.txt temp.txt
sed -i "s/ImageRepositoryIP/$MyImageRepositoryIP/g" temp.txt
sed -i '23 r temp.txt' prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/0prometheus-operator-deployment.yaml
rm -f temp.txt

# Fix issue 2291 of prometheus operator
sed -i "s/0.28.0/$PrometheusOperatorVersion/g" prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/0prometheus-operator-deployment.yaml

# Wait for CRDs to be ready, we need to split all yaml files to two parts
cd prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/
mkdir phase2
mv manifests/0prometheus-operator-serviceMonitor.yaml phase2/
mv manifests/alertmanager-alertmanager.yaml phase2/
mv manifests/alertmanager-serviceMonitor.yaml phase2/
mv manifests/kube-state-metrics-serviceMonitor.yaml phase2/
mv manifests/node-exporter-serviceMonitor.yaml phase2/
mv manifests/prometheus-prometheus.yaml phase2/
mv manifests/prometheus-rules.yaml phase2/
mv manifests/prometheus-serviceMonitor.yaml phase2/
mv manifests/prometheus-serviceMonitorApiserver.yaml phase2/
mv manifests/prometheus-serviceMonitorCoreDNS.yaml phase2/
mv manifests/prometheus-serviceMonitorKubeControllerManager.yaml phase2/
mv manifests/prometheus-serviceMonitorKubeScheduler.yaml phase2/
mv manifests/prometheus-serviceMonitorKubelet.yaml phase2/
mv manifests phase1
mkdir manifests
mv phase1 manifests
mv phase2 manifests
cd ../../../

# Generate the offline packages
rm -f ./v$PrometheusOperatorVersion.tar.gz
rm -f ../../offline-files/sourcecode/offline-prometheus-operator-$PrometheusOperatorVersion.tar.gz
tar zcf ../../offline-files/sourcecode/offline-prometheus-operator-$PrometheusOperatorVersion.tar.gz prometheus-operator-$PrometheusOperatorVersion

rm -rf prometheus-operator-$PrometheusOperatorVersion
