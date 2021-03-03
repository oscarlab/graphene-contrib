## Server

1. Download and convert model
    ```
    pip install tensorflow==2.4.0

    ./download_model.sh

    python ./model_graph_to_saved_model.py --import_path ${models_abs_dir}/resnet50-v15-fp32/resnet50-v15-fp32.pb --export_dir ${models_abs_dir}/resnet50-v15-fp32 --model_version 1 --inputs input --outputs predict
    ```

2. Generate SSL/TLS certificate and key
    ```
    service_domain_name=grpc.tf-serving.service.com
    ./generate_ssl_config.sh ${service_domain_name}
    ```

4. Setup and start tensorflow-serving service
    - with docker
        - prepare docker image
            ```
            docker pull tensorflow/serving:2.4.0
            ```
        - start service
            ```
            ./run_tf_serving.sh -a ${image_id} -b 8500-8501 -c resnet50-v15-fp32 -d ssl.cfg
            ```

    - with graphene and docker
        - prepare docker image
            > select and edit tensorflow_model_server.manifest.${type}.template
            ```
            cd docker

            type=nonattestation

            cp tensorflow_model_server.manifest.${type}.template tensorflow_model_server.manifest.template

            ./build_graphene_tf_serving.sh ${tag}

            cd -
            ```
        - start service
            ```
            ./run_graphene_tf_serving.sh -a ${image_id} -b 8500-8501 -c resnet50-v15-fp32 -d ssl.cfg
            ```

    - with graphene, attestation and docker
        - prepare docker image
            > select and edit tensorflow_model_server.manifest.${type}.template
            ```
            cd docker

            type=attestation

            cp tensorflow_model_server.manifest.${type}.template tensorflow_model_server.manifest.template

            ./build_graphene_tf_serving.sh ${tag}

            cd -
            ```
        - encrypt model and ssl.cfg
            ```
            cd <graphene repository>/Examples/ra-tls-secret-prov
            make -C ../../Pal/src/host/Linux-SGX/tools/ra-tls dcap
            make dcap pf_crypt

            mkdir plaintext/
            mkdir -p models/resnet50-v15-fp32/1/

            copy <graphene repository>/Examples/tensorflow-serving-cluster/tensorflow-serving/models/resnet50-v15-fp32/1/saved_model.pb plaintext/
            LD_LIBRARY_PATH=. ./pf_crypt encrypt -w files/wrap-key -i plaintext/saved_model.pb -o  models/resnet50-v15-fp32/1/saved_model.pb

            copy <graphene repository>/Examples/tensorflow-serving-cluster/tensorflow-serving/ssl_configure/ssl.cfg plaintext/
            LD_LIBRARY_PATH=. ./pf_crypt encrypt -w files/wrap-key -i ssl.cfg -o ssl.cfg

            mv <graphene repository>/Examples/ra-tls-secret-prov/models <graphene repository>/Examples/tensorflow-serving-cluster/tensorflow_serving/
            mv <graphene repository>/Examples/ra-tls-secret-prov/ssl.cfg <graphene repository>/Examples/tensorflow-serving-cluster/tensorflow_serving/ssl_configure/
            ```
        - start service
            ```
            cd <graphene repository>/Examples/tensorflow-serving-cluster/tensorflow_serving

            attestation_domain_name=attestation.service.com
            attestation_hosts="${attestation_domain_name}:${ip}"

            ./run_graphene_tf_serving.sh -a ${image_id} -b 8500-8501 -c resnet50-v15-fp32 -d ssl.cfg -e ${attestation_hosts}
            ```

    - with graphene, attestation and Kubernetes
        - prepare docker image
            > see `with graphene, attestation and docker`
        - encrypt model and ssl.cfg
            > see `with graphene, attestation and docker`
        - start service
            > kubernetes/README.md


## Client

1. Add DNS record via hosts
    ```
    echo "${ip} ${service_domain_name}" >> /etc/hosts
    ```

2. Query the model using the predict API
    ```
    cd client

    pip install -r ./requirements.txt

    unset http_proxy && unset https_proxy
    ```

   - with docker
        ```
        echo "${ip} ${service_domain_name}" >> /etc/hosts

        grpc_url=${service_domain_name}:8500

        python ./resnet_client_grpc.py -url ${grpc_url} -crt ../ssl_configure/server.crt -batch 1 -cnum 1 -loop 50
        ```

   - with kubernetes
        ```
        grpc_url=${service_domain_name}:30443

        python ./resnet_client_grpc.py -url ${grpc_url} -crt ../ssl_configure/server.crt -batch 1 -cnum 1 -loop 50
        ```

3. Benchmark
    ```
    ./benchmark.sh python ${grpc_url} ../ssl_configure/server.crt | tee -a benchmark.log

    cat ./benchmark.log | grep 'summary'
    ```
