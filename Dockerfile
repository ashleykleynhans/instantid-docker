ARG BASE_IMAGE
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create and use the Python venv
WORKDIR /
RUN python3 -m venv --system-site-packages /venv

# Install Torch
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION
RUN source /venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL} && \
    deactivate

# Clone the git repo of InstantID and set version
ARG INSTANTID_COMMIT
RUN git clone https://github.com/ashleykleynhans/InstantID.git && \
    cd /InstantID && \
    git checkout ${INSTANTID_COMMIT}

# Install the dependencies for InstantID
WORKDIR /InstantID
RUN source /venv/bin/activate && \
    pip3 install -r gradio_demo/requirements.txt --extra-index-url https://download.pytorch.org/whl/cu118 && \
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

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
