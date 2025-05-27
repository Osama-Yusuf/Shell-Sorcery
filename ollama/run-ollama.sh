#!/usr/bin/env bash

# heavy and accurate models: 
# 1- deepseek-coder-v2 (Matches GPT4-Turbo's performance in code-related tasks) (16b) (8.9GB)
# 2- llama3.1 (made by meta) (8b params) (4.7GB) || llama3.1 (8b params q-8) (8.5GB)
# 3- gemma2 (made by google) (9b params) (5.4GB)
# 4- mistral-nemo (built in collaboration with NVIDIA) (12b params) (7.1GB)

# light models (can work anywhere):
ollama serve &
ollama list
ollama pull nomic-embed-text

ollama serve &
ollama list
ollama pull qwen:0.5b-chat
