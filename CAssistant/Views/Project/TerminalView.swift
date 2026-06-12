import SwiftUI

// MARK: - 快捷命令
struct QuickCommand: Identifiable {
    let id = UUID()
    let name: String
    let command: String
    let icon: String
}

// MARK: - 终端类型
enum TerminalType: String, CaseIterable {
    case shell  = "Shell"
    case python = "Python"
    case adb    = "ADB"
    case custom = "自定义"

    var prompt: String {
        switch self {
        case .shell:  return "$"
        case .python: return ">>>"
        case .adb:    return "adb"
        case .custom: return ">"
        }
    }
}

// MARK: - 终端输出行
struct TerminalLine: Identifiable {
    let id = UUID()
    let content: String
    let isCommand: Bool
    let isError: Bool
    let timestamp: Date
}

// MARK: - TerminalView
struct TerminalView: View {
    @EnvironmentObject private var appState: AppState

    @State private var terminalLines: [TerminalLine] = []
    @State private var currentInput: String = ""
    @State private var selectedType: TerminalType = .shell
    @State private var scrollToBottom = false

    // 会话管理
    @State private var sessionCount = 1
    @State private var currentSession = 1

    // 快捷命令
    private let quickCommands: [QuickCommand] = [
        QuickCommand(name: "ls",   command: "ls -la",                               icon: "list.bullet"),
        QuickCommand(name: "pwd",  command: "pwd",                                  icon: "arrow.forward"),
        QuickCommand(name: "cd",   command: "cd ",                                  icon: "folder"),
        QuickCommand(name: "grep", command: "grep -rn \"search\" .",                icon: "magnifyingglass"),
        QuickCommand(name: "find", command: "find . -name \"*.apk\"",               icon: "doc.text.magnifyingglass"),
        QuickCommand(name: "java", command: "java -version",                        icon: "cup.and.saucer"),
        QuickCommand(name: "apktool", command: "apktool d target.apk",              icon: "hammer"),
        QuickCommand(name: "jadx", command: "jadx-gui target.apk",                  icon: "doc.text"),
        QuickCommand(name: "adb devices", command: "adb devices",                    icon: "iphone.gen2"),
        QuickCommand(name: "clear", command: "clear",                               icon: "trash"),
        QuickCommand(name: "dex2jar", command: "d2j-dex2jar.sh classes.dex",        icon: "arrow.triangle.swap"),
        QuickCommand(name: "python", command: "python3 --version",                   icon: "chevron.left.forwardslash.chevron.right"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            toolbarView

            // 终端显示区域
            terminalDisplayView

            // 快捷命令栏
            quickCommandBar

            // 输入区域
            inputArea
        }
        .glassBackground()
        .onAppear {
            addWelcomeMessage()
        }
    }

    // MARK: - 顶部工具栏
    private var toolbarView: some View {
        HStack {
            // 终端类型选择
            Picker("终端类型", selection: $selectedType) {
                ForEach(TerminalType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)

            Spacer()

            // 会话信息
            Text("会话 \(currentSession)/\(sessionCount)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))

            // 操作按钮
            GlassButton(title: "新建会话", icon: "plus.square") {
                createNewSession()
            }

            GlassButton(title: "清空", icon: "trash") {
                clearTerminal()
            }

            GlassButton(title: "停止", icon: "stop") {
                stopCurrentCommand()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .glassCard()
    }

    // MARK: - 终端显示区域
    private var terminalDisplayView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(terminalLines) { line in
                        TerminalLineView(line: line)
                    }

                    // 输入提示符
                    HStack(spacing: 0) {
                        Text(selectedType.prompt + " ")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.green)

                        Text(currentInput)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)

                        // 光标
                        Text("|")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)
                            .opacity(0.7)
                    }
                    .id("inputLine")
                }
                .padding(12)
            }
            .background(Color.black.opacity(0.85))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
            .onChange(of: terminalLines.count) { _ in
                withAnimation {
                    proxy.scrollTo("inputLine", anchor: .bottom)
                }
            }
        }
    }

    // MARK: - 快捷命令栏
    private var quickCommandBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(quickCommands) { cmd in
                    Button {
                        insertQuickCommand(cmd.command)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: cmd.icon)
                                .font(.caption2)
                            Text(cmd.name)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.08))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .background(.white.opacity(0.04))
    }

    // MARK: - 输入区域
    private var inputArea: some View {
        HStack(spacing: 8) {
            // 提示符
            Text(selectedType.prompt)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.green)
                .bold()

            // 命令输入
            TextField("输入命令...", text: $currentInput)
                .textFieldStyle(.plain)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white)
                .padding(10)
                .background(.white.opacity(0.06))
                .cornerRadius(8)
                .onSubmit {
                    executeCommand()
                }

            // 执行按钮
            GlassButton(title: "执行", icon: "return") {
                executeCommand()
            }
        }
        .padding()
    }

    // MARK: - 终端行视图
    struct TerminalLineView: View {
        let line: TerminalLine

        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                if line.isCommand {
                    Text("$ ")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.green)
                }

                Text(line.content)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(textColor)
                    .textSelection(.enabled)

                Spacer()

                Text(formattedTime(line.timestamp))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(.vertical, 1)
        }

        private var textColor: Color {
            if line.isError { return .red }
            if line.isCommand { return .green.opacity(0.9) }
            return .white.opacity(0.8)
        }

        private func formattedTime(_ date: Date) -> String {
            let fmt = DateFormatter()
            fmt.dateFormat = "HH:mm:ss"
            return fmt.string(from: date)
        }
    }

    // MARK: - 逻辑方法
    private func addWelcomeMessage() {
        terminalLines.append(TerminalLine(
            content: "CAssistant 终端 v1.0",
            isCommand: false, isError: false,
            timestamp: Date()
        ))
        terminalLines.append(TerminalLine(
            content: "终端类型: \(selectedType.rawValue) | 输入 'help' 查看可用命令",
            isCommand: false, isError: false,
            timestamp: Date()
        ))
        terminalLines.append(TerminalLine(
            content: "---",
            isCommand: false, isError: false,
            timestamp: Date()
        ))
    }

    private func executeCommand() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // 添加命令到终端
        terminalLines.append(TerminalLine(
            content: trimmed,
            isCommand: true, isError: false,
            timestamp: Date()
        ))

        // 处理特殊命令
        if trimmed == "clear" {
            clearTerminal()
            currentInput = ""
            return
        } else if trimmed == "help" {
            addHelpMessage()
            currentInput = ""
            return
        }

        // 模拟命令输出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let output = generateMockOutput(for: trimmed)
            let isError = output.contains("未找到") || output.contains("错误")
            terminalLines.append(TerminalLine(
                content: output,
                isCommand: false,
                isError: isError,
                timestamp: Date()
            ))
            terminalLines.append(TerminalLine(
                content: "",
                isCommand: false, isError: false,
                timestamp: Date()
            ))
        }

        currentInput = ""
    }

    private func addHelpMessage() {
        let helpText = """
        可用命令:
          ls          - 列出目录内容
          pwd         - 显示当前路径
          cd <path>   - 切换目录
          grep        - 搜索文本
          find        - 查找文件
          clear       - 清空终端
          help        - 显示此帮助
          java        - Java版本信息
          apktool     - Apktool命令
          jadx        - JADX相关
          adb         - ADB命令
        """
        terminalLines.append(TerminalLine(
            content: helpText,
            isCommand: false, isError: false,
            timestamp: Date()
        ))
    }

    private func generateMockOutput(for command: String) -> String {
        if command.hasPrefix("ls") {
            return """
            total 64
            drwxr-xr-x  12 admin  staff   384  6 12 10:30 .
            drwxr-xr-x   5 admin  staff   160  6 12 09:00 ..
            -rw-r--r--   1 admin  staff  1024  6 12 10:30 AndroidManifest.xml
            drwxr-xr-x   4 admin  staff   128  6 12 10:30 res
            drwxr-xr-x   3 admin  staff    96  6 12 10:30 smali
            drwxr-xr-x   3 admin  staff    96  6 12 10:30 sources
            """
        }
        if command == "pwd" {
            return "/Users/admin/Projects/TargetApp"
        }
        if command.hasPrefix("cd ") {
            let path = command.replacingOccurrences(of: "cd ", with: "").trimmingCharacters(in: .whitespaces)
            return "已切换到目录: \(path)"
        }
        if command.hasPrefix("grep") {
            return "匹配到 3 处结果\n  MainActivity.java:42: protected void onCreate\n  HookManager.java:15: public void hookMethod\n  Utils.java:88: private void checkPermission"
        }
        if command.hasPrefix("find") {
            return """
            ./app/src/MainActivity.java
            ./app/src/HookManager.java
            ./libs/dex2jar.jar
            ./res/layout/activity_main.xml
            ./original.apk
            """
        }
        if command == "java -version" {
            return "openjdk version \"17.0.9\" 2023-10-17\nOpenJDK Runtime Environment (build 17.0.9+9)\nOpenJDK 64-Bit Server VM (build 17.0.9+9, mixed mode)"
        }
        if command.hasPrefix("apktool") {
            return "Apktool v2.9.3\nI: Using Apktool 2.9.3\nI: Loading resource table...\nI: Decoding file resources...\nI: Decoding values*/* XMLs...\nI: Done."
        }
        if command == "adb devices" {
            return "List of devices attached\nemulator-5554\tdevice\nR58M35Y6Z7V\tdevice"
        }
        if command == "python3 --version" || command.hasPrefix("python") {
            return "Python 3.11.6"
        }
        if command.hasPrefix("d2j") {
            return "dex2jar version: 2.1\ndex2jar classes.dex -> classes-dex2jar.jar\nDone."
        }

        return "命令已执行: \(command)\n返回状态: 0 (成功)"
    }

    private func insertQuickCommand(_ command: String) {
        currentInput = command
    }

    private func createNewSession() {
        sessionCount += 1
        currentSession = sessionCount
        terminalLines.append(TerminalLine(
            content: "--- 新建会话 \(currentSession) ---",
            isCommand: false, isError: false,
            timestamp: Date()
        ))
    }

    private func clearTerminal() {
        terminalLines.removeAll()
        addWelcomeMessage()
    }

    private func stopCurrentCommand() {
        terminalLines.append(TerminalLine(
            content: "命令已被用户中断 (SIGINT)",
            isCommand: false, isError: true,
            timestamp: Date()
        ))
    }
}