import SwiftUI

// MARK: - Smali 语法高亮器
struct SmaliSyntaxHighlighter {
    static func highlight(_ code: String) -> [AttributedString] {
        let lines = code.components(separatedBy: "\n")
        return lines.map { highlightLine($0) }
    }

    static func highlightLine(_ line: String) -> AttributedString {
        var result = AttributedString(line)
        result.font = .system(size: 13, design: .monospaced)
        result.foregroundColor = .primary

        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // 注释（# 开头）用绿色
        if trimmed.hasPrefix("#") {
            result.foregroundColor = .green
            return result
        }

        // 关键字匹配规则：按优先级从高到低

        // .method / .end method → 蓝色
        if trimmed.hasPrefix(".method") {
            result.foregroundColor = .blue
            return result
        }
        if trimmed == ".end method" {
            result.foregroundColor = .blue
            return result
        }

        // .field / .end field → 绿色
        if trimmed.hasPrefix(".field") {
            result.foregroundColor = .green
            return result
        }
        if trimmed == ".end field" {
            result.foregroundColor = .green
            return result
        }

        // .class, .super, .implements → 紫色
        if trimmed.hasPrefix(".class") {
            result.foregroundColor = .purple
            return result
        }
        if trimmed.hasPrefix(".super") {
            result.foregroundColor = .purple
            return result
        }
        if trimmed.hasPrefix(".implements") {
            result.foregroundColor = .purple
            return result
        }

        // .line, .local, .param → 灰色
        if trimmed.hasPrefix(".line") {
            result.foregroundColor = .gray
            return result
        }
        if trimmed.hasPrefix(".local") {
            result.foregroundColor = .gray
            return result
        }
        if trimmed.hasPrefix(".param") {
            result.foregroundColor = .gray
            return result
        }

        // .annotation, .prologue, .registers, .locals → 灰色
        if trimmed.hasPrefix(".annotation") || trimmed.hasPrefix(".prologue")
            || trimmed.hasPrefix(".registers") || trimmed.hasPrefix(".locals") {
            result.foregroundColor = .gray
            return result
        }

        // invoke- 指令 → 橙色
        if trimmed.hasPrefix("invoke-") {
            result.foregroundColor = .orange
            return result
        }

        // const- 指令 → 黄色
        if trimmed.hasPrefix("const-") || trimmed.hasPrefix("const/") {
            result.foregroundColor = .yellow
            return result
        }

        // move-, return-, if-, goto-, new-, throw 等指令 → 青色
        if trimmed.hasPrefix("move-") || trimmed.hasPrefix("return")
            || trimmed.hasPrefix("if-") || trimmed.hasPrefix("goto")
            || trimmed.hasPrefix("new-") || trimmed.hasPrefix("throw")
            || trimmed.hasPrefix("check-cast") || trimmed.hasPrefix("aget-")
            || trimmed.hasPrefix("aput-") || trimmed.hasPrefix("iget-")
            || trimmed.hasPrefix("iput-") || trimmed.hasPrefix("sget-")
            || trimmed.hasPrefix("sput-") || trimmed.hasPrefix("add-")
            || trimmed.hasPrefix("sub-") || trimmed.hasPrefix("mul-")
            || trimmed.hasPrefix("div-") || trimmed.hasPrefix("rem-")
            || trimmed.hasPrefix("and-") || trimmed.hasPrefix("or-")
            || trimmed.hasPrefix("xor-") || trimmed.hasPrefix("shl-")
            || trimmed.hasPrefix("shr-") || trimmed.hasPrefix("ushr-")
            || trimmed.hasPrefix("cmp") || trimmed.hasPrefix("aget-")
            || trimmed.hasPrefix("aput-") || trimmed.hasPrefix("array-length")
            || trimmed.hasPrefix("fill-array-data") || trimmed.hasPrefix("packed-switch")
            || trimmed.hasPrefix("sparse-switch") || trimmed.hasPrefix("monitor-")
            || trimmed.hasPrefix("filled-new-array") || trimmed.hasPrefix("nop") {
            result.foregroundColor = .cyan
            return result
        }

        // # 开头的注释行
        if trimmed.contains("#") {
            // 字符串中含有注释符号时优先判断注释位置
            // 简化处理：整体保持默认色
        }

        return result
    }
}

// MARK: - Smali 代码查看器
struct SmaliViewerView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSmaliFile: String?
    @State private var searchText: String = ""
    @State private var fileContent: String = ""
    @State private var highlightedLines: [AttributedString] = []
    @State private var lineCount: Int = 0
    @State private var fileSize: Int64 = 0

    var filteredSmaliFiles: [String] {
        if searchText.isEmpty {
            return appState.smaliFiles
        }
        return appState.smaliFiles.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        GlassSplitView(
            left: smaliFileList,
            right: codeViewPanel
        )
        .navigationTitle("Smali 代码")
    }

    // MARK: - 左侧：Smali 文件列表
    private var smaliFileList: some View {
        VStack(spacing: 0) {
            GlassSectionHeader(title: "Smali 文件", icon: "chevron.left.forwardslash.chevron.right")

            GlassSearchBar(text: $searchText, placeholder: "搜索 Smali 文件...")
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

            if filteredSmaliFiles.isEmpty {
                emptyFileList
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredSmaliFiles, id: \.self) { file in
                            GlassFileTreeRow(
                                name: fileNameOnly(from: file),
                                icon: "doc.text",
                                isSelected: selectedSmaliFile == file,
                                level: 0,
                                action: {
                                    selectedSmaliFile = file
                                    loadSmaliFile(file)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
            }

            // 文件统计
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("共 \(appState.smaliFiles.count) 个 Smali 文件")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                if selectedSmaliFile != nil {
                    HStack {
                        Image(systemName: "text.alignleft")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(lineCount) 行")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(formatFileSize(fileSize))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 右侧：代码查看面板
    private var codeViewPanel: some View {
        VStack(spacing: 0) {
            if let selectedFile = selectedSmaliFile {
                // 文件标题
                fileTitleView(selectedFile)

                // 代码区域
                codeScrollView
            } else {
                emptySelectionView
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 文件标题
    private func fileTitleView(_ file: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.title2)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(fileNameOnly(from: file))
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Smali 反编译代码")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            GlassBadge(text: "\(lineCount) 行", color: .blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - 代码滚动视图
    private var codeScrollView: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                // 行号
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(1...max(lineCount, 1), id: \.self) { i in
                        Text("\(i)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .frame(minWidth: 40, alignment: .trailing)
                            .padding(.trailing, 8)
                            .padding(.vertical, 1)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                )

                Rectangle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 1)

                // 高亮代码
                if highlightedLines.isEmpty {
                    Text(fileContent)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(highlightedLines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 1)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Spacer(minLength: 0)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.08), lineWidth: 0.5)
        )
        .padding(12)
    }

    // MARK: - 空状态
    private var emptyFileList: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("无 Smali 文件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("请导入包含 Smali 的 APK 文件")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptySelectionView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("选择 Smali 文件")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("从左侧列表中选择一个 Smali 文件查看反编译代码")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers
    private func fileNameOnly(from path: String) -> String {
        URL(fileURLWithPath: path).lastPathComponent
    }

    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    private func loadSmaliFile(_ filePath: String) {
        // 读取文件内容
        if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
            fileContent = content
            lineCount = content.components(separatedBy: "\n").count
            highlightedLines = SmaliSyntaxHighlighter.highlight(content)

            // 获取文件大小
            if let attrs = try? FileManager.default.attributesOfItem(atPath: filePath) {
                fileSize = attrs[.size] as? Int64 ?? 0
            }
        } else {
            fileContent = "// 无法读取文件: \(filePath)"
            lineCount = 1
            highlightedLines = []
            fileSize = 0
        }
    }
}

// MARK: - Preview
struct SmaliViewerView_Previews: PreviewProvider {
    static var previews: some View {
        SmaliViewerView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}