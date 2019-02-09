#!/bin/bash
set -e

PrometheusOperatorVersion=0.28.0

for file in $(cat images-list.txt); do docker pull $file; done

echo 'Images pulled.'

docker save $(cat images-list.txt) -o ../offline-files/images/prometheus-operator-images-v$PrometheusOperatorVersion.tar

echo 'Images saved.'

rm -f ../deploy/scripts/images-list.txt
cp images-list.txt ../deploy/scripts/
