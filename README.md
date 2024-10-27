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

## Basic Usage

### Initialize the Client

```swift
import Swollama

// Default configuration (connects to localhost:11434)
let client = OllamaClient()

// Custom configuration
let config = OllamaConfiguration(
    timeoutInterval: 60,
    maxRetries: 3,
    retryDelay: 1,
    defaultKeepAlive: 300
)
let customClient = OllamaClient(
    baseURL: URL(string: "http://your-server:11434")!,
    configuration: config
)
```

### Model Management

```swift
// List all available models
let client = OllamaClient()
let models = try await client.listModels()
for model in models.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }) {
    print(model.name)
}

// Pull a new model
guard let modelName = OllamaModelName.parse("llama3.2") else {
    throw CLIError.invalidArgument("Invalid model name format")
}
let progress = try await client.pullModel(
    name: modelName,
    options: PullOptions()
)
for try await update in progress {
    print("Status: \(update.status)")
}

// Show model details
let modelInfo = try await client.showModel(name: modelName)
print("Model format: \(modelInfo.details.format)")
print("Model family: \(modelInfo.details.family)")
print("Parameter size: \(modelInfo.details.parameterSize)")
print("Quantization: \(modelInfo.details.quantizationLevel)")

// Copy a model
guard let sourceModel = OllamaModelName.parse("llama3.2"),
      let destModel = OllamaModelName.parse("llama3.2-custom") else {
    throw CLIError.invalidArgument("Invalid model name format")
}
try await client.copyModel(source: sourceModel, destination: destModel)

// Delete a model
guard let modelToDelete = OllamaModelName.parse("unused-model") else {
    throw CLIError.invalidArgument("Invalid model name format")
}
try await client.deleteModel(name: modelToDelete)

// List running models
let runningModels = try await client.listRunningModels()
for model in runningModels {
    print("Model: \(model.name)")
    print("VRAM Usage: \(model.sizeVRAM) bytes")
    print("Expires: \(model.expiresAt)")
    print("Details:")
    print("  Family: \(model.details.family)")
    print("  Parameter Size: \(model.details.parameterSize)")
    print("  Quantization: \(model.details.quantizationLevel)")
}
```

### Chat Completion

```swift
let client = OllamaClient()

do {
    guard let model = OllamaModelName.parse("llama3.2") else {
        throw CLIError.invalidArgument("Invalid model name format")
    }
    
    // Create messages for the conversation
    var messages: [ChatMessage] = [
        ChatMessage(role: .system, content: "You are a helpful assistant"),
        ChatMessage(role: .user, content: "Hello! Can you help me?")
    ]
    
    // Start a chat stream with the model
    let responses = try await client.chat(
        messages: messages,
        model: model,
        options: .default
    )
    
    // Process the streaming responses
    var fullResponse = ""
    for try await response in responses {
        if !response.message.content.isEmpty {
            print(response.message.content, terminator: "")
            fullResponse += response.message.content
        }
        
        if response.done {
            messages.append(ChatMessage(role: .assistant, content: fullResponse))
        }
    }
} catch {
    if let ollamaError = error as? OllamaError {
        // Handle specific Ollama errors
        print("Ollama error: \(ollamaError)")
    } else {
        print("Error: \(error)")
    }
}
```

### Generate Text

```swift
let client = OllamaClient()

do {
    guard let model = OllamaModelName.parse("llama3.2") else {
        throw CLIError.invalidArgument("Invalid model name format")
    }
    
    let options = GenerationOptions(
        systemPrompt: "You are a helpful assistant"
    )
    
    let stream = try await client.generateText(
        prompt: "Tell me a story",
        model: model,
        options: options
    )
    
    var fullResponse = ""
    for try await response in stream {
        if !response.response.isEmpty {
            print(response.response, terminator: "")
            fullResponse += response.response
        }
    }
} catch {
    if let ollamaError = error as? OllamaError {
        // Handle specific Ollama errors
        print("Ollama error: \(ollamaError)")
    } else {
        print("Error: \(error)")
    }
}
```

### Error Handling

```swift
do {
    let responses = try await client.generateText(
        prompt: "Hello",
        model: OllamaModelName(name: "nonexistent-model")
    )
    for try await response in responses {
        print(response.response)
    }
} catch let error as OllamaError {
    switch error {
    case .modelNotFound:
        print("Model not found")
    case .serverError(let message):
        print("Server error: \(message)")
    case .networkError(let underlying):
        print("Network error: \(underlying)")
    case .invalidResponse:
        print("Invalid response from server")
    case .invalidParameters(let message):
        print("Invalid parameters: \(message)")
    case .decodingError(let error):
        print("Error decoding response: \(error)")
    case .unexpectedStatusCode(let code):
        print("Unexpected status code: \(code)")
    case .cancelled:
        print("Request cancelled")
    case .fileError(let error):
        print("File error: \(error)")
    }
}
```

## Best Practices

1. **Model Name Parsing**: Always use `OllamaModelName.parse()` to safely create model names
2. **Error Handling**: Implement comprehensive error handling using the `OllamaError` enum
3. **Progress Tracking**: For long-running operations like model pulls, handle progress updates
4. **Resource Management**: Use appropriate configuration options for your use case
5. **Stream Processing**: Handle streaming responses appropriately for both chat and text generation

## Contributing

Contributions are welcome!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Ollama](https://ollama.ai) for providing the base API

## Contact

If you have any questions or feedback, please open an issue on the GitHub repository.