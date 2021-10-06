# Kubespray-4RPI4
## Summary
When you follow the instructions you will end up with a 4 node Kubernetes cluster running on 4 Raspberry Pi's. Within that Kubernetes cluster a 3 node Elasticsearch cluster plus one Kibana will be deployed. All Raspberry Pi's will contain Filebeat and Metricbeat reporting to the Elasticsearch cluster within Kubernetes.
The Kubernetes dashboard will be accessable via port 30001 on each Raspberry Pi. Elasticsearch will be reachable on port 30002 and Kibana on 30003. So you don't have to fidde with kubectl proxy or port-forward.

## Hardware
I've purchased 4 Raspberry Pi4 machines with 8Gb memory plus a TP-LINK LS1005G including cables. The Raspberry Pi's are built together with acryl plates. Power is coming from "old" Rapsberry Pi3 power supplies, so I also purchased USB Micro-B to USB-C adapters.

## Architecture
The cluster is reachable via the wlan0 Wifi connector and the Kubernetes cluster is communicating with each other via eth0 connector. I've chosen the IP addresses 10.0.0.11 to 10.0.0.14 for the Raspberry Pi eth0 addresses.

## Build
The build is run with ansible from your desktop/laptop. The ansible install job running on your desktop/laptop will prepare node1 as the Kubernetes installing node. After that it will run a Kubespray ansible install job on node1. After installing Kubernetes you'll execute ansible scripts for implementing Kubernetes-dashboard, the Elasticsearch cluster and Kibana. Finaly ansible scripts are available for implementing Filebeat and Metricbeat on each Raspberry Pi. All scripts are executed from your desktop/laptop.

## The tasks and scripts
- At first you need to prepare the SD cards for the Pi's. Google for instructrions to install Ubuntu LTS on the raspberry PI's. 
- Then login to each ubuntu with the user ubuntu and password ubuntu. Change the ubuntu password and configure the wlan0 wifi adapter with netplan. You can google howto do that or you can have a peek at the 01-prepare.yml file.
- Write down the IP addresses of all Raspberry Pi's. Use the command ip a.
- Alter the hosts.ini and fill in the wifi IPs of the nodes.
- On your desktop/laptop generate ssh keys with ssh-keygen, when not already done!
- Setup the ssh keys to all Raspberry Pi's with ssh-copy-id ubuntu@(Wifi IP1) up to ssh-copy-id ubuntu@(Wifi IP4).
- sh 01-prepare.sh
  - This will apply maintenance, disable unattended upgrades and enable cgroups memory.
- Login into the first Raspberry Pi node1 and do here the ssh-keygen
- After the keygen setup the ssh to all (also node 1) Raspberry Pi's with ssh-copy-id 10.0.0.11 up to ssh-copy-id 10.0.0.14.
- sh 02-install.sh
  - This will prepare node1 and install kubespray, followed up by an install running on node1. This will take 30-45 minutes. Be patient!
- sh 03-kubernetes-dashboard.sh
  - Install the kubernetes dashboard. I use the official instead of the Kubespray one. Somehow the official worked better for me. Fetch the displayed token at the end of the install. You need it for accessing the dashboard.
- Check the Kubernetes dashboard on https://(IP of any Rpi):30001. When Chrome complains on the certificates just type thisisunsafe. 
- sh 04-elastic.sh
  - This will install the elastic operator responsible for implementing Elasticsearch clusters and Kibana's.
- sh 05-elasticsearch.sh
  - This will install a 3 node Elasticsearch cluster. At the end there will be a file /home/ubuntu/kubespray/_elastic.pwd file on each Raspberry Pi containing the password for the elastic user. Fetch it, you need this for accessing Elasticsearch via Kibana.
- sh 06-kibana.sh
  - Install a Kibana instance.
- Check Kubernetes dashboard if Elasticsearch and Kibana are up and running. After that access Kibana on https://(IP of any Rpi):30003.
- sh 07-metricbeat.sh
  - Install and configure Metricbeat on each Raspberry Pi including loading the index templates and dashboards.
- sh 08-filebeat.sh
  - Install and configure Filebeat on each Raspbery Pi including loading the index template and dasboards.
- Check the incoming data and dashboards within Kibana.
