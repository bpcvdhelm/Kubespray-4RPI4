# Kubespray-4RPI4
## Summary
When you follow the instructions you will end up with a 4 node Kubernetes cluster running on 4 Raspberry Pi's. Within that Kubernetes cluster a 3 node Elasticsearch cluster plus one Kibana will be deployed. All Raspberry Pi's will contain Filebeat and Metricbeat reporting to the Elasticsearch cluster within Kubernetes.
The Kubernetes dashboard will be accessable via port 30001 on each Raspberry Pi. Elasticsearch will be reachable on port 30002 and Kibana on 30003. So you don't have to fidde with kubectl proxy or port-forward.

## Hardware
I've purchased 4 Raspberry Pi4 machines with 8Gb memory plus a TP-LINK LS1005G including cables. The Raspberry Pi's are built together with acryl plates. Power is coming from "old" Rapsberry Pi3 power supplies, so I also purchased USB Micro-B to USB-C adapters.

## Architecture
The cluster is reachable via the wlan0 Wifi connector and the Kubernetes cluster is communicating with each other via eth0 connector. I've chosen the IP addresses 10.0.0.11 to 10.0.0.14 for the Raspberry Pi eth0 addresses.

## Build
The build is run with ansible from your desktop/laptop. The ansible install job running on your desktop/laptop will prepare node1 as the Kubernetes installing node. After that it will run a Kubespray ansible install job on node1. There are ansible scripts for implementing Kubernetes-dashboard, the Elasticsearch cluster and Kibana. Finaly ansible scripts are available for implementing Filebeat and Metricbeat on each Raspberry Pi.
