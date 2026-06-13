import Foundation
import Combine

// MARK: - AI 对话服务
@MainActor
final class AIService: ObservableObject {
    @Published var isStreaming = false

    /// 发关 AI 请求（支持 OpenAI 兼容 API）
    func sendMessage(
        provider: AIProvider,
        apiKey: String,
        model: String,
        messages: [ChatMessage],
        temperature: Double,
        maxTokens: Int,
        systemPrompt: String
    ) async throws -> AsyncThrowingStream<String, Error> {
        let endpoint = apiEndpoint(for: provider)
        let requestBody = buildRequestBody(
            model: model,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens,
            systemPrompt: systemPrompt
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? ""
            if httpResponse.statusCode == 401 {
                throw AIError.invalidAPIKey
            }
            throw AIError.httpError(httpResponse.statusCode, errorBody)
        }

        // 解析响应
        let decoder = JSONDecoder()
        let completion = try decoder.decode(ChatCompletionResponse.self, from: data)
        guard let content = completion.choices.first?.message.content, !content.isEmpty else {
            throw AIError.emptyResponse
        }

        return AsyncThrowingStream { continuation in
            continuation.yield(content)
            continuation.finish()
        }
    }

    /// 流式 AI 请求
    func sendStreamingMessage(
        provider: AIProvider,
        apiKey: String,
        model: String,
        messages: [ChatMessage],
        temperature: Double,
        maxTokens: Int,
        systemPrompt: String
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let endpoint = self.apiEndpoint(for: provider)
            var requestBody = self.buildRequestBody(
                model: model,
                messages: messages,
                temperature: temperature,
                maxTokens: maxTokens,
                systemPrompt: systemPrompt
            )
            requestBody["stream"] = true

            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

            guard let httpBody = request.httpBody else {
                continuation.finish(throwing: AIError.invalidRequest)
                return
            }
            request.httpBody = httpBody

            let session = URLSession(configuration: .default)
            Task {
                do {
                    let (bytes, response) = try await session.bytes(for: request)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: AIError.invalidResponse)
                        return
                    }
                    guard httpResponse.statusCode == 200 else {
                        continuation.finish(throwing: AIError.httpError(httpResponse.statusCode, "Stream error"))
                        return
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonStr = String(line.dropFirst(6))
                        if jsonStr == "[DONE]" {
                            continuation.finish()
                            return
                        }
                        if let data = jsonStr.data(using: .utf8),
                           let chunk = try? JSONDecoder().decode(StreamChunk.self, from: data),
                           let content = chunk.choices.first?.delta.content {
                            continuation.yield(content)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private
    private let fallbackURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    private nonisolated func apiEndpoint(for provider: AIProvider) -> URL {
        switch provider {
        case .openAI:
            return URL(string: "https://api.openai.com/v1/chat/completions") ?? fallbackURL
        case .claude:
            return URL(string: "https://api.anthropic.com/v1/messages") ?? fallbackURL
        case .gemini:
            return URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent") ?? fallbackURL
        case .custom:
            return URL(string: "https://api.openai.com/v1/chat/completions") ?? fallbackURL
        }
    }

    private nonisolated func buildRequestBody(
        model: String,
        messages: [ChatMessage],
        temperature: Double,
        maxTokens: Int,
        systemPrompt: String
    ) -> [String: Any] {
        var msgArray: [[String: String]] = []
        if !systemPrompt.isEmpty {
            msgArray.append(["role": "system", "content": systemPrompt])
        }
        for msg in messages {
            let role: String = {
                switch msg.role {
                case .user: return "user"
                case .assistant: return "assistant"
                case .system: return "system"
                }
            }()
            msgArray.append(["role": role, "content": msg.content])
        }

        return [
            "model": model,
            "messages": msgArray,
            "temperature": temperature,
            "max_tokens": maxTokens
        ]
    }

    func generateMockReply(for message: String, context: AppState) -> String {
        let lower = message.lowercased()
        let apkInfo = context.apkInfo

        if lower.contains("包名") || lower.contains("package") {
            return "当前 APK 的包名是 **\(apkInfo.packageName.isEmpty ? "未加载" : apkInfo.packageName)**。\n\n包名是 Android 应用的唯一标识符，遵循反向域名规则（如 `com.example.app`）。它用于在 Google Play 和设备上唯一标识应用。"
        }
        if lower.contains("权限") || lower.contains("permission") {
            let dangerous = context.permissions.filter { $0.riskLevel == .dangerous || $0.riskLevel == .critical }
            return "当前 APK 共声明了 **\(context.permissions.count)** 个权限，其中：\n- 危险级别: \(dangerous.count) 个\n- 普通级别: \(context.permissions.filter { $0.riskLevel == .normal }.count) 个\n\n**危险权限列表：**\n\(dangerous.map { "- \($0.name)" }.joined(separator: "\n"))\n\n建议重点关注危险权限的用途是否合理。"
        }
        if lower.contains("证书") || lower.contains("签名") || lower.contains("certificate") {
            return "APK 签名证书信息：\n\(context.certificates.map { "- 主体: \($0.subject)\n- 签发者: \($0.issuer)\n- SHA1: \($0.fingerprintSHA1)\n- 状态: \($0.isValid ? "有效" : "无效")" }.joined(separator: "\n\n"))\n\n签名证书用于验证 APK 的完整性和来源。"
        }
        if lower.contains("组件") || lower.contains("component") {
            let grouped = Dictionary(grouping: context.components, by: { $0.componentType })
            var result = "当前 APK 共有 **\(context.components.count)** 个组件：\n"
            for (type, comps) in grouped.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
                result += "\n**\(type.rawValue):** \(comps.count) 个\n"
                for c in comps.prefix(5) {
                    result += "- \(c.name)\(c.exported ? " (已导出)" : "")\n"
                }
                if comps.count > 5 { result += "- ... 还有 \(comps.count - 5) 个\n" }
            }
            return result
        }
        if lower.contains("dex") || lower.contains("方法") {
            return "DEX 文件分析：\n- DEX 文件数: \(context.dexFiles.count) 个\n- 方法总数: \(apkInfo.methodCount)\n- 字符串总数: \(apkInfo.stringCount)\n- Smali 文件数: \(context.smaliFiles.count) 个\n\nDEX 文件包含编译后的 Java/Kotlin 代码，Smali 是其反汇编格式。"
        }
        if lower.contains("so") || lower.contains("native") || lower.contains("elf") {
            return "SO 库分析：\n- SO 文件数: \(context.soFiles.count) 个\n\(context.soFiles.map { "- \(URL(fileURLWithPath: $0).lastPathComponent)" }.joined(separator: "\n"))\n\nSO 文件是 Android 的 Native 库（ELF 格式），通常用 C/C++ 编写，用于性能优化或调用底层 API。"
        }
        if lower.contains("安全") || lower.contains("风险") || lower.contains("security") {
            let critical = context.permissions.filter { $0.riskLevel == .critical }
            let dangerous = context.permissions.filter { $0.riskLevel == .dangerous }
            let exported = context.components.filter { $0.exported }
            return "**安全风险评估：**\n\n1. **严重权限** (\(critical.count) 个):\n\(critical.map { "- \($0.name): \($0.description)" }.joined(separator: "\n"))\n\n2. **危险权限** (\(dangerous.count) 个):\n\(dangerous.prefix(5).map { "- \($0.name)" }.joined(separator: "\n"))\n\n3. **导出组件** (\(exported.count) 个):\n\(exported.prefix(5).map { "- \($0.name) [\($0.componentType.rawValue)]" }.joined(separator: "\n"))\n\n导出组件是潜在的攻击面，建议检查是否有不必要的导出。"
        }
        if lower.contains("帮助") || lower.contains("help") || lower.isEmpty {
            return "我是 CAssistant 的 AI 分析助手。你可以问我：\n\n- **包名** - 查看 APK 包名信息\n- **权限** - 分析权限列表\n- **证书/签名** - 查看签名证书\n- **组件** - 查看组件列表\n- **DEX/方法** - DEX 文件分析\n- **SO/Native** - SO 库分析\n- **安全/风险** - 安全风险评估\n\n请先导入 APK 文件，然后提出你的问题！"
        }
        return "我已收到你的问题。基于当前加载的 APK 数据，我可以帮你分析包名、权限、证书、组件、DEX 文件、SO 库等方面。请尝试更具体的问题，例如：\n- \"分析权限\"\n- \"查看证书\"\n- \"安全评估\"\n- \"DEX 分析\""
    }
}

// MARK: - API 响应模型
private struct ChatCompletionResponse: Codable {
    let choices: [Choice]
    struct Choice: Codable {
        let message: Message
        struct Message: Codable {
            let content: String?
        }
    }
}

private struct StreamChunk: Codable {
    let choices: [Choice]
    struct Choice: Codable {
        let delta: Delta
        struct Delta: Codable {
            let content: String?
        }
    }
}

// MARK: - 错误类型
enum AIError: LocalizedError {
    case invalidResponse
    case invalidAPIKey
    case httpError(Int, String)
    case emptyResponse
    case invalidRequest

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "无效的 API 响应"
        case .invalidAPIKey: return "API Key 无效，请检查设置"
        case .httpError(let code, let body): return "HTTP \(code): \(body)"
        case .emptyResponse: return "AI 返回了空响应"
        case .invalidRequest: return "请求构建失败"
        }
    }
}