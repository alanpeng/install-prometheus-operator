# Install Prometheus Operator

每个k8s节点修改时区
```
timedatectl set-timezone Asia/Shanghai
date -s 正确时间
hwclock -w
```

每个k8s master节点执行：
```
cd deploy/scripts/
./fix-k8s-master-nodes.sh
cd ../../
```

每个k8s worker节点执行：
```
cd deploy/scripts/
./fix-k8s-worker-nodes.sh
cd ../../
```

部署机安装docker，保持网络在线，执行：
```
cd prepare/
./bundle.sh
```
以上命令会下载prometheus-operator的源码包并自动将项目依赖的全部docker镜像下载保存

拷贝部署机整个目录至一个k8s worker节点，修改一下deploy/scripts/generate-offline-package.sh和push-offline-images.sh脚本里的变量：

将MyImageRepositoryIP=192.168.9.20修改成实际的私有镜像仓库地址，并执行：
```
cd deploy/scripts/
./generate-offline-package.sh
./push-offline-images.sh
./deploy.sh
```

补充模块启用：
### etcd
```
cd deploy/addon-exporter/
kubectl -n monitoring apply -f etcd-monitor.yaml 
```

### kube-dns
```
cd deploy/addon-exporter/exporter-kube-dns/
kubectl apply -f kube-dns.yaml 
kubectl -n monitoring apply -f prometheus-k8s-service-monitor-kube-dns.yaml 
```

### kube-controller-manager / kube-scheduler
```
cd deploy/addon-exporter/
kubectl apply -f k8s/
```

通过Grafana UI界面导入以下目录内的etcd、kube-dns的json模板即可使用相应的dashboard了。

deploy/grafana-dashboard
