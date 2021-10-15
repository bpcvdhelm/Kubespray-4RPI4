echo $(kubectl get secret $(kubectl get secret | grep dashboard-admin-sa-token | awk '{print $1}') -o go-template='{{.data.token | base64decode}}')
