#!/bin/bash
set -e

function usage_help() {
    echo -e "options:"
    echo -e "  -h Display help"
    echo -e "  -a {image_id}"
    echo -e "  -b {host_ports}"
    echo -e "  -c {model_name}"
    echo -e "  -d {ssl_config_file}"
    echo -e "  -e {attestation_hosts}"
    echo -e "       Format: '{attestation_domain_name}:{ip}'"
    echo -e "  -f {sgx_env}"
    echo -e "       SGX = sgx_env"
}

# Default args
SGX=1
host_ports=""
cur_dir=`pwd -P`
ssl_config_file=""
enable_batching=false
rest_api_num_threads=64
session_parallelism=0
parallel_num_threads=32
file_system_poll_wait_seconds=5
attestation_hosts="localhost:127.0.0.1"
work_base_path=/graphene/Examples/tensorflow-serving-cluster/tensorflow-serving
isgx_driver_path=/graphene/Pal/src/host/Linux-SGX/linux-sgx-driver
http_proxy=""
https_proxy=""
no_proxy=""

# Override args
while getopts "h?r:a:b:c:d:e:f:" OPT; do
    case $OPT in
        h|\?)
            usage_help
            exit 1
            ;;
        a)
            echo -e "Option $OPTIND, image_id = $OPTARG"
            image_id=$OPTARG
            ;;
        b)
            echo -e "Option $OPTIND, host_ports = $OPTARG"
            host_ports=$OPTARG
            ;;
        c)
            echo -e "Option $OPTIND, model_name = $OPTARG"
            model_name=$OPTARG
            ;;
        d)
            echo -e "Option $OPTIND, ssl_config_file = $OPTARG"
            ssl_config_file=$OPTARG
            ;;
        e)
            echo -e "Option $OPTIND, attestation_hosts = $OPTARG"
            attestation_hosts=$OPTARG
            ;;
        f)
            echo -e "Option $OPTIND, SGX = $OPTARG"
            SGX=$OPTARG
            ;;
        :)
            echo -e "Option $OPTARG needs argument"
            usage_help
            exit 1
            ;;
        ?)
            echo -e "Unknown option $OPTARG"
            usage_help
            exit 1
            ;;
    esac
done


docker run \
    -it \
    --device /dev/sgx \
    --privileged=true \
    --add-host=${attestation_hosts} \
    -p ${host_ports}:8500-8501 \
    -v ${cur_dir}/models:${work_base_path}/models \
    -v ${cur_dir}/ssl_configure/${ssl_config_file}:${work_base_path}/${ssl_config_file} \
    -v /var/run/aesmd/aesm:/var/run/aesmd/aesm \
    -e http_proxy=${http_proxy} \
    -e https_proxy=${https_proxy} \
    -e no_proxy=${no_proxy} \
    -e SGX=${SGX} \
    -e ISGX_DRIVER_PATH=${isgx_driver_path} \
    -e WORK_BASE_PATH=${work_base_path} \
    -e model_name=${model_name} \
    -e ssl_config_file=/${ssl_config_file} \
    -e enable_batching=${enable_batching} \
    -e rest_api_num_threads=${rest_api_num_threads} \
    -e session_parallelism=${session_parallelism} \
    -e intra_op_parallelism=${parallel_num_threads} \
    -e inter_op_parallelism=${parallel_num_threads} \
    -e OMP_NUM_THREADS=${parallel_num_threads} \
    -e MKL_NUM_THREADS=${parallel_num_threads} \
    -e file_system_poll_wait_seconds=${file_system_poll_wait_seconds} \
    ${image_id}
