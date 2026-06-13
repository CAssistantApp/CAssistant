import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var appState: AppState
    @State private var commandInput: String = ""
    @State private var terminalOutput: [TerminalLine] = []
    @State private var commandHistory: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            // 终端标题栏
            titleBar

            Divider()
                .background(.white.opacity(0.1))

            // 终端输出区域
            outputArea

            Divider()
                .background(.white.opacity(0.1))

            // 命令输入行
            inputLine
        }
        .background(Color.black.opacity(0.9))
        .navigationTitle("终端")
        .onAppear {
            if terminalOutput.isEmpty {
                terminalOutput.append(TerminalLine(text: "CAssistant Terminal v3.0", type: .info))
                terminalOutput.append(TerminalLine(text: "输入 'help' 查看可用命令", type: .info))
                terminalOutput.append(TerminalLine(text: "", type: .output))
            }
        }
    }

    // MARK: - 标题栏
    private var titleBar: some View {
        HStack {
            GlassSectionHeader(title: "终端", icon: "terminal.fill")

            Spacer()

            GlassButton(title: "清屏", icon: "trash", color: .secondary) {
                terminalOutput = []
                terminalOutput.append(TerminalLine(text: "CAssistant Terminal v3.0", type: .info))
                terminalOutput.append(TerminalLine(text: "输入 'help' 查看可用命令", type: .info))
                terminalOutput.append(TerminalLine(text: "", type: .output))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.thinMaterial)
    }

    // MARK: - 输出区域
    private var outputArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(terminalOutput.indices, id: \.self) { index in
                        terminalLineView(terminalOutput[index])
                            .id(index)
                    }

                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: terminalOutput.count) { _ in
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }

    @ViewBuilder
    private func terminalLineView(_ line: TerminalLine) -> some View {
        switch line.type {
        case .command:
            Text("$ \(line.text)")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.green)
        case .output:
            Text(line.text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
        case .error:
            Text(line.text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.red)
        case .info:
            Text(line.text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.cyan)
        case .highlight:
            Text(line.text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.yellow)
        }
    }

    // MARK: - 命令输入行
    private var inputLine: some View {
        HStack(spacing: 8) {
            Text("$")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.green)

            TextField("输入命令...", text: $commandInput)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .onSubmit {
                    executeCommand()
                }

            Button(action: executeCommand) {
                Image(systemName: "arrow.forward.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(commandInput.trimmingCharacters(in: .whitespaces).isEmpty ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.green))
            }
            .buttonStyle(.plain)
            .disabled(commandInput.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.thinMaterial)
    }

    // MARK: - 执行命令
    private func executeCommand() {
        let cmd = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cmd.isEmpty else { return }

        terminalOutput.append(TerminalLine(text: cmd, type: .command))
        commandHistory.append(cmd)
        commandInput = ""

        let parts = cmd.components(separatedBy: .whitespaces)
        let command = parts[0].lowercased()
        let args = Array(parts.dropFirst())

        switch command {
        case "ls":
            handleLS(args: args)
        case "pwd":
            handlePWD()
        case "cat":
            handleCAT(args: args)
        case "help":
            handleHelp()
        case "clear":
            handleClear()
        case "info":
            handleInfo()
        case "whoami":
            terminalOutput.append(TerminalLine(text: "CAssistant User", type: .output))
        case "date":
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            terminalOutput.append(TerminalLine(text: formatter.string(from: Date()), type: .output))
        case "echo":
            terminalOutput.append(TerminalLine(text: args.joined(separator: " "), type: .output))
        default:
            terminalOutput.append(TerminalLine(text: "未知命令: \(command)。输入 'help' 查看可用命令。", type: .error))
        }
    }

    // MARK: - ls 命令
    private func handleLS(args: [String]) {
        if appState.files.isEmpty {
            terminalOutput.append(TerminalLine(text: "没有文件。请先加载 APK。", type: .error))
            return
        }

        let showAll = args.contains("-a") || args.contains("-la") || args.contains("-al")
        let showDetail = args.contains("-l") || args.contains("-la") || args.contains("-al")

        let filesToShow = showAll ? appState.files : appState.files.filter { !$0.name.hasPrefix(".") }

        for file in filesToShow.prefix(50) {
            if showDetail {
                let dir = file.isDirectory ? "d" : "-"
                let size = String(format: "%10d", file.size)
                let line = "\(dir)rwxr-xr-x  \(size)  \(file.name)"
                terminalOutput.append(TerminalLine(text: line, type: .output))
            } else {
                let color: TerminalLineType = file.isDirectory ? .highlight : .output
                terminalOutput.append(TerminalLine(text: file.name, type: color))
            }
        }

        if filesToShow.count > 50 {
            terminalOutput.append(TerminalLine(text: "... 以及 \(filesToShow.count - 50) 个文件", type: .info))
        }

        terminalOutput.append(TerminalLine(text: "共 \(filesToShow.count) 个项目", type: .info))
    }

    // MARK: - pwd 命令
    private func handlePWD() {
        if appState.extractedPath.isEmpty {
            terminalOutput.append(TerminalLine(text: "未设置提取路径。请先加载 APK。", type: .error))
        } else {
            terminalOutput.append(TerminalLine(text: appState.extractedPath, type: .output))
        }
    }

    // MARK: - cat 命令
    private func handleCAT(args: [String]) {
        guard !args.isEmpty else {
            terminalOutput.append(TerminalLine(text: "用法: cat <文件名>", type: .error))
            return
        }

        let fileName = args[0]
        if !appState.selectedFileName.isEmpty && fileName == appState.selectedFileName {
            terminalOutput.append(TerminalLine(text: "[二进制文件内容无法直接显示]", type: .info))
            terminalOutput.append(TerminalLine(text: "APK 文件信息:", type: .info))
            terminalOutput.append(TerminalLine(text: "  包名: \(appState.apkInfo.packageName)", type: .output))
            terminalOutput.append(TerminalLine(text: "  版本: \(appState.apkInfo.versionName)", type: .output))
            return
        }

        if fileName == "AndroidManifest.xml" || fileName.lowercased().contains("manifest") {
            let xml = appState.manifest.formattedXML
            if !xml.isEmpty {
                for line in xml.components(separatedBy: "\n").prefix(30) {
                    terminalOutput.append(TerminalLine(text: line, type: .output))
                }
                if xml.components(separatedBy: "\n").count > 30 {
                    terminalOutput.append(TerminalLine(text: "... (内容过长，已截断)", type: .info))
                }
                return
            }
        }

        // 在 files 中查找
        if let match = appState.files.first(where: { $0.name == fileName || $0.path.hasSuffix(fileName) }) {
            terminalOutput.append(TerminalLine(text: "文件名: \(match.name)", type: .output))
            terminalOutput.append(TerminalLine(text: "路径: \(match.path)", type: .output))
            terminalOutput.append(TerminalLine(text: "大小: \(formatSize(match.size))", type: .output))
            terminalOutput.append(TerminalLine(text: "类型: \(match.isDirectory ? "目录" : "文件")", type: .output))
        } else {
            terminalOutput.append(TerminalLine(text: "cat: \(fileName): 文件未找到", type: .error))
        }
    }

    // MARK: - help 命令
    private func handleHelp() {
        let helpText = [
            "可用命令:",
            "  ls [-l] [-a]    列出文件",
            "  pwd             显示当前提取路径",
            "  cat <file>      显示文件信息",
            "  echo <text>     输出文本",
            "  whoami          显示当前用户",
            "  date            显示当前日期时间",
            "  info            显示 APK 信息",
            "  clear           清屏",
            "  help            显示此帮助信息"
        ]
        for line in helpText {
            terminalOutput.append(TerminalLine(text: line, type: .info))
        }
    }

    // MARK: - clear 命令
    private func handleClear() {
        terminalOutput = []
    }

    // MARK: - info 命令
    private func handleInfo() {
        if appState.selectedFileName.isEmpty {
            terminalOutput.append(TerminalLine(text: "未加载 APK 文件。", type: .error))
            return
        }

        terminalOutput.append(TerminalLine(text: "=== APK 信息 ===", type: .highlight))
        terminalOutput.append(TerminalLine(text: "文件: \(appState.selectedFileName)", type: .output))
        terminalOutput.append(TerminalLine(text: "包名: \(appState.apkInfo.packageName)", type: .output))
        terminalOutput.append(TerminalLine(text: "版本: \(appState.apkInfo.versionName) (\(appState.apkInfo.versionCode))", type: .output))
        terminalOutput.append(TerminalLine(text: "Min SDK: \(appState.apkInfo.minSdkVersion)", type: .output))
        terminalOutput.append(TerminalLine(text: "Target SDK: \(appState.apkInfo.targetSdkVersion)", type: .output))
        terminalOutput.append(TerminalLine(text: "DEX 数量: \(appState.dexFiles.count)", type: .output))
        terminalOutput.append(TerminalLine(text: "Smali 文件: \(appState.smaliFiles.count)", type: .output))
        terminalOutput.append(TerminalLine(text: "SO 库: \(appState.soFiles.count)", type: .output))
        terminalOutput.append(TerminalLine(text: "权限: \(appState.permissions.count)", type: .output))
        terminalOutput.append(TerminalLine(text: "组件: \(appState.components.count)", type: .output))
    }

    // MARK: - 辅助
    private func formatSize(_ size: Int64) -> String {
        if size < 1024 { return "\(size) B" }
        if size < 1024 * 1024 { return String(format: "%.1f KB", Double(size) / 1024.0) }
        return String(format: "%.1f MB", Double(size) / (1024.0 * 1024.0))
    }
}

// MARK: - 终端行模型
struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let type: TerminalLineType
}

enum TerminalLineType {
    case command
    case output
    case error
    case info
    case highlight
}

// MARK: - Preview
struct TerminalView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}