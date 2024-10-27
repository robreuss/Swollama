# Swollama

<img src="https://github.com/user-attachments/assets/bcad3675-5c0f-47aa-b4d2-ff2ebec54437" alt="swollama-logo-small" width="256" height="256" />

![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue)](https://marcusziade.github.io/Swollama/documentation/swollama/)
![License](https://img.shields.io/badge/License-MIT-green)

A comprehensive, protocol-oriented Swift client for the Ollama API. This package provides a type-safe way to interact with Ollama's machine learning models, supporting all API endpoints with native Swift concurrency.

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

## Requirements
- macOS 14+
- Xcode 15.0+
- Swift 5.9+
- [Ollama](https://ollama.ai) installed and running locally or on a remote server

## Installation

### Swift Package Manager
Add Swollama to your Swift package dependencies in `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/marcusziade/Swollama.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File > Add Package Dependencies
2. Enter the repository URL: `https://github.com/marcusziade/Swollama.git`

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
guard let model = OllamaModelName.parse("llama3.2") else {
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
swollama chat llama3.2

# Generate text with specific parameters
swollama generate codellama

# Pull a new model
swollama pull llama3.2

# Show model information
swollama show llama3.2

# Copy a model
swollama copy llama3.2 my-llama3.2

# Delete a model
swollama delete my-llama3.2

# List running models
swollama ps
```

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
    model: .init("llama3.2")!
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
    model: .init("llama3.2")!
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
