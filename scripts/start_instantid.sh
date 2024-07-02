#!/usr/bin/env bash

echo "Starting InstantID"
source /venv/bin/activate
cd /workspace/InstantID
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"
export PYTHONUNBUFFERED=1
nohup python3 gradio_demo/app.py --server_port 3001 > /workspace/logs/InstantID.log 2>&1 &
echo "InstantID started"
echo "Log file: /workspace/logs/InstantID.log"
deactivate
