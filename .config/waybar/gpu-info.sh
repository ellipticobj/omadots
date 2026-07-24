#!/usr/bin/env bash
util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
if [[ -z "$util" ]]; then
  echo '{"text": "x", "tooltip": "GPU: not detected"}'
  exit 0
fi
temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
mem=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null)
mem_total=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null)
gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits 2>/dev/null)
echo "{\"text\": \"${util}%\", \"tooltip\": \"GPU: ${gpu_name}\nUsage: ${util}%\nTemperature: ${temp}°C\nMemory: ${mem}MiB / ${mem_total}MiB\"}"
