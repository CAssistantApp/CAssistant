import SwiftUI

// MARK: - 快捷提示
private struct QuickPrompt: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let prompt: String
}

// MARK: - AIChatView
struct AIChatView: View {
    @EnvironmentObject private var appState: AppState

    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isSending = false
    @State private var showClearAlert = false
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var scrollToBottom = false

    // 快捷提示
    private let quickPrompts: [QuickPrompt] = [
        QuickPrompt(title: "分析 Smali 代码", icon: "chevron.left.forwardslash.chevron.right", prompt: "请帮我分析这段 Smali 代码的功能和结构"),
        QuickPrompt(title: "解释 DEX 结构", icon: "tree", prompt: "请解释 DEX 文件的类和方法组织结构"),
        QuickPrompt(title: "APK 安全评估", icon: "lock.shield", prompt: "请对当前 APK 做安全评估分析"),
        QuickPrompt(title: "代码优化建议", icon: "wand.and.stars", prompt: "请给出 Smali 代码的优化建议"),
        QuickPrompt(title: "权限说明", icon: "hand.raised", prompt: "请解释这些权限的实际影响和风险"),
        QuickPrompt(title: "反混淆", icon: "questionmark.circle", prompt: "请帮忙分析这段混淆代码的含义"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            toolbarView

            // 消息列表
            messageListView

            // 快捷提示
            if messages.isEmpty {
                quickPromptView
            }

            // 输入区域
            inputView
        }
        .glassBackground()
        .alert("确认清空", isPresented: $showClearAlert) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                withAnimation {
                    messages.removeAll()
                }
            }
        } message: {
            Text("确定要清空所有聊天记录吗？此操作不可撤销。")
        }
        .confirmationDialog("导出聊天记录", isPresented: $showExportSheet) {
            Button("导出为文本文件") { exportChat() }
            Button("导出为 JSON") { exportChatJSON() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("选择导出格式")
        }
    }

    // MARK: - 工具栏
    private var toolbarView: some View {
        HStack {
            Text("AI 助手")
                .font(.title2.bold())

            Spacer()

            HStack(spacing: 8) {
                // 导入按钮
                GlassButton(title: "导入", icon: "square.and.arrow.down") {
                    showImportPicker = true
                }

                // 导出按钮
                GlassButton(title: "导出", icon: "square.and.arrow.up") {
                    showExportSheet = true
                }

                // 清空按钮
                GlassButton(title: "清空", icon: "trash") {
                    if !messages.isEmpty {
                        showClearAlert = true
                    }
                }
                .foregroundColor(messages.isEmpty ? .gray : .red)
                .disabled(messages.isEmpty)
            }
        }
        .padding()
        .glassCard()
    }

    // MARK: - 消息列表
    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messages.isEmpty {
                        welcomeView
                    } else {
                        ForEach(messages) { message in
                            messageBubbleView(message)
                                .id(message.id)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _ in
                if let last = messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - 欢迎消息
    private var welcomeView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 40)

            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                Text("欢迎使用 AI 助手")
                    .font(.title2.bold())

                Text("我可以帮助你分析 Smali 代码、理解 APK 结构、\n提供安全评估建议等")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("当前模型：\(appState.aiModel)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }

            Spacer()
                .frame(height: 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - 消息气泡
    private func messageBubbleView(_ message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // 头像
            if message.role == .assistant {
                Image(systemName: "brain")
                    .font(.title3)
                    .foregroundColor(.purple)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                    )
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                // 消息内容
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if message.role == .user {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.regularMaterial)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    )

                // 时间
                HStack(spacing: 4) {
                    if message.role == .user {
                        Text("已发送")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.65, alignment: message.role == .user ? .trailing : .leading)

            // 用户头像
            if message.role == .user {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
        .padding(.horizontal, 4)
    }

    // MARK: - 快捷提示
    private var quickPromptView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("快捷提示")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickPrompts) { prompt in
                        Button {
                            inputText = prompt.prompt
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: prompt.icon)
                                    .font(.caption)
                                Text(prompt.title)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.regularMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - 输入区域
    private var inputView: some View {
        VStack(spacing: 0) {
            Divider()
                .opacity(0.5)

            HStack(spacing: 12) {
                // 输入框
                HStack(spacing: 8) {
                    TextField("输入消息...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .lineLimit(1...5)

                    if !inputText.isEmpty {
                        Button {
                            inputText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )

                // 发送按钮
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - 发送消息
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // 添加用户消息
        let userMessage = ChatMessage(
            role: .user,
            content: text,
            timestamp: Date()
        )
        withAnimation {
            messages.append(userMessage)
        }
        inputText = ""
        isSending = true

        // 模拟 AI 响应
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let response = generateMockResponse(for: text)
            let aiMessage = ChatMessage(
                role: .assistant,
                content: response,
                timestamp: Date()
            )
            withAnimation {
                messages.append(aiMessage)
            }
            isSending = false
        }
    }

    // MARK: - 模拟响应
    private func generateMockResponse(for text: String) -> String {
        if text.contains("Smali") || text.contains("smali") {
            return """
            这是一段 Smali 代码分析结果：

            1. **类信息**: 该类继承自 AppCompatActivity，实现了 OnClickListener 接口
            2. **关键方法**:
               - `onCreate`: 初始化布局和 ViewModel
               - `onClick`: 处理点击事件，调用 ViewModel 的数据获取
            3. **字段说明**:
               - `binding`: DataBinding 绑定实例
               - `userViewModel`: 用户数据 ViewModel

            该 Activity 使用了 MVVM 架构模式，配合 DataBinding 实现数据驱动的 UI 更新。
            """
        } else if text.contains("DEX") || text.contains("dex") {
            return """
            DEX 文件结构分析：

            1. **DEX Header**: 包含魔数、校验和、文件大小等信息
            2. **string_ids**: 字符串索引表，包含所有使用的字符串
            3. **type_ids**: 类型索引表，定义所有引用类型
            4. **proto_ids**: 方法原型索引表
            5. **field_ids**: 字段索引表
            6. **method_ids**: 方法索引表
            7. **class_defs**: 类定义表，包含类访问标志、父类、接口列表等

            当前 APK 包含 1 个 DEX 文件，共约 8,500 个方法引用。
            """
        } else if text.contains("安全") || text.contains("评估") {
            return """
            APK 安全评估报告：

            **高风险项**:
            - 检测到 3 个 WebView 未禁用 JavaScript
            - SharedPreferences 存储敏感数据未加密
            
            **中风险项**:
            - 使用 Log 输出调试信息 (TAG: "MainActivity")
            - 未使用网络安全配置 (network_security_config.xml)
            
            **低风险项**:
            - TargetSDK 未更新至最新版本
            
            **建议**: 修复高风险项，使用 EncryptedSharedPreferences 替代普通 SP。
            """
        } else if text.contains("权限") {
            return """
            权限分析报告：

            当前 APK 声明的敏感权限：
            
            1. **CAMERA** - 高风险
               - 允许应用拍摄照片和视频
               - 建议在不需要时移除
               
            2. **ACCESS_FINE_LOCATION** - 高风险
               - 允许应用获取精确位置
               - 需确保符合隐私政策
               
            3. **READ_CONTACTS** - 中风险
               - 允许读取联系人数据
               - 检查是否有必要功能使用
               
            4. **INTERNET** - 正常
               - 基本的网络访问权限
            """
        } else {
            return """
            感谢您的提问！作为 AI 助手，我可以帮助您：

            - **代码分析**: 分析和解释 Smali/Java/Kotlin 代码
            - **APK 分析**: 解析 APK 结构、权限、组件信息
            - **安全评估**: 检测安全风险和漏洞
            - **逆向辅助**: 提供反编译、脱壳等技术支持

            请提供更具体的需求，我将为您提供详细的分析和建议。
            """
        }
    }

    // MARK: - 导入导出
    private func exportChat() {
        // 导出为文本
        var text = "CAssistant AI 聊天记录\n"
        text += "导出时间: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium))\n"
        text += String(repeating: "=", count: 50) + "\n\n"

        for message in messages {
            let role = message.role == .user ? "用户" : "AI"
            text += "[\(role)] \(DateFormatter.localizedString(from: message.timestamp, dateStyle: .none, timeStyle: .medium))\n"
            text += "\(message.content)\n\n"
        }
        print("导出聊天记录:\n\(text)")
    }

    private func exportChatJSON() {
        // 导出为 JSON
        struct ExportMessage: Codable {
            let role: String
            let content: String
            let timestamp: TimeInterval
        }
        let exportData = messages.map { ExportMessage(role: $0.role.rawValue, content: $0.content, timestamp: $0.timestamp.timeIntervalSince1970) }
        if let jsonData = try? JSONEncoder().encode(exportData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("导出 JSON:\n\(jsonString)")
        }
    }
}