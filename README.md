# Kubespray-4RPI4

## Summary
When you follow the instructions you will end up with a 4 node Kubernetes cluster running on 4 Raspberry Pi's. Within that Kubernetes cluster ECK will be deployed. ECK will hold a 3 node Elasticsearch cluster plus Kibana, File- and Metricbeat. So within Kibana you can see all performance of Kubernetes itself and the underlaying Raspberry Pi's.
The Kubernetes dashboard will be accessable via https://node1.local:30001. You can fetch the token with command token.sh. Elasticsearch will be reachable via https://node1:30002 and Kibana can be reached via https://node1.local:30003. Use the user elastic to authenticate to Elastic. You can fetch the password with command elasticpwd.sh. You won't have to fiddle with kubectl proxy or port-forward.

## Hardware
I've purchased 4 Raspberry Pi4 machines with 8Gb memory plus a TP-LINK LS1005G including cables. When I look at the Metricbeat dashboards, also the 4Gb memory Raspberry Pi's should work. Power is coming from "old" Rapsberry Pi3 power supplies, so I also purchased USB Micro-B to USB-C adapters.

<img src="https://github.com/bpcvdhelm/Kubespray-4RPI4/blob/main/RpiCluster.jpeg" width="400">

## Architecture
My cluster is reachable via the wlan0 Wifi connector and the Kubernetes cluster is communicating with each other via the eth0 connector. I've chosen the IP addresses 10.0.0.11 to 10.0.0.14 for the Raspberry Pi eth0 addresses.

## Build
The build is run with ansible from your desktop/laptop, so ansible needs to be installed. The scripts will first prepare the Raspberry Pi's and then install the Kubernetes cluster. This install will be run from node1, so you won't have to install all kinds of requirements on your laptop. When the cluster is up and running you will install Kubernetes-dashboard, Elastic operator, the 3 node Elasticsearch cluster, one Kibana instance within Kubernetes. Finally file- and metricbeat will be installed on all Raspberry Pi's reporting to the Elasticsearch cluster within Kubernetes.

## Prepare the Raspberry Pi's
- Flash your SD cards and start up the Raspberry Pi's. 
  - Here is the official documentation: https://ubuntu.com/tutorials/how-to-install-ubuntu-desktop-on-raspberry-pi-4#1-overview.
- Login to each ubuntu with user ubuntu and password ubuntu. Now you need to connect the Raspberry Pi's to Wifi.
  - Here is a nice guide to do this: https://linuxconfig.org/ubuntu-20-04-connect-to-wifi-from-command-line.
  - You can also have a look at 01-prepare.yml, but this is in Ansible language.
  - Write down the IP addresses of all Raspberry Pi's and decide who becomes node1, node2, node3 and node4.
- Let Ubuntu do the unattended upgrades. This takes 15-20 minutes. Just look with top at the last node and wait until it becomes quiet.
- Be sure you're in the Kubespray-4RPI4 directory.
  - Edit the hosts.ini and fill in the wifi IPs of the nodes.
  - Edit wifi.yml for the access to your wifi network.
- Generate ssh keys with ssh-keygen on your desktop/laptop, when not already done!
- Setup the ssh keys to all Raspberry Pi's with ssh-copy-id ubuntu@(Wifi IP address node1) up to ssh-copy-id ubuntu@(Wifi IP address node4).

## Install Kubernetes
Be sure you have the latest ansible version installed!
- sh 01-prepare.sh
  - This will apply maintenance, remove snapd and unattended upgrades, install avahi, configure the network and enable cgroups memory.
  - Avahi is enabled, you should be able to login with ssh ubuntu@node1.local.
- Login into the first Raspberry Pi node1 and do here the ssh-keygen, just go with the defaults.
- Setup the ssh keys to all (also node1) Raspberry Pi's with ssh-copy-id 10.0.0.11 up to ssh-copy-id 10.0.0.14. Just reply yes and the password.
- sh 02-install.sh
  - This will prepare node1 and install kubespray, followed up by an install running on node1. This will take 30-45 minutes. Be patient!
  - On another terminal login into node1, go to the kubespray directory and tail -f the log named _install-YYMMDD-HH:MM.log.
- sh 03-kubernetes-dashboard.sh
  - Install the kubernetes dashboard. I use the official instead of the Kubespray one, somehow the official works better for me.
  - Fetch the displayed token at the end of the install and save it. You need it for accessing the dashboard.
- Check the Kubernetes dashboard on https://node1.local:30001. When Chrome complains on the certificates just type thisisunsafe. 
  - Use the token to login.
  - Select all namespaces to see some action.
- sh 04-metrics-server.sh
  - Install the metrics-server. I've added and marked 2 changes in the components.yml for Rapsberry Pi.
- sh 05-kube-state-metrics.sh
  - Install the kube-state-metrics that will provide statistics to kubernetes metricbeat.

## Install ECK, Elasticsearch, Kibana, File- and Metricbeat, all on Kubernetes
- sh 06-elastic.sh
  - This will install the elastic operator responsible for implementing Elasticsearch clusters and Kibana's.
- sh 07-elasticsearch.sh
  - This will install a single node Elasticsearch cluster.
  - At the end there will be a file /home/ubuntu/kubespray/_elastic.pwd on each Raspberry Pi containing the elasti password for the elastic user.
  - Fetch this password, you need it to get into Kibana.
  - Later on you can enlarge the number of nodes.
- sh 08-kibana.sh
  - Install a Kibana instance.
- Check Kubernetes dashboard if Elasticsearch and Kibana are up and running. 
  - After that access Kibana on https://node1.local:30003.
  - Use the user elastic with the fetched password.
- sh 09-metricbeat.sh
  - Install and configure Metricbeat on each Raspberry Pi including loading the index templates and dashboards.
- sh 10-filebeat.sh
  - Install and configure Filebeat on each Raspbery Pi including loading the index template and dasboards.
- Check the incoming data for file- and metricbeat and check the nice metricbeat dashboards within Kibana.

## Enable kubectl command for your desktop/laptop
Execute the commands:
- mkdir -p ~/.kube
- scp ubuntu@node1.local:/home/ubuntu/.kube/config ~/.kube/config
- edit the ~/.kube/config file and change 127.0.0.1 to the Wifi IP address of node1.
- test with the command kubectl get nodes -owide

## Handy commands
- elasticpwd.sh
  - Print the elastic password, you'll need it to login to Kibana with the elastic user.
- restart.sh
  - Restart the Pi's.
- shutdown.sh
    - Shutdown the Pi's. You'll still need to unplug them after that ;-).
- token.sh
  - Print the kubernetes-dashboard token. You'll need this to watch the dashboard.

## Todo
- Implement ssh key gen and copy wihtin ansible

Wow, you made it all to the bottom! If there is any remark or request, just reach out to me!
