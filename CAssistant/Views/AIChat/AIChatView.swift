import SwiftUI

struct AIChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputText: String = ""
    @State private var isSending: Bool = false
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
            .onChange(of: appState.aiChatMessages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: isSending) { _ in
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

        // 模拟 AI 回复
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let reply = generateAIReply(for: text)
            let aiMessage = ChatMessage(role: .assistant, content: reply, timestamp: Date())
            appState.aiChatMessages.append(aiMessage)
            isSending = false
        }
    }

    // MARK: - 生成 AI 回复
    private func generateAIReply(for query: String) -> String {
        let lowercased = query.lowercased()

        if lowercased.contains("apk") || lowercased.contains("包") {
            let pkg = appState.apkInfo.packageName
            if !pkg.isEmpty {
                return "当前分析的 APK 包名为 `\(pkg)`，版本 \(appState.apkInfo.versionName)（\(appState.apkInfo.versionCode)）。该应用最低支持 SDK \(appState.apkInfo.minSdkVersion)，目标 SDK \(appState.apkInfo.targetSdkVersion)。共包含 \(appState.dexFiles.count) 个 DEX 文件和 \(appState.smaliFiles.count) 个 Smali 源文件。"
            } else {
                return "当前还没有加载 APK 文件。请先在分析页面导入一个 APK 文件，我就可以帮你进行详细分析了。"
            }
        }

        if lowercased.contains("权限") || lowercased.contains("permission") {
            let count = appState.permissions.count
            let dangerous = appState.permissions.filter { $0.riskLevel == .dangerous || $0.riskLevel == .critical }.count
            return "该应用共声明了 \(count) 个权限，其中危险/严重权限 \(dangerous) 个。建议重点关注这些高风险权限的使用情况，确保它们不会被恶意利用。"
        }

        if lowercased.contains("签名") || lowercased.contains("证书") || lowercased.contains("cert") {
            if let cert = appState.certificates.first {
                return "该 APK 的签名证书信息：签发者 `\(cert.issuer)`，有效期 \(cert.validFrom) 至 \(cert.validTo)。SHA1 指纹：\(cert.fingerprintSHA1)。当前证书状态：\(cert.isValid ? "有效" : "无效或已过期")。"
            } else {
                return "未找到签名证书信息，请确认 APK 已正确加载。"
            }
        }

        if lowercased.contains("组件") || lowercased.contains("component") {
            let exported = appState.components.filter { $0.exported }.count
            return "该应用包含 \(appState.components.count) 个组件，其中 \(exported) 个处于导出状态。导出组件可能被外部应用调用，需要检查是否存在安全风险。"
        }

        if lowercased.contains("so") || lowercased.contains("库") || lowercased.contains("native") {
            return "该 APK 包含 \(appState.soFiles.count) 个 SO 库文件。SO 库通常使用 C/C++ 编写，可能包含加密逻辑、反调试机制或其他原生代码。建议使用 IDA Pro 或 Ghidra 进行进一步分析。"
        }

        if lowercased.contains("smali") || lowercased.contains("代码") {
            return "共提取到 \(appState.smaliFiles.count) 个 Smali 文件。Smali 是 DEX 字节码的文本表示形式，可以直接修改后重新打包。你可以在 Smali 查看器中浏览和搜索关键方法。"
        }

        return "这是一个很好的问题。基于当前加载的 APK 文件（\(appState.selectedFileName)），我建议你从以下角度进一步分析：\n\n1. **权限审计** - 检查是否有过度申请的危险权限\n2. **组件安全** - 审查导出组件是否存在 Intent 注入风险\n3. **代码逻辑** - 查看关键 Smali 方法是否存在硬编码密钥或漏洞\n4. **SO 库分析** - 检查 Native 层是否有加固或反调试\n\n你想深入哪个方面？"
    }

    // MARK: - 滚动到底部
    private func scrollToBottom(proxy: ScrollViewProxy? = nil) {
        // scrollToBottom called in onAppear without proxy, handled by ScrollViewReader internally
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