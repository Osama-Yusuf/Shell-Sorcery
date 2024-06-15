# AI Assistant Script

## Prerequisites
- Install [Ollama](https://ollama.com/)
- Install at least one [model](https://ollama.com/library) like llama3
- Install [Fabric](https://github.com/danielmiessler/fabric?tab=readme-ov-file#quickstart)
- Have a [YouTube API](https://console.cloud.google.com/marketplace/product/google/youtube.googleapis.com) key ready
- Execute `fabric setup`

## Usage
To use the script, run it with the following arguments:
- `-yt <youtube url>`: Specify the YouTube URL
- `-p <pattern>`: Specify the pattern (wisdom or tutorial)
- `[-llm <llm>]`: Optional - Specify the LLM (default: llama3)