## Server 

1. Add DNS record
    - For ingress
        ```
        echo "${host_ip} grpc.tf-serving.service.com" >> /etc/hosts
        ```

    - For attestation
        ```
        kubectl edit configmap -n kube-system coredns

            hosts {
                ${ip} ${attestation_host_name}
                fallthrough
            }

            prometheus :9153
            forward . /etc/resolv.conf {
                ......
        ```

2. Deploy service and configure ingress
    > change model path of volumes.name.model-path.path in deploy.yaml
    ```
    kubectl apply -f ./deploy.yaml
    kubectl apply -f ./ingress.yaml
    ```

3. Elastic deployment
   ```
    kubectl scale -n graphene-tf-serving deployment.apps/graphene-tf-serving-deployment --replicas 2
    ```

4. Check status
    ```
    kubectl logs -n graphene-tf-serving service/graphene-tf-serving-service
    kubectl get -n graphene-tf-serving ingress
    kubectl describe ingress -n graphene-tf-serving graphene-tf-serving-grpc-ingress
    ```

5. Delete Service and clean ingress configuration (Optional)
    ```
    kubectl delete -f ./deploy.yaml
    ```
