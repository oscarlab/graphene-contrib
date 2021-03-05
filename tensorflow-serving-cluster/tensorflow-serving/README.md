# TensorFlow Serving
[TensorFlow Serving](https://www.TensorFlow.org/tfx/guide/serving) is a flexible,
high-performance serving system for machine learning models. Here we choose it as
our AI service.

This directory contains:
- `client` directory.
  It contains scripts of client. The user can send the request from the client
  with scrpit `resnet_client_grpc.py`.
- `docker` directory.
  It contains the script `build_graphene_tf_serving_image.sh` to build TensorFlow
  Serving docker image.
- `kubernetes` directory.
  It contains the Yaml configuraiton files in Kubernetes which are used for
  TensorFlow Serving elastic deployment.
- other scripts.
  `download_model.sh` to download the model file.
  `model_graph_to_saved_model` to convert the model file.
  `run_graphene_tf_serving.sh` and `run_tf_serving.sh` to run TensorFlow Serving
  with Graphene and with non-Graphene.
  `generate_ssh_config.sh` to generate SSL/TLS certificate and key between TensorFlow
  Serving and client.

In the tutorial, we descript the usage of these scripts and command, please follow
the tutorial step by step to use this scripts.
