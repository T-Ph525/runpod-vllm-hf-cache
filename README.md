# RunPod vLLM — baked-in Hugging Face cache

Build on the latest published `runpod/worker-v1-vllm:latest` Docker image and download a Hugging Face model into its image layers during `docker build`.

## Build

```bash
docker buildx build --pull --platform linux/amd64 \
  --build-arg MODEL_NAME=Qwen/Qwen3-8B \
  --build-arg BASE_PATH=/models \
  -t my-runpod-vllm:latest --load .
```

To build gated/private models, authenticate with a BuildKit secret rather than a Docker build argument:

```bash
export HF_TOKEN=hf_your_token
docker buildx build --pull --platform linux/amd64 \
  --secret id=HF_TOKEN,env=HF_TOKEN \
  --build-arg MODEL_NAME=your-org/private-model \
  --build-arg BASE_PATH=/models \
  -t my-runpod-vllm:latest --load .
```

## Configuration

- `MODEL_NAME`: Hugging Face repository ID; required at build time.
- `BASE_PATH`: Parent directory for Hugging Face cache, defaults to `/models`.
- `MODEL_REVISION`: Hugging Face revision, defaults to `main`.
- `WORKER_IMAGE`: Optional upstream image reference, defaults to `runpod/worker-v1-vllm:latest`.

The Dockerfile preserves the upstream RunPod worker ENTRYPOINT and CMD. Model files land in `$BASE_PATH/huggingface/hub`, and `HF_HUB_OFFLINE=1` prevents runtime Hugging Face Hub network lookups.

**Note:** The image tag `latest` requires the upstream image publisher to maintain that tag. You can set `--build-arg WORKER_IMAGE=runpod/worker-v1-vllm:<published-tag>` to pin or select a different tag. The Hugging Face model is cached in the image; whether the worker loads it directly from that cache depends on its runtime configuration. Avoid mounting an empty network volume over `BASE_PATH` because it will hide the baked-in cache.

For large models, the final image can be very large and uploading/exporting image layers may be slow. No Docker build is automatically executed by this repository.
