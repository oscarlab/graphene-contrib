# Flannel
Falnnel is a simple and easy way to configure a layer 3 network fabric designed
for Kubernetes and can be added to any existing Kubernetes cluster though it's
simplest to add flannel before any pods using the pod network have been started.

# Deploy service

```
kubectl apply -f ./deploy.yaml
```
# Delete service

```
kubectl delete -f ./deploy.yaml
```