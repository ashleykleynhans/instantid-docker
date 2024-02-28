# Stage 1: Base
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 as base

ARG INSTANTID_COMMIT=204db37f6c519d2182a9b5dd7f0c188c92fdcdf7
ARG TORCH_VERSION=2.2.0
ARG XFORMERS_VERSION=0.0.24

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create workspace working directory
WORKDIR /

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        software-properties-common \
        build-essential \
        python3.10-venv \
        python3-pip \
        python3-tk \
        python3-dev \
        nginx \
        bash \
        dos2unix \
        git \
        git-lfs \
        ncdu \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        zip \
        unzip \
        htop \
        screen \
        tmux \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 \
        libtcmalloc-minimal4 \
        apt-transport-https \
        ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Stage 2: Install InstantID and python modules
FROM base as setup

# Create and use the Python venv
RUN python3 -m venv /venv

# Install Torch
RUN source /venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install xformers==${XFORMERS_VERSION} && \
    deactivate

# Clone the git repo of InstantID and set version
WORKDIR /
RUN git clone https://github.com/ashleykleynhans/InstantID.git && \
    cd /InstantID && \
    git checkout ${INSTANTID_COMMIT}

# Install the dependencies for InstantID
WORKDIR /InstantID
RUN source /venv/bin/activate && \
    pip3 install -r gradio_demo/requirements.txt --extra-index-url https://download.pytorch.org/whl/cu121 && \
    deactivate

# Copy the style template and script to download the checkpoints
COPY instantid/* ./

# Download checkpoints
RUN source /venv/bin/activate && \
    python3 download_checkpoints.py && \
    deactivate

# Download antelopev2 models from Huggingface
RUN git lfs install && \
    git clone https://huggingface.co/ashleykleynhans/FaceAnalysis models

# Install Jupyter, gdown and OhMyRunPod
RUN pip3 install -U --no-cache-dir jupyterlab \
        jupyterlab_widgets \
        ipykernel \
        ipywidgets \
        gdown \
        OhMyRunPod

# Install RunPod File Uploader
RUN curl -sSL https://github.com/kodxana/RunPod-FilleUploader/raw/main/scripts/installer.sh -o installer.sh && \
    chmod +x installer.sh && \
    ./installer.sh

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install runpodctl
RUN wget https://github.com/runpod/runpodctl/releases/download/v1.13.0/runpodctl-linux-amd64 -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# Install croc
RUN curl https://getcroc.schollz.com | bash

# Install speedtest CLI
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt install speedtest

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/502.html /usr/share/nginx/html/502.html

# Set template version
ENV TEMPLATE_VERSION=2.0.0

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
