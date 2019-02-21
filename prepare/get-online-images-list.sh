#!/bin/bash
set -e

PrometheusOperatorVersion=0.29.0

rm -f images-list.txt
rm -rf prometheus-operator-$PrometheusOperatorVersion
tar zxf ../offline-files/sourcecode/prometheus-operator-v$PrometheusOperatorVersion-origin.tar.gz

# Fix issue 2291 of prometheus operator
sed -i "s/0.28.0/$PrometheusOperatorVersion/g" prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/0prometheus-operator-deployment.yaml

for file in $(grep -lr "quay.io/coreos" prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/); do cat $file |grep "quay.io/coreos" ; done > image-lists-temp.txt
for file in $(grep -lr "grafana/grafana" prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/); do cat $file |grep "grafana/grafana" ; done >> image-lists-temp.txt
for file in $(grep -lr "quay.io/prometheus" prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/); do cat $file |grep "quay.io/prometheus" ; done >> image-lists-temp.txt
for file in $(grep -lr "gcr.io/" prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/); do cat $file |grep "gcr.io/" ; done >> image-lists-temp.txt

prometheus_base_image=`cat prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/prometheus-prometheus.yaml |grep "baseImage: " |awk '{print $2}'`
prometheus_image_tag=`cat prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/prometheus-prometheus.yaml |grep "version: " |awk '{print $2}'`

alertmanager_base_image=`cat prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/alertmanager-alertmanager.yaml |grep "baseImage: " |awk '{print $2}'`
alertmanager_image_tag=`cat prometheus-operator-$PrometheusOperatorVersion/contrib/kube-prometheus/manifests/alertmanager-alertmanager.yaml |grep "version: " |awk '{print $2}'`

echo $prometheus_base_image:$prometheus_image_tag >> image-lists-temp.txt
echo $alertmanager_base_image:$alertmanager_image_tag >> image-lists-temp.txt

rm -rf prometheus-operator-$PrometheusOperatorVersion

sed "s/- --config-reloader-image=//g" image-lists-temp.txt > 1.txt
sed "s/- --prometheus-config-reloader=//g" 1.txt > 2.txt
sed "s/image: //g" 2.txt > 3.txt
sed "s/repository: //g" 3.txt > 4.txt
sed "s/baseImage: //g" 4.txt > 5.txt
sed "s/- grafana/grafana/g" 5.txt > 6.txt
cat 6.txt |grep ":" > 7.txt
sed -i "s/[[:space:]]//g" 7.txt
rm -f image-lists-temp.txt 1.txt 2.txt 3.txt 4.txt 5.txt 6.txt
mv 7.txt images-list.txt
