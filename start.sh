#!/bin/bash
# git clone https://github.com/cocktailpeanut/fluxgym.git /app/fluxgym;
# git clone -b sd3 https://github.com/kohya-ss/sd-scripts /app/fluxgym/sd-scripts;

cd /app/fluxgym/sd-scripts &&
pip install -r requirements.txt &&
echo "fluxgym requirements installed successfully.";

cd /app/fluxgym &&
pip install -r requirements.txt &&
echo "fluxgym requirements installed successfully.";

pip install --pre torch==2.4 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 &&
echo "PyTorch installed successfully.";

pip install jupyter &&
echo "Jupyter installed successfully.";

echo "Symlink models directory..."
rm -rf /app/fluxgym/models
mkdir -p /models
mkdir -p /models/clip
mkdir -p /models/vae
mkdir -p /models/unet

ln -s /models /app/fluxgym/models

chown -R appuser:appuser /models

echo "Downloading models..." &&
# Define file paths and URLs
declare -A files=(
  ["/app/fluxgym/models/unet/flux1-dev.sft"]="https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/flux1-dev.sft?download=true"
  ["/app/fluxgym/models/clip/clip_l.safetensors"]="https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true"
  ["/app/fluxgym/models/clip/t5xxl_fp16.safetensors"]="https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true"
  ["/app/fluxgym/models/vae/ae.sft"]="https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/ae.sft?download=true"
)

# Loop through each file and download if it doesn't exist
for file_path in "${!files[@]}"; do
  if [[ -f "$file_path" ]]; then
    echo "File already exists: $file_path"
  else
    echo "Downloading: $file_path"
    wget -O "$file_path" "${files[$file_path]}"
  fi
done

echo "Models downloaded successfully.";

export GRADIO_SERVER_NAME="0.0.0.0"

python3 /app/fluxgym/app.py
