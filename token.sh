KD=$(kubectl get secret | grep dashboard-admin-sa-token | awk '{print $1}')
kubectl get secret $KD -o go-template='{{.data.token | base64decode}}'
echo
