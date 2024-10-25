import Foundation

/// Information about a model's configuration and characteristics
public struct ModelInformation: Codable, Sendable {
    /// The Modelfile content
    public let modelfile: String
    /// Model parameters
    public let parameters: String
    /// The template used for prompts
    public let template: String
    /// Details about the model
    public let details: ModelDetails
    /// Additional model information
    public let modelInfo: ModelInfo
    
    private enum CodingKeys: String, CodingKey {
        case modelfile, parameters, template, details
        case modelInfo = "model_info"
    }
}

/// Additional model information
public struct ModelInfo: Codable, Sendable {
    public let architecture: String
    public let fileType: Int
    public let parameterCount: Int
    public let quantizationVersion: Int
    public let attentionHeadCount: Int
    public let attentionHeadCountKV: Int
    public let attentionLayerNormEpsilon: Double
    public let blockCount: Int
    public let contextLength: Int
    public let embeddingLength: Int
    public let feedForwardLength: Int
    public let ropeScalingType: Int?
    public let ropeDimensionCount: Int
    public let ropeFreqBase: Int
    public let vocabSize: Int
    
    private enum CodingKeys: String, CodingKey {
        case architecture = "general.architecture"
        case fileType = "general.file_type"
        case parameterCount = "general.parameter_count"
        case quantizationVersion = "general.quantization_version"
        case attentionHeadCount = "llama.attention.head_count"
        case attentionHeadCountKV = "llama.attention.head_count_kv"
        case attentionLayerNormEpsilon = "llama.attention.layer_norm_rms_epsilon"
        case blockCount = "llama.block_count"
        case contextLength = "llama.context_length"
        case embeddingLength = "llama.embedding_length"
        case feedForwardLength = "llama.feed_forward_length"
        case ropeScalingType = "llama.rope.scaling_type"
        case ropeDimensionCount = "llama.rope.dimension_count"
        case ropeFreqBase = "llama.rope.freq_base"
        case vocabSize = "llama.vocab_size"
    }
}

// Update ModelOptions.swift to fix missing fields
public struct ModelOptions: Codable, Sendable {
    public let numKeep: Int?
    public let seed: UInt32?
    public let numPredict: Int?
    public let topK: Int?
    public let topP: Double?
    public let minP: Double?
    public let tfsZ: Double?
    public let typicalP: Double?
    public let repeatLastN: Int?
    public let temperature: Double?
    public let repeatPenalty: Double?
    public let presencePenalty: Double?
    public let frequencyPenalty: Double?
    public let mirostat: Int?
    public let mirostatTau: Double?
    public let mirostatEta: Double?
    public let penalizeNewline: Bool?
    public let stop: [String]?
    public let numa: Bool?
    public let numCtx: Int?
    public let numBatch: Int?
    public let numGPU: Int?
    public let mainGPU: Int?
    public let lowVRAM: Bool?
    public let f16KV: Bool?
    public let vocabOnly: Bool?
    public let useMMap: Bool?
    public let useMLock: Bool?
    public let numThread: Int?
    
    private enum CodingKeys: String, CodingKey {
        case numKeep = "num_keep"
        case seed
        case numPredict = "num_predict"
        case topK = "top_k"
        case topP = "top_p"
        case minP = "min_p"
        case tfsZ = "tfs_z"
        case typicalP = "typical_p"
        case repeatLastN = "repeat_last_n"
        case temperature
        case repeatPenalty = "repeat_penalty"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case mirostat
        case mirostatTau = "mirostat_tau"
        case mirostatEta = "mirostat_eta"
        case penalizeNewline = "penalize_newline"
        case stop
        case numa
        case numCtx = "num_ctx"
        case numBatch = "num_batch"
        case numGPU = "num_gpu"
        case mainGPU = "main_gpu"
        case lowVRAM = "low_vram"
        case f16KV = "f16_kv"
        case vocabOnly = "vocab_only"
        case useMMap = "use_mmap"
        case useMLock = "use_mlock"
        case numThread = "num_thread"
    }
    
    public init(
        numKeep: Int? = nil,
        seed: UInt32? = nil,
        numPredict: Int? = nil,
        topK: Int? = nil,
        topP: Double? = nil,
        minP: Double? = nil,
        tfsZ: Double? = nil,
        typicalP: Double? = nil,
        repeatLastN: Int? = nil,
        temperature: Double? = nil,
        repeatPenalty: Double? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        mirostat: Int? = nil,
        mirostatTau: Double? = nil,
        mirostatEta: Double? = nil,
        penalizeNewline: Bool? = nil,
        stop: [String]? = nil,
        numa: Bool? = nil,
        numCtx: Int? = nil,
        numBatch: Int? = nil,
        numGPU: Int? = nil,
        mainGPU: Int? = nil,
        lowVRAM: Bool? = nil,
        f16KV: Bool? = nil,
        vocabOnly: Bool? = nil,
        useMMap: Bool? = nil,
        useMLock: Bool? = nil,
        numThread: Int? = nil
    ) {
        self.numKeep = numKeep
        self.seed = seed
        self.numPredict = numPredict
        self.topK = topK
        self.topP = topP
        self.minP = minP
        self.tfsZ = tfsZ
        self.typicalP = typicalP
        self.repeatLastN = repeatLastN
        self.temperature = temperature
        self.repeatPenalty = repeatPenalty
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.mirostat = mirostat
        self.mirostatTau = mirostatTau
        self.mirostatEta = mirostatEta
        self.penalizeNewline = penalizeNewline
        self.stop = stop
        self.numa = numa
        self.numCtx = numCtx
        self.numBatch = numBatch
        self.numGPU = numGPU
        self.mainGPU = mainGPU
        self.lowVRAM = lowVRAM
        self.f16KV = f16KV
        self.vocabOnly = vocabOnly
        self.useMMap = useMMap
        self.useMLock = useMLock
        self.numThread = numThread
    }
}
