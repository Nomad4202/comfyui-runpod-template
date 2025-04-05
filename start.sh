#!/bin/sh
set -e

# Use /workspace for Python installs and binaries
export PYTHONUSERBASE=/workspace/.local
export PATH=$PYTHONUSERBASE/bin:$PATH

# ---------------------------------------------
# System Update and Package Installation (Ubuntu 22.04)
# ---------------------------------------------
echo "Installing base system packages..."
apt-get update && apt-get install -y \
    git curl wget zip unzip \
    python3 python3-pip python3-venv \
    tmux nano build-essential \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------
# Upgrade pip and install JupyterLab
# ---------------------------------------------
echo "Upgrading pip and installing JupyterLab..."
pip3 install --upgrade pip --user
pip3 install jupyterlab --user

# ---------------------------------------------
# Install PyTorch + CUDA packages
# ---------------------------------------------
echo "Installing PyTorch and CUDA extensions..."
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 --user
pip3 install triton xformers sageattention --user

# ---------------------------------------------
# ComfyUI setup
# ---------------------------------------------
echo "Cloning ComfyUI..."
cd /workspace
if [ ! -d "ComfyUI" ]; then
    git clone https://github.com/comfyanonymous/ComfyUI.git
fi
cd ComfyUI
pip3 install -r requirements.txt --user

# ---------------------------------------------
# Install ComfyUI Manager
# ---------------------------------------------
echo "Installing ComfyUI Manager extension..."
mkdir -p /workspace/ComfyUI/custom_nodes
cd /workspace/ComfyUI/custom_nodes
if [ ! -d "ComfyUI-Manager" ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
fi

# ---------------------------------------------
# Download Hugging Face Models
# ---------------------------------------------
echo "Downloading models..."
if [ -z "$HF_TOKEN" ]; then
  echo "ERROR: HF_TOKEN not set."
  exit 1
fi

mkdir -p /workspace/ComfyUI/models/clip
mkdir -p /workspace/ComfyUI/models/diffusion_models
mkdir -p /workspace/ComfyUI/models/vae

declare -A MODEL_URLS
MODEL_URLS["/workspace/ComfyUI/models/clip/clip_l.safetensors"]="https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
MODEL_URLS["/workspace/ComfyUI/models/clip/t5xxl_fp16.safetensors"]="https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
MODEL_URLS["/workspace/ComfyUI/models/diffusion_models/flux1-dev.safetensors"]="https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors"
MODEL_URLS["/workspace/ComfyUI/models/diffusion_models/flux1-fill-dev.safetensors"]="https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev/resolve/main/flux1-fill-dev.safetensors"
MODEL_URLS["/workspace/ComfyUI/models/vae/ae.safetensors"]="https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors"

for TARGET_PATH in "${!MODEL_URLS[@]}"; do
    URL="${MODEL_URLS[$TARGET_PATH]}"
    if [ ! -f "$TARGET_PATH" ]; then
        echo "Downloading $(basename $TARGET_PATH)..."
        wget --header="Authorization: Bearer $HF_TOKEN" -O "$TARGET_PATH" "$URL"
    else
        echo "$(basename $TARGET_PATH) already exists."
    fi
done

# ---------------------------------------------
# Create output zip script
# ---------------------------------------------
echo "Creating zip-output.sh..."
cat << 'EOF' > /workspace/ComfyUI/zip-output.sh
#!/bin/sh
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ZIPFILE="/workspace/ComfyUI/output_backup_$TIMESTAMP.zip"
zip -r "$ZIPFILE" /workspace/ComfyUI/output
EOF
chmod +x /workspace/ComfyUI/zip-output.sh

# ---------------------------------------------
# Start ComfyUI and JupyterLab
# ---------------------------------------------
echo "Starting ComfyUI..."
cd /workspace/ComfyUI
nohup python3 main.py --listen 0.0.0.0 --port 8188 > /workspace/comfyui.log 2>&1 &

echo "Starting JupyterLab..."
cd /workspace
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' --NotebookApp.password=''
