# Swollama

<img src="https://github.com/user-attachments/assets/bcad3675-5c0f-47aa-b4d2-ff2ebec54437" alt="swollama-logo-small" width="256" height="256" />

![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue)](https://marcusziade.github.io/Swollama/documentation/swollama/)
![License](https://img.shields.io/badge/License-MIT-green)

A comprehensive, protocol-oriented Swift client for the Ollama API. This package provides a type-safe way to interact with Ollama's machine learning models, supporting all API endpoints with native Swift concurrency. Available for both macOS and Linux through native installation or Docker.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [CLI Usage](#cli-usage)
- [Environment Variables](#environment-variables)
- [Documentation](#documentation)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features
- ✨ Full Ollama API coverage
- 🔄 Native async/await and AsyncSequence support
- 🛡️ Type-safe API with comprehensive error handling
- 🔒 Thread-safe implementation using Swift actors
- 🔄 Automatic retry logic for failed requests
- 📦 Zero external dependencies
- 🐳 Cross-platform support via Docker (macOS, Linux)
- 🖥️ Native support for macOS and Linux

## Requirements

### For Native Installation
- macOS: Xcode 15.0+ (for development)
- Linux: Swift 5.9+
- [Ollama](https://ollama.ai) installed and running locally or on a remote server

### For Docker Installation (Cross-Platform)
- Docker
- No Swift installation required
- Works on any platform that supports Docker (macOS, Linux, Windows via WSL)

## Installation

### Swift Package Manager (Native Installation)
Add Swollama to your Swift package dependencies in `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/marcusziade/Swollama.git", from: "1.0.0")
]
```

Or add it through Xcode (macOS only):
1. File > Add Package Dependencies
2. Enter the repository URL: `https://github.com/marcusziade/Swollama.git`

### Docker Installation (Cross-Platform)
Use Docker to run Swollama on any platform without installing Swift or other dependencies:

1. Clone the repository:
```bash
git clone https://github.com/marcusziade/Swollama.git
cd Swollama
```

2. Build the Docker image:
```bash
docker build -t swollama .
```

3. Run the CLI commands using Docker:
```bash
# List available models
docker run swollama list

# Pull a model
docker run swollama pull llama2

# Start a chat session
docker run -it swollama chat llama2

# Generate text
docker run -it swollama generate llama2

# Show model information
docker run swollama show llama2
```

#### Docker Compose (Optional)
Run both Ollama and Swollama together with Docker Compose:

```yaml
version: '3.8'
services:
  ollama:
    image: ollama/ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama

  swollama:
    build: .
    depends_on:
      - ollama
    environment:
      - OLLAMA_HOST=http://ollama:11434

volumes:
  ollama_data:
```

Run both services:
```bash
docker-compose up
```

## Quick Start
```swift
import Swollama

// Initialize client
let client = OllamaClient()

// List available models
let models = try await client.listModels()
for model in models {
    print(model.name)
}

// Start a chat
guard let model = OllamaModelName.parse("llama2") else {
    throw CLIError.invalidArgument("Invalid model name format")
}
let responses = try await client.chat(
    messages: [
        ChatMessage(role: .user, content: "Hello! How are you?")
    ],
    model: model
)
for try await response in responses {
    print(response.message.content, terminator: "")
}
```

## CLI Usage
```bash
# List all available models
swollama list

# Stream a chat response
swollama chat llama2

# Generate text with specific parameters
swollama generate codellama

# Pull a new model
swollama pull llama2

# Show model information
swollama show llama2

# Copy a model
swollama copy llama2 my-llama2

# Delete a model
swollama delete my-llama2

# List running models
swollama ps
```

## Environment Variables
- `OLLAMA_HOST`: Ollama API endpoint (default: http://localhost:11434)
- `OLLAMA_TIMEOUT`: Request timeout in seconds (default: 30)

## Documentation
For complete API documentation, usage examples, and best practices, visit our [Documentation](https://marcusziade.github.io/Swollama/documentation/swollama/).

## Examples

### Chat Completion
```swift
let client = OllamaClient()
let responses = try await client.chat(
    messages: [
        .init(role: .system, content: "You are a helpful assistant"),
        .init(role: .user, content: "Write a haiku about Swift")
    ],
    model: .init("llama2")!
)

for try await response in responses {
    print(response.message.content)
}
```

### Generate Text
```swift
let client = OllamaClient()
let responses = try await client.generate(
    prompt: "Explain quantum computing",
    model: .init("llama2")!
)

for try await response in responses {
    print(response.content)
}
```

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License.

## Contact
If you have any questions, feedback, or run into issues, please [open an issue](https://github.com/marcusziade/Swollama/issues) on the GitHub repository.