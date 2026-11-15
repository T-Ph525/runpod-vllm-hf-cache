# syntax=docker/dockerfile:1.7
ARG WORKER_IMAGE=runpod/worker-v1-vllm:latest
FROM ${WORKER_IMAGE}

ARG MODEL_NAME
ARG BASE_PATH=/models
ARG MODEL_REVISION=main

ENV MODEL_NAME=${MODEL_NAME} \
    BASE_PATH=${BASE_PATH} \
    HF_HOME=${BASE_PATH}/huggingface \
    HF_HUB_CACHE=${BASE_PATH}/huggingface/hub \
    HF_HUB_OFFLINE=1

RUN --mount=type=secret,id=HF_TOKEN,required=false \
    set -eu; \
    test -n "$MODEL_NAME"; \
    mkdir -p "$HF_HUB_CACHE"; \
    HF_HUB_OFFLINE=0 python3 -c 'import os; from pathlib import Path; from huggingface_hub import snapshot_download; f=Path("/run/secrets/HF_TOKEN"); token=f.read_text().strip() if f.exists() else None; snapshot_download(repo_id=os.environ["MODEL_NAME"], revision=os.environ["MODEL_REVISION"], cache_dir=os.environ["HF_HUB_CACHE"], token=token)'
