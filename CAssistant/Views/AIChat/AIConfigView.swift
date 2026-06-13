import SwiftUI

struct AIConfigView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var localConfig: AIConfig
    @State private var showApiKey: Bool = false
    @State private var hasChanges: Bool = false

    init() {
        _localConfig = State(initialValue: AIConfig())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // API 提供商选择
                    providerSection

                    // API Key 输入
                    apiKeySection

                    // 模型选择
                    modelSection

                    // 温度滑块
                    temperatureSection

                    // 最大 Token
                    maxTokensSection

                    // 系统提示词
                    systemPromptSection
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            .navigationTitle("AI 配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    GlassButton(title: "取消", icon: "xmark", color: .secondary) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    GlassButton(title: "保存", icon: "checkmark", color: .blue) {
                        saveConfig()
                    }
                }
            }
            .onAppear {
                localConfig = appState.aiConfig
            }
        }
    }

    // MARK: - API 提供商选择
    private var providerSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "API 提供商", icon: "server.rack")

                HStack(spacing: 10) {
                    ForEach(AIProvider.allCases) { provider in
                        providerButton(provider)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 8)
        }
    }

    private func providerButton(_ provider: AIProvider) -> some View {
        Button(action: {
            localConfig.provider = provider
            localConfig.model = provider.defaultModel
            hasChanges = true
        }) {
            VStack(spacing: 6) {
                Image(systemName: providerIcon(for: provider))
                    .font(.title3)
                Text(provider.rawValue)
                    .font(.system(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(localConfig.provider == provider
                        ? AnyShapeStyle(Color.accentColor.opacity(0.15))
                        : AnyShapeStyle(.thinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        localConfig.provider == provider
                            ? Color.accentColor.opacity(0.4)
                            : .white.opacity(0.08),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func providerIcon(for provider: AIProvider) -> String {
        switch provider {
        case .openAI: return "brain"
        case .claude: return "sparkles"
        case .gemini: return "star.circle"
        case .custom: return "gearshape.2"
        }
    }

    // MARK: - API Key
    private var apiKeySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "API Key", icon: "key.fill")

                HStack(spacing: 8) {
                    if showApiKey {
                        TextField("输入 API Key", text: $localConfig.apiKey)
                            .font(.system(size: 14, design: .monospaced))
                            .textFieldStyle(.plain)
                            .onChange(of: localConfig.apiKey) { _, newValue in
                                hasChanges = true
                            }
                    } else {
                        SecureField("输入 API Key", text: $localConfig.apiKey)
                            .font(.system(size: 14, design: .monospaced))
                            .textFieldStyle(.plain)
                            .onChange(of: localConfig.apiKey) { _, newValue in
                                hasChanges = true
                            }
                    }

                    Button(action: { showApiKey.toggle() }) {
                        Image(systemName: showApiKey ? "eye.slash.fill" : "eye.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.thinMaterial)
                )
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - 模型选择
    private var modelSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "模型", icon: "cpu")

                VStack(spacing: 8) {
                    ForEach(availableModels, id: \.self) { model in
                        modelRow(model)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 8)
        }
    }

    private var availableModels: [String] {
        switch localConfig.provider {
        case .openAI:
            return ["gpt-4o", "gpt-4-turbo", "gpt-3.5-turbo"]
        case .claude:
            return ["claude-3-opus", "claude-3-sonnet", "claude-3-haiku"]
        case .gemini:
            return ["gemini-pro", "gemini-ultra"]
        case .custom:
            return []
        }
    }

    private func modelRow(_ model: String) -> some View {
        Button(action: {
            localConfig.model = model
            hasChanges = true
        }) {
            HStack {
                Image(systemName: localConfig.model == model ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(localConfig.model == model ? AnyShapeStyle(.blue) : AnyShapeStyle(.tertiary))
                Text(model)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(localConfig.model == model
                        ? AnyShapeStyle(.blue.opacity(0.1))
                        : AnyShapeStyle(.clear)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 温度滑块
    private var temperatureSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "温度 (Temperature)", icon: "thermometer.medium")

                VStack(spacing: 8) {
                    Slider(value: $localConfig.temperature, in: 0...2, step: 0.1) {
                        Text("温度")
                    }
                    .onChange(of: localConfig.temperature) { _, newValue in
                        hasChanges = true
                    }
                    .padding(.horizontal, 16)

                    HStack {
                        GlassBadge(text: "精确", color: .blue)
                        Spacer()
                        Text(String(format: "%.1f", localConfig.temperature))
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.primary)
                        Spacer()
                        GlassBadge(text: "创意", color: .orange)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 8)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - 最大 Token
    private var maxTokensSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "最大 Token 数", icon: "number")

                HStack {
                    TextField("Token 数量", value: $localConfig.maxTokens, format: .number)
                        .font(.system(size: 14))
                        .textFieldStyle(.plain)
                        .onChange(of: localConfig.maxTokens) { _, newValue in
                            hasChanges = true
                        }

                    Stepper("", value: $localConfig.maxTokens, in: 256...32768, step: 256)
                        .labelsHidden()
                        .onChange(of: localConfig.maxTokens) { _, newValue in
                            hasChanges = true
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.thinMaterial)
                )
                .padding(.horizontal, 16)

                Text("当前: \(localConfig.maxTokens) tokens")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - 系统提示词
    private var systemPromptSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "系统提示词", icon: "text.quote")

                TextEditor(text: $localConfig.systemPrompt)
                    .font(.system(size: 13))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.thinMaterial)
                    )
                    .onChange(of: localConfig.systemPrompt) { _, newValue in
                        hasChanges = true
                    }
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - 保存配置
    private func saveConfig() {
        appState.aiConfig = localConfig
        dismiss()
    }
}

// MARK: - Preview
struct AIConfigView_Previews: PreviewProvider {
    static var previews: some View {
        AIConfigView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}