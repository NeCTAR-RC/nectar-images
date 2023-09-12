# See https://docs.nvidia.com/cuda/cuda-installation-guide-linux/#environment-setup
# NOTE: /usr/local/cuda is provided by update-alternatives
export CUDA_HOME=/usr/local/cuda
export PATH=${CUDA_HOME}/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
