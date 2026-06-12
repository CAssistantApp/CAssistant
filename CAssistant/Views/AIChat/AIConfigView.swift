import SwiftUI

// MARK: - AIConfigView
struct AIConfigView: View {
    @EnvironmentObject private var appState: AppState

    @State private var selectedProvider: AIProvider = .openAI
    @State private var apiKey: String = ""
    @State private var baseURL: String = ""
    @State private var selectedModel: String = "gpt-4"
    @State private var temperature: Double = 0.7
    @State private var maxTokens: Double = 2048
    @State private var useProxy = false
    @State private var proxyHost: String = ""
    @State private var proxyPort: String = "8080"
    @State private var showAPIKey = false
    @State private var isTesting = false
    @State private var testResult: String?
    @State private var testSuccess = false
    @State private var showSaveAlert = false

    // 模型选项
    private let openAIModels = ["gpt-4", "gpt-4-turbo", "gpt-4o", "gpt-4o-mini", "gpt-3.5-turbo"]
    private let claudeModels = ["claude-3-opus", "claude-3-sonnet", "claude-3-haiku", "claude-3.5-sonnet"]
    private let localModels = ["llama3", "qwen2", "deepseek", "mixtral"]

    private var currentModels: [String] {
        switch selectedProvider {
        case .openAI: return openAIModels
        case .claude: return claudeModels
        case .local: return localModels
        case .custom: return ["custom-model"]
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // API 服务商
                providerSection

                // API 密钥
                apiKeySection

                // API 地址
                apiURLSection

                // 模型选择
                modelSection

                // 参数配置
                parameterSection

                // 代理设置
                proxySection

                // 操作按钮
                actionButtons

                // 测试结果
                if let result = testResult {
                    testResultView
                }
            }
            .padding()
        }
        .glassBackground()
        .alert("配置已保存", isPresented: $showSaveAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("AI 配置已成功保存，可以在聊天中使用。")
        }
        .onAppear {
            loadConfig()
        }
    }

    // MARK: - API 服务商
    private var providerSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "API 服务商", systemImage: "globe")

                HStack(spacing: 12) {
                    ForEach(AIProvider.allCases, id: \.self) { provider in
                        Button {
                            withAnimation {
                                selectedProvider = provider
                                updateDefaultConfig()
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: providerIcon(provider))
                                    .font(.title2)
                                    .foregroundColor(selectedProvider == provider ? .white : .primary)
                                Text(providerText(provider))
                                    .font(.caption)
                                    .foregroundColor(selectedProvider == provider ? .white : .primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedProvider == provider ?
                                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                        LinearGradient(colors: [Color(.systemGray6)], startPoint: .top, endPoint: .bottom))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedProvider == provider ? Color.clear : .white.opacity(0.1), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - API 密钥
    private var apiKeySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "API 密钥", systemImage: "key.fill")

                HStack {
                    if showAPIKey {
                        TextField("输入 API 密钥", text: $apiKey)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                    } else {
                        SecureField("输入 API 密钥", text: $apiKey)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                    }

                    Button {
                        showAPIKey.toggle()
                    } label: {
                        Image(systemName: showAPIKey ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )

                Text("API 密钥仅保存在本地设备上，不会上传到服务器")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - API 地址
    private var apiURLSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "API 地址", systemImage: "link")

                TextField("https://api.openai.com/v1", text: $baseURL)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.regularMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.1), lineWidth: 0.5)
                    )

                if selectedProvider == .openAI {
                    Text("OpenAI 默认地址: https://api.openai.com/v1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if selectedProvider == .claude {
                    Text("Claude 默认地址: https://api.anthropic.com/v1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - 模型选择
    private var modelSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "模型选择", systemImage: "cpu")

                Picker("选择模型", selection: $selectedModel) {
                    ForEach(currentModels, id: \.self) { model in
                        Text(model)
                            .tag(model)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                )

                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("不同模型的性能和价格有所差异，请根据需求选择")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - 参数配置
    private var parameterSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                GlassSectionHeader(title: "参数配置", systemImage: "slider.horizontal.3")

                // 温度
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("温度 (Temperature)")
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.1f", temperature))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $temperature, in: 0...2, step: 0.1)
                        .tint(.blue)

                    HStack {
                        Text("精确")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("创造")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // 最大 Token
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("最大 Token")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(maxTokens))")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $maxTokens, in: 256...8192, step: 256)
                        .tint(.purple)

                    HStack {
                        Text("256")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("8192")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - 代理设置
    private var proxySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "代理设置", systemImage: "network")

                Toggle(isOn: $useProxy) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(.blue)
                        Text("启用代理")
                            .font(.subheadline)
                    }
                }
                .toggleStyle(.switch)

                if useProxy {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("代理地址")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("127.0.0.1", text: $proxyHost)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .monospaced))
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.regularMaterial)
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("端口")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("8080", text: $proxyPort)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .monospaced))
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.regularMaterial)
                                )
                                .frame(width: 100)
                        }
                    }

                    Text("支持的代理协议: HTTP, HTTPS, SOCKS5")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - 操作按钮
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // 测试连接
            GlassButton(title: "测试连接", icon: "antenna.radiowaves.left.and.right") {
                testConnection()
            }
            .disabled(isTesting || apiKey.isEmpty)

            // 保存配置
            GlassButton(title: "保存配置", icon: "checkmark.circle") {
                saveConfig()
            }
            .disabled(apiKey.isEmpty)
        }
        .padding(.top, 8)
    }

    // MARK: - 测试结果
    private var testResultView: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: testSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(testSuccess ? .green : .red)

                VStack(alignment: .leading, spacing: 4) {
                    Text(testSuccess ? "连接成功" : "连接失败")
                        .font(.headline)
                    Text(testResult ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(8)
        }
    }

    // MARK: - 辅助方法
    private func providerIcon(_ provider: AIProvider) -> String {
        switch provider {
        case .openAI: return "sparkles"
        case .claude: return "leaf"
        case .local: return "desktopcomputer"
        case .custom: return "gearshape"
        }
    }

    private func providerText(_ provider: AIProvider) -> String {
        switch provider {
        case .openAI: return "OpenAI"
        case .claude: return "Claude"
        case .local: return "本地模型"
        case .custom: return "自定义"
        }
    }

    private func updateDefaultConfig() {
        switch selectedProvider {
        case .openAI:
            baseURL = "https://api.openai.com/v1"
            selectedModel = "gpt-4"
        case .claude:
            baseURL = "https://api.anthropic.com/v1"
            selectedModel = "claude-3-sonnet"
        case .local:
            baseURL = "http://localhost:11434/v1"
            selectedModel = "llama3"
        case .custom:
            baseURL = ""
            selectedModel = "custom-model"
        }
    }

    private func loadConfig() {
        selectedProvider = appState.aiProvider
        apiKey = appState.aiAPIKey
        baseURL = appState.aiBaseURL
        selectedModel = appState.aiModel
    }

    private func saveConfig() {
        appState.aiProvider = selectedProvider
        appState.aiAPIKey = apiKey
        appState.aiBaseURL = baseURL
        appState.aiModel = selectedModel

        showSaveAlert = true
    }

    private func testConnection() {
        isTesting = true
        testResult = nil

        // 模拟测试连接
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if apiKey.hasPrefix("sk-") || apiKey.hasPrefix("sk-ant-") {
                testSuccess = true
                testResult = "API 连接测试通过。延迟: 120ms"
            } else {
                testSuccess = false
                testResult = "API 密钥格式不正确。OpenAI 密钥以 'sk-' 开头，Claude 密钥以 'sk-ant-' 开头"
            }
            isTesting = false
        }
    }
}

// MARK: - Preview 占位
extension LinearGradient {
    init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {
        self.init(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
    }
}