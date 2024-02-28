#!/usr/bin/env bash

export PYTHONUNBUFFERED=1
export TMPDIR=/workspace/tmp

echo "Template version: ${TEMPLATE_VERSION}"

if [[ -e "/workspace/template_version" ]]; then
    EXISTING_VERSION=$(cat /workspace/template_version)
else
    EXISTING_VERSION="0.0.0"
fi

sync_apps() {
    # Sync venv to workspace to support Network volumes
    echo "Syncing venv to workspace, please wait..."
    rsync --remove-source-files -rlptDu /venv/ /workspace/venv/

    # Sync InstantID to workspace to support Network volumes
    echo "Syncing InstantID to workspace, please wait..."
    rsync --remove-source-files -rlptDu /InstantID/ /workspace/InstantID/

    echo "${TEMPLATE_VERSION}" > /workspace/template_version
}

fix_venvs() {
    # Fix the venv to make it work from /workspace
    echo "Fixing venv..."
    /fix_venv.sh /venv /workspace/venv
}

if [ "$(printf '%s\n' "$EXISTING_VERSION" "$TEMPLATE_VERSION" | sort -V | head -n 1)" = "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" != "$TEMPLATE_VERSION" ]; then
        sync_apps
        fix_venvs

        # Create directories
        mkdir -p /workspace/logs /workspace/tmp
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
else
    echo "Existing version is newer than the template version, not syncing!"
fi

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
    echo "You can launch it manually:"
    echo ""
    echo "   cd /workspace/InstantID"
    echo "   deactivate && source /workspace/venv/bin/activate"
    echo "   python3 gradio_demo/app.py --server_port 3001"
else
    echo "Starting InstantID"
    source /workspace/venv/bin/activate
    cd /workspace/InstantID
    TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
    export LD_PRELOAD="${TCMALLOC}"
    nohup python3 gradio_demo/app.py --server_port 3001 > /workspace/logs/InstantID.log 2>&1 &
    echo "InstantID started"
    echo "Log file: /workspace/logs/InstantID.log"
    deactivate
fi

echo "All services have been started"
