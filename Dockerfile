# Use the NVIDIA CUDA 12.2 base image with Ubuntu 22.04
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Update package lists and install basic tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    tmux \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Create a working directory
WORKDIR /workspace

# Clone the latest ComfyUI repository (which includes the manager)
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Switch to the ComfyUI directory and install Python dependencies
WORKDIR /workspace/ComfyUI
RUN python3 -m pip install --upgrade pip && \
    pip install -r requirements.txt

# Install Jupyter Lab for notebook access
RUN pip install jupyterlab

# Install required AI libraries:
# - PyTorch (with CUDA support for 12.2)
# - Triton, xformers, and safe attention (all required)
RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu122 && \
    pip install triton xformers safe-attention

# Copy our startup and model download scripts into the container
COPY start.sh /workspace/start.sh
COPY download_models.sh /workspace/download_models.sh

# Ensure the scripts are executable
RUN chmod +x /workspace/start.sh /workspace/download_models.sh

# Expose ports for ComfyUI (8188) and Jupyter Lab (8888)
EXPOSE 8188 8888

# Set the default command to our startup script
CMD ["/workspace/start.sh"]
