# Kubespray-4RPI4

## Summary
When you follow the instructions you will end up with a 4 node Kubernetes cluster running on 4 Raspberry Pi's. Within that Kubernetes cluster a 3 node Elasticsearch cluster plus one Kibana will be deployed. All Raspberry Pi's will contain Filebeat and Metricbeat reporting to the Elasticsearch cluster within Kubernetes.
The Kubernetes dashboard will be accessable via port 30001 on each Raspberry Pi. Elasticsearch will be reachable on port 30002 and Kibana on 30003. So you don't have to fiddle with kubectl proxy or port-forward.

## Hardware
I've purchased 4 Raspberry Pi4 machines with 8Gb memory plus a TP-LINK LS1005G including cables. When I look at the Metricbeat dashboards, also the 4Gb memory Raspberry Pi's should work. Power is coming from "old" Rapsberry Pi3 power supplies, so I also purchased USB Micro-B to USB-C adapters.

<img src="https://github.com/bpcvdhelm/Kubespray-4RPI4/blob/main/RpiCluster.jpeg" width="400">

## Architecture
My cluster is reachable via the wlan0 Wifi connector and the Kubernetes cluster is communicating with each other via the eth0 connector. I've chosen the IP addresses 10.0.0.11 to 10.0.0.14 for the Raspberry Pi eth0 addresses.

## Build
The build is run with ansible from your desktop/laptop, so ansible needs to be installed. The scripts will first prepare the Raspberry Pi's and then install the Kubernetes cluster. This install will be run from node1, so you won't have to install all kinds of requirements on your laptop. When the cluster is up and running you will install Kubernetes-dashboard, Elastic operator, the 3 node Elasticsearch cluster, one Kibana instance within Kubernetes. Finally file- and metricbeat will be installed on all Raspberry Pi's reporting to the Elasticsearch cluster within Kubernetes.

## The tasks and scripts
- First you need to prepare the SD cards for the Pi's. Google for instructrions howto install Ubuntu LTS on the raspberry PI's. 
- Login to each ubuntu with the user ubuntu and password ubuntu, change the ubuntu password and configure the wlan0 wifi adapter with netplan. Google howto do that or have a peek at the 01-prepare.yml file for inspiration.
- Write down the IP addresses of all Raspberry Pi's. Use the command ip a.
- After Wifi becoming alive, let Ubuntu do the unattended upgrades. This takes 15-20 minutes. Just look with top at the last node and wait until it becomes quiet.
- Edit the hosts.ini and fill in the wifi IPs of the nodes.
- Generate ssh keys with ssh-keygen on your desktop/laptop, when not already done!
- Setup the ssh keys to all Raspberry Pi's with ssh-copy-id ubuntu@(Wifi IP address node1) up to ssh-copy-id ubuntu@(Wifi IP address node4).
- sh 01-prepare.sh
  - Edit wifi.yml for the access to your wifi network.
  - This will apply maintenance, remove snapd and unattended upgrades, install avahi, configure the network and enable cgroups memory.
  - Avahi is enabled, you should be able to login with ssh ubuntu@node1.local.
- Login into the first Raspberry Pi node1 and do here the ssh keygen with command ssh-keygen. Just go with the defaults.
- Setup the ssh to all (also node1) Raspberry Pi's with ssh-copy-id 10.0.0.11 up to ssh-copy-id 10.0.0.14.
- sh 02-install.sh
  - This will prepare node1 and install kubespray, followed up by an install running on node1. This will take 30-45 minutes. Be patient!
  - You can watch the log by loging into node1, go to the kubespray directory and tail -f the log named _install-YYMMDD-HH:MM.log that's there being created,
- sh 03-kubernetes-dashboard.sh
  - Install the kubernetes dashboard. I use the official instead of the Kubespray one, domehow the official works better for me.
  - Fetch the displayed token at the end of the install and save it. You need it for accessing the dashboard.
- Check the Kubernetes dashboard on https://node1.local:30001. When Chrome complains on the certificates just type thisisunsafe. 
  - Use the token to login.
  - Select all namespaces to see some action.
- sh 04-elastic.sh
  - This will install the elastic operator responsible for implementing Elasticsearch clusters and Kibana's.
- sh 05-elasticsearch.sh
  - This will install a 3 node Elasticsearch cluster. 
  - At the end there will be a file /home/ubuntu/kubespray/_elastic.pwd file on each Raspberry Pi containing the password for the elastic user. Fetch it, you need this for accessing Elasticsearch via Kibana.
- sh 06-kibana.sh
  - Install a Kibana instance.
- Check Kubernetes dashboard if Elasticsearch and Kibana are up and running. After that access Kibana on https://node1.local:30003.
- sh 07-metricbeat.sh
  - Install and configure Metricbeat on each Raspberry Pi including loading the index templates and dashboards.
- sh 08-filebeat.sh
  - Install and configure Filebeat on each Raspbery Pi including loading the index template and dasboards.
- sh 09-metrics-server.sh
  - Install the metrics-server. See the 09-metrics-server.yml what needs to be changed on the original for Raspberry Pi's.
- Check the incoming data for file- and metricbeat and check the nice metricbeat dashboards within Kibana.

<img src="https://github.com/bpcvdhelm/Kubespray-4RPI4/blob/main/Metricbeat.png" width="1000">

## Enable kubectl command for your desktop/laptop
Execute the commands:
- mkdir -p ~/.kube
- scp ubuntu@node1.local:/home/ubuntu/.kube/config ~/.kube/config
- edit the ~/.kube/config file and change 127.0.0.1 to the Wifi IP address of node1.
- test with the command kubectl get nodes -owide

## Todo
- Implement ssh key gen and copy wihtin ansible
