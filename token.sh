KD=$(kubectl get secret | grep dashboard-admin-sa-token | awk '{print $1}')
kubectl get secret $KD -oyaml | grep 'token:' | awk '{print $NF}'
