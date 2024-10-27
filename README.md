# Swollama

<img src="https://github.com/user-attachments/assets/bcad3675-5c0f-47aa-b4d2-ff2ebec54437" alt="swollama-logo-small" width="256" height="256" />

A comprehensive, protocol-oriented Swift client for the Ollama API. This package provides a type-safe way to interact with Ollama's machine learning models, supporting all API endpoints with native Swift concurrency.

## [Documentation](https://marcusziade.github.io/Swollama/documentation/swollama/)

## Features

- ✨ Full Ollama API coverage
- 🔄 Native async/await and AsyncSequence support
- 🛡️ Type-safe API with comprehensive error handling
- 🔒 Thread-safe implementation using Swift actors
- 🔄 Automatic retry logic for failed requests
- 📦 Zero external dependencies

## Requirements

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

For complete documentation, code examples, and best practices, visit our [Documentation](https://marcusziade.github.io/Swollama/documentation/swollama/).

## Contributing

Contributions are welcome!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

If you have any questions or feedback, please open an issue on the GitHub repository.