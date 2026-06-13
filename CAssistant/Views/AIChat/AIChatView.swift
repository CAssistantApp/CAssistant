import SwiftUI

struct AIChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputText: String = ""
    @State private var isSending: Bool = false
    @StateObject private var aiService = AIService()
    @Namespace private var bottomID

    var body: some View {
        VStack(spacing: 0) {
            // 顶部：模型选择器和清空按钮
            topBar

            Divider()
                .background(.white.opacity(0.1))

            // 中间：对话消息列表
            chatMessagesView

            Divider()
                .background(.white.opacity(0.1))

            // 底部：输入区域
            inputArea
        }
        .background(.ultraThinMaterial)
        .navigationTitle("AI 对话")
        .onAppear {
            scrollToBottom()
        }
    }

    // MARK: - 顶部栏
    private var topBar: some View {
        HStack {
            GlassBadge(text: appState.aiConfig.model, color: .blue)

            Spacer()

            GlassSectionHeader(title: appState.aiConfig.provider.rawValue, icon: "bolt.circle.fill")

            Spacer()

            GlassButton(title: "清空", icon: "trash", color: .red) {
                appState.aiChatMessages.removeAll()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - 对话消息列表
    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if appState.aiChatMessages.isEmpty {
                        emptyChatPlaceholder
                    }

                    ForEach(appState.aiChatMessages) { message in
                        chatBubble(message)
                            .id(message.id)
                    }

                    if isSending {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.thinMaterial)
                                )
                            Spacer()
                        }
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(bottomID)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: appState.aiChatMessages.count) { _, newValue in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: isSending) { _, newValue in
                if !isSending {
                    scrollToBottom(proxy: proxy)
                }
            }
        }
    }

    private var emptyChatPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            Text("开始 AI 对话")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("询问关于 APK 分析、权限、代码等问题")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer().frame(height: 60)
        }
    }

    // MARK: - 聊天气泡
    @ViewBuilder
    private func chatBubble(_ message: ChatMessage) -> some View {
        let isUser = message.role == .user

        HStack(alignment: .top, spacing: 8) {
            if !isUser {
                aiAvatar
            } else {
                Spacer(minLength: 60)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isUser
                                ? AnyShapeStyle(.blue.opacity(0.2))
                                : AnyShapeStyle(.green.opacity(0.15))
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isUser ? Color.blue.opacity(0.3) : Color.green.opacity(0.25),
                                lineWidth: 0.5
                            )
                    )

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if isUser {
                userAvatar
            } else {
                Spacer(minLength: 60)
            }
        }
    }

    private var userAvatar: some View {
        Image(systemName: "person.circle.fill")
            .font(.title3)
            .foregroundColor(.blue)
            .frame(width: 32, height: 32)
    }

    private var aiAvatar: some View {
        Image(systemName: "brain.head.profile")
            .font(.title3)
            .foregroundColor(.green)
            .frame(width: 32, height: 32)
    }

    // MARK: - 输入区域
    private var inputArea: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack(alignment: .topLeading) {
                if inputText.isEmpty {
                    Text("输入消息...")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                TextEditor(text: $inputText)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 36, maxHeight: 100)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
            )

            Button(action: sendMessage) {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.blue))
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - 发送消息
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        let userMessage = ChatMessage(role: .user, content: text, timestamp: Date())
        appState.aiChatMessages.append(userMessage)
        inputText = ""
        isSending = true

        // 尝试真实 AI API
        let hasAPIKey = !appState.aiConfig.apiKey.isEmpty
        let provider = appState.aiConfig.provider
        let model = appState.aiConfig.model

        if hasAPIKey {
            Task {
                do {
                    let stream = try await aiService.sendMessage(
                        provider: provider,
                        apiKey: appState.aiConfig.apiKey,
                        model: model,
                        messages: appState.aiChatMessages,
                        temperature: appState.aiConfig.temperature,
                        maxTokens: appState.aiConfig.maxTokens,
                        systemPrompt: appState.aiConfig.systemPrompt
                    )
                    var fullReply = ""
                    for try await chunk in stream {
                        fullReply += chunk
                    }
                    if !fullReply.isEmpty {
                        let aiMessage = ChatMessage(role: .assistant, content: fullReply, timestamp: Date())
                        await MainActor.run {
                            appState.aiChatMessages.append(aiMessage)
                            isSending = false
                        }
                        return
                    }
                } catch {
                    // API 失败，走本地回退
                }
                await MainActor.run {
                    let reply = generateLocalReply(for: text)
                    let aiMessage = ChatMessage(role: .assistant, content: reply, timestamp: Date())
                    appState.aiChatMessages.append(aiMessage)
                    isSending = false
                }
            }
        } else {
            // 无 API Key，使用本地分析引擎
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let reply = generateLocalReply(for: text)
                let aiMessage = ChatMessage(role: .assistant, content: reply, timestamp: Date())
                appState.aiChatMessages.append(aiMessage)
                isSending = false
            }
        }
    }

    // MARK: - 本地分析引擎（基于 APK 真实数据）
    private func generateLocalReply(for query: String) -> String {
        let lowercased = query.lowercased()

        // 帮助/引导
        if lowercased.contains("帮助") || lowercased.contains("help") || lowercased.contains("能做什么") {
            return """
            **CAssistant AI 分析助手** — 我可以帮你：

            📦 **APK 信息** - 包名、版本、SDK 版本等
            🔐 **权限审计** - 分析危险/严重权限
            📜 **签名证书** - 查看证书指纹和有效期
            🧩 **组件分析** - Activity/Service/Receiver/Provider
            📚 **DEX/Smali** - DEX 文件数、方法数、Smali 分析
            🖥️ **SO 库** - Native 库文件列表和分析
            🔒 **安全评估** - 综合分析安全风险

            请先导入 APK 文件，然后直接提问即可！
            """
        }

        let hasApk = !appState.apkInfo.packageName.isEmpty

        if !hasApk {
            return "当前还没有加载 APK 文件。请先在「分析」页面导入一个 APK 文件（点击「选择文件」按钮），加载完成后我就可以帮你进行详细分析了。"
        }

        // APK 基本信息
        if lowercased.contains("包名") || lowercased.contains("package") || lowercased.contains("版本") {
            let info = appState.apkInfo
            return """
            **APK 基本信息**
            - 包名: `\(info.packageName)`
            - 版本名: \(info.versionName)
            - 版本号: \(info.versionCode)
            - 最低 SDK: \(info.minSdkVersion)
            - 目标 SDK: \(info.targetSdkVersion)
            - 应用名: \(info.appName)
            - DEX 文件: \(info.dexCount) 个
            - 方法数: \(info.methodCount)
            - 字符串数: \(info.stringCount)
            - 文件大小: \(FileHelpers.fileSizeString(info.fileSize))

            共解析出 \(appState.files.count) 个文件，\(appState.classes.count) 个类。
            """
        }

        // 权限分析
        if lowercased.contains("权限") || lowercased.contains("permission") {
            let normal = appState.permissions.filter { $0.riskLevel == .normal }
            let dangerous = appState.permissions.filter { $0.riskLevel == .dangerous }
            let critical = appState.permissions.filter { $0.riskLevel == .critical }
            return """
            **权限审计报告**
            - 总计: \(appState.permissions.count) 个
            - 普通: \(normal.count) 个
            - 危险: \(dangerous.count) 个
            - 严重: \(critical.count) 个

            \(critical.isEmpty ? "✅ 无严重权限" : "⚠️ 严重权限:\n" + critical.map { "- `\($0.name)` (\($0.description))" }.joined(separator: "\n"))

            \(dangerous.isEmpty ? "" : "\n**危险权限:**\n" + dangerous.map { "- `\($0.name)`" }.joined(separator: "\n"))

            建议：检查危险权限是否有对应的合理功能需求，避免隐私泄露风险。
            """
        }

        // 证书/签名
        if lowercased.contains("证书") || lowercased.contains("签名") || lowercased.contains("cert") {
            if let cert = appState.certificates.first {
                return """
                **签名证书信息**
                - 主体: `\(cert.subject)`
                - 签发者: `\(cert.issuer)`
                - 版本: V\(cert.version)
                - 签名算法: \(cert.signatureAlgorithm)
                - 公钥算法: \(cert.publicKeyAlgorithm)
                - 序列号: `\(cert.serialNumber)`
                - 有效期: \(FileHelpers.formatDate(cert.validFrom)) → \(FileHelpers.formatDate(cert.validTo))
                - 状态: \(cert.isValid ? "✅ 有效" : "❌ 已过期")

                **数字指纹**
                - MD5: `\(cert.fingerprintMD5)`
                - SHA1: `\(cert.fingerprintSHA1)`
                - SHA256: `\(cert.fingerprintSHA256)`
                """
            }
            return "未找到签名证书信息。"
        }

        // 组件分析
        if lowercased.contains("组件") || lowercased.contains("component") {
            let activities = appState.components.filter { $0.componentType == .activity }
            let services = appState.components.filter { $0.componentType == .service }
            let receivers = appState.components.filter { $0.componentType == .receiver }
            let providers = appState.components.filter { $0.componentType == .provider }
            let exported = appState.components.filter { $0.exported }
            return """
            **组件分析**
            - Activity: \(activities.count) 个
            - Service: \(services.count) 个
            - Receiver: \(receivers.count) 个
            - Provider: \(providers.count) 个
            - 导出组件: \(exported.count) 个

            \(exported.isEmpty ? "✅ 无导出组件" : "⚠️ 导出组件列表:\n" + exported.map { "- `\($0.name)` [\($0.componentType.rawValue)]" }.joined(separator: "\n"))

            导出组件可被外部应用通过 Intent 调用，建议为非必要组件添加 `android:exported="false"`。
            """
        }

        // DEX/Smali 代码
        if lowercased.contains("dex") || lowercased.contains("smali") || lowercased.contains("方法") || lowercased.contains("代码") {
            return """
            **代码分析**
            - DEX 文件: \(appState.dexFiles.count) 个
            - Smali 文件: \(appState.smaliFiles.count) 个
            - 类: \(appState.classes.count) 个
            - 方法数: \(appState.apkInfo.methodCount)
            - 字符串数: \(appState.apkInfo.stringCount)

            DEX 文件是 Dalvik 字节码的容器。Smali 是 DEX 的可读反汇编格式，你可以在 Smali 查看器中浏览代码逻辑。
            """
        }

        // SO/Native 库
        if lowercased.contains("so") || lowercased.contains("库") || lowercased.contains("native") || lowercased.contains("elf") {
            if appState.soFiles.isEmpty {
                return "该 APK 不包含 SO（Native）库文件。"
            }
            let libNames = appState.soFiles.map { "- `\(URL(fileURLWithPath: $0).lastPathComponent)`" }.joined(separator: "\n")
            return """
            **SO Native 库分析**
            共 \(appState.soFiles.count) 个 SO 文件：

            \(libNames)

            SO 库是 ARM64 ELF 格式的 Native 代码，通常使用 C/C++/Rust 编写。常用于：
            - 性能敏感计算（图像处理、编解码）
            - 加密/解密逻辑
            - 反调试/代码保护
            - 第三方 SDK

            建议使用 Hopper 或 Ghidra 对关键 SO 库进行更深层分析。
            """
        }

        // 安全评估
        if lowercased.contains("安全") || lowercased.contains("风险") || lowercased.contains("security") {
            let criticalPerms = appState.permissions.filter { $0.riskLevel == .critical }
            let dangerousPerms = appState.permissions.filter { $0.riskLevel == .dangerous }
            let exported = appState.components.filter { $0.exported }
            var score = 100
            score -= criticalPerms.count * 15
            score -= dangerousPerms.count * 5
            score -= exported.count * 3
            score = max(0, min(100, score))
            return """
            **安全风险评估** — 评分: \(score)/100

            \(score >= 80 ? "🟢 相对安全" : score >= 50 ? "🟡 中等风险" : "🔴 高风险")

            **检查项:**
            - 严重权限: \(criticalPerms.count) 个 \(criticalPerms.isEmpty ? "✅" : "⚠️")
            - 危险权限: \(dangerousPerms.count) 个
            - 导出组件: \(exported.count) 个 \(exported.isEmpty ? "✅" : "⚠️")

            **建议:**
            1. 审查所有危险权限是否有对应的功能需求
            2. 非必要的导出组件应设为不导出
            3. 检查是否有调试标志（debuggable）
            4. 检查是否有备份标志（allowBackup）
            """
        }

        // 文件结构
        if lowercased.contains("文件") || lowercased.contains("结构") || lowercased.contains("目录") {
            return """
            该 APK 共包含 \(appState.files.count) 个文件。
            文件类型分布:
            - Smali: \(appState.smaliFiles.count)
            - DEX: \(appState.dexFiles.count)
            - SO: \(appState.soFiles.count)
            - ARSC: \(appState.arscFiles.count)
            - 其他: \(appState.files.count - appState.smaliFiles.count - appState.dexFiles.count - appState.soFiles.count - appState.arscFiles.count)

            你可以在文件浏览和文件预览页面查看详细文件树。
            """
        }

        // 默认通用回复
        return """
        这是一个很好的问题！基于当前加载的 **\(appState.apkInfo.packageName)** (\(appState.apkInfo.versionName))，我建议从以下角度深入分析：

        1. **安全审计** — 检查权限和导出组件风险
        2. **代码分析** — 查看 DEX 和 Smali 代码逻辑
        3. **SO 库分析** — 分析 Native 层实现
        4. **组件分析** — 审查四大组件配置

        你可以直接问：
        - "查看权限"
        - "安全评估"
        - "组件分析"
        - "证书信息"
        """
    }

    // MARK: - 滚动到底部
    private func scrollToBottom(proxy: ScrollViewProxy? = nil) {
        if let proxy = proxy {
            withAnimation { proxy.scrollTo(bottomID, anchor: .bottom) }
        }
    }
}

// MARK: - Preview
struct AIChatView_Previews: PreviewProvider {
    static var previews: some View {
        AIChatView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}