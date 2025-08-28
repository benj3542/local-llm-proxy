# Local LLM (Ollama + LiteLLM Proxy)

Runs a lightweight LLM **locally** via **Ollama**, fronted by a **LiteLLM** proxy that exposes an **OpenAI-compatible** API at:

[URL_local_host](http://localhost:4000/v1)

Defaults to the small, fast model **`phi3:mini`** so you can quickly test your evaluation pipelines.

- Ollama (model runtime) listens on: `http://localhost:11434`
- LiteLLM Proxy (OpenAI-compatible) listens on: `http://localhost:4000/v1`

## Quick start

```bash
# 1) clone this repo, then:
cp .env.example .env   # optional: tweak MODEL_NAME or ports

# 2) start services (Ollama + Proxy) and auto-pull the model
docker compose up -d

# 3) check logs
docker compose logs -f

# 4) sanity check (proxy)
curl -sS http://localhost:4000/v1/models | jq .

# 5) basic chat test through the OpenAI-compatible proxy
curl -sS http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "ollama/phi3:mini",
    "messages": [{"role":"user","content":"Say hi in Danish"}],
    "temperature": 0.2
  }' | jq .
```
If you don't have `jq`, omit it (it just pretty-prints JSON).

## Use with your EuroEval runner

Point your runner to the proxy:
- **API base:** `http://localhost:4000/v1`
- **API key:** (none required-leave blank)
- **Model id:** `ollama/phi3:mini` (or whichever you configured)

Example (non-interactive):
```bash
docker run --rm \
  -v "$(pwd)/results:/workspace/results" \
  ghcr.io/<owner>/<euroeval-repo>:<tag> \
  euroeval-runner \
    --api-base "http://localhost:4000/v1" \
    --model    "ollama/phi3:mini" \
    --language "da" \
    --task     "sentiment-classification" \
    --batch-size 1
```
On Apple Silicon, if your EuroEval image is amd64-only, add `platform=linux/amd64` to the `docker run` above. 

## Change the model 

Edit `.env`or set `MODEL_NAME` when starting: 

```bash
# Use Llama 3 (8B) instead of Phi-3 Mini:
MODEL_NAME="llama3:8b" docker compose up -d
```

## Makefile shortcuts 

```bash
make up         # start services + pull model
make logs       # follow logs
make test       # test a simple chat via the proxy
make models     # list models from proxy
make down       # stop
make clean      # stop + remove volumes (deletes local model cache)
```

