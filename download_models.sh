#!/bin/bash
# Create directories for models if they don't already exist
mkdir -p /workspace/ComfyUI/models/clip
mkdir -p /workspace/ComfyUI/models/diffusion_models
mkdir -p /workspace/ComfyUI/models/style_models
mkdir -p /workspace/ComfyUI/models/vae
mkdir -p /workspace/ComfyUI/models/text_encoders
mkdir -p /workspace/ComfyUI/models/clip_vision

# Prompt for your Hugging Face token
read -p "Enter your Hugging Face token: " HF_TOKEN

# Function to download a model file using wget with the HF token
download_model() {
    MODEL_URL=$1
    DEST_PATH=$2
    echo "Downloading to ${DEST_PATH} ..."
    wget --header="Authorization: Bearer ${HF_TOKEN}" -O "${DEST_PATH}" "${MODEL_URL}"
}

# Display a menu for model selection (enter numbers separated by spaces)
echo "Select models to download by entering their numbers separated by spaces (e.g., '1 3 5'):"
echo "1) clip_l.safetensors (to ComfyUI/models/clip)"
echo "2) t5xxl_fp16.safetensors (to ComfyUI/models/clip)"
echo "3) flux1-dev.safetensors (to ComfyUI/models/diffusion_models)"
echo "4) flux1-fill-dev.safetensors (to ComfyUI/models/diffusion_models)"
echo "5) flux1-redux-dev.safetensors (to ComfyUI/models/style_models)"
echo "6) ae.safetensors (to ComfyUI/models/vae)"
echo "7) wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors (to ComfyUI/models/diffusion_models)"
echo "8) umt5_xxl_fp8_e4m3fn_scaled.safetensors (to ComfyUI/models/text_encoders)"
echo "9) clip_vision_h.safetensors (to ComfyUI/models/clip_vision)"
echo "10) wan_2.1_vae.safetensors (to ComfyUI/models/vae)"
read -p "Your choices: " CHOICES

for CHOICE in $CHOICES; do
    case $CHOICE in
        1)
            download_model "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" "/workspace/ComfyUI/models/clip/clip_l.safetensors"
            ;;
        2)
            download_model "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" "/workspace/ComfyUI/models/clip/t5xxl_fp16.safetensors"
            ;;
        3)
            download_model "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux1-dev.safetensors"
            ;;
        4)
            download_model "https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev/resolve/main/flux1-fill-dev.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux1-fill-dev.safetensors"
            ;;
        5)
            download_model "https://huggingface.co/black-forest-labs/FLUX.1-Redux-dev/resolve/main/flux1-redux-dev.safetensors" "/workspace/ComfyUI/models/style_models/flux1-redux-dev.safetensors"
            ;;
        6)
            download_model "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors" "/workspace/ComfyUI/models/vae/ae.safetensors"
            ;;
        7)
            download_model "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors" "/workspace/ComfyUI/models/diffusion_models/wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors"
            ;;
        8)
            download_model "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "/workspace/ComfyUI/models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
            ;;
        9)
            download_model "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" "/workspace/ComfyUI/models/clip_vision/clip_vision_h.safetensors"
            ;;
        10)
            download_model "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" "/workspace/ComfyUI/models/vae/wan_2.1_vae.safetensors"
            ;;
        *)
            echo "Invalid choice: $CHOICE"
            ;;
    esac
done

echo "Model download(s) complete!"
