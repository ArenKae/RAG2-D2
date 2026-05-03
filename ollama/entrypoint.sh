#!/bin/sh
set -e

MODEL="${OLLAMA_MODEL:-llama3.2:1b}"

ollama serve &

OLLAMA_PID=$!

echo "Waiting for Ollama server..."
until ollama list >/dev/null 2>&1; do
  sleep 1
done

echo "Ensuring model is available: $MODEL"
ollama pull "$MODEL"

echo "Ollama ready with model: $MODEL"

wait "$OLLAMA_PID"