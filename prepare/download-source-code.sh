#!/bin/bash
set -e

PrometheusOperatorVersion=0.27.0

if [ -f ../offline-files/sourcecode/prometheus-operator-v$PrometheusOperatorVersion-origin.tar.gz ];then
  echo "File already exists. No need to download again."
else
  curl -L -o ../offline-files/sourcecode/prometheus-operator-v$PrometheusOperatorVersion-origin.tar.gz https://github.com/coreos/prometheus-operator/archive/v$PrometheusOperatorVersion.tar.gz
  echo 'Download Complete.'
fi
