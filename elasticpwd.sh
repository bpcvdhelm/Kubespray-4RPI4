echo $(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
