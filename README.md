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
for model in models.sorted(by: { $0.name < $1.name }) {
    print(model.name)
}

// Pull a new model
let modelName = OllamaModelName(name: "llama3.2")
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

// Copy a model
try await client.copyModel(
    source: OllamaModelName(name: "llama3.2"),
    destination: OllamaModelName(name: "llama3.2-custom")
)

// Delete a model
try await client.deleteModel(name: OllamaModelName(name: "unused-model"))

// List running models
let runningModels = try await client.listRunningModels()
for model in runningModels {
    print("Model: \(model.name)")
    print("VRAM Usage: \(model.sizeVRAM) bytes")
    print("Expires: \(model.expiresAt)")
}
```

### Chat Completion

```swift
let client = OllamaClient()

do {
    // Create messages for the conversation
    var messages: [ChatMessage] = [
        ChatMessage(role: .system, content: "You are a helpful assistant"),
        ChatMessage(role: .user, content: "Hello! Can you help me?")
    ]
    
    // Start a chat stream with the model
    let responses = try await client.chat(
        messages: messages,
        model: OllamaModelName(name: "llama3.2"),
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
    print("Error: \(error)")
}
```

### Generate Embeddings

```swift
do {
    let response = try await client.generateEmbeddings(
        input: .single("Some text to embed"),
        model: OllamaModelName(name: "llama3.2")
    )
    print("Embeddings: \(response.embeddings)")
} catch {
    print("Error: \(error)")
}
```

## Advanced Usage

### Custom Model Options

```swift
let options = GenerationOptions(
    modelOptions: ModelOptions(
        temperature: 0.7,
        topP: 0.9,
        seed: 42,
        numPredict: 100
    ),
    systemPrompt: "You are a creative storyteller",
    keepAlive: 300
)

let responses = try await client.generateText(
    prompt: "Tell me a story",
    model: OllamaModelName(name: "llama3.2"),
    options: options
)
```

### Working with Images (Multimodal Models)

```swift
let imageData = // ... your image data ...
let base64Image = imageData.base64EncodedString()

let options = GenerationOptions(images: [base64Image])
let responses = try await client.generateText(
    prompt: "What's in this image?",
    model: OllamaModelName(name: "llava"),
    options: options
)
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
} catch OllamaError.modelNotFound {
    print("Model not found")
} catch OllamaError.serverError(let message) {
    print("Server error: \(message)")
} catch OllamaError.networkError(let error) {
    print("Network error: \(error)")
} catch {
    print("Other error: \(error)")
}
```

## Best Practices

1. **Reuse the Client**: Create a single `OllamaClient` instance and reuse it throughout your app.
2. **Handle Errors**: Always implement proper error handling as shown above.
3. **Configure Timeouts**: Set appropriate timeout values based on your use case.
4. **Resource Management**: Use the `keepAlive` parameter to control model memory usage.
5. **Progress Tracking**: For long-running operations, always handle progress updates.

## Contributing

Contributions are welcome!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Ollama](https://ollama.ai) for providing the base API

## Contact

If you have any questions or feedback, please open an issue on the GitHub repository.