#!/bin/bash
echo "Starting ComfyUI..."
cd /workspace/ComfyUI
nohup python3 main.py > comfyui.log 2>&1 &

echo "Starting Jupyter Lab..."
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' --NotebookApp.password=''
