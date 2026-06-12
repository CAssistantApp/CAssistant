import SwiftUI

// MARK: - File Preview View
struct FilePreviewView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedFile: FileEntry?
    @State private var fileContent: String = ""
    @State private var isLoadingContent = false
    @State private var hexContent: [UInt8] = []
    @State private var imageData: Data?

    // MARK: - Computed: File Tree
    private var fileTree: [FileEntry] {
        buildFileTree(from: appState.files)
    }

    private var filteredTree: [FileEntry] {
        if searchText.isEmpty {
            return fileTree
        }
        return filterTreeEntries(fileTree, matching: searchText)
    }

    // MARK: - Body
    var body: some View {
        if appState.files.isEmpty {
            emptyStateView
        } else {
            GlassSplitView(left: fileTreePanel, right: previewPanel)
        }
    }

    // MARK: - Left: File Tree Panel
    private var fileTreePanel: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                GlassSectionHeader(title: "文件树", icon: "folder")
                Spacer()
                Text("\(appState.files.count) 个文件")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Search
            GlassSearchBar(text: $searchText, placeholder: "搜索文件...")
                .padding(.horizontal, 8)
                .padding(.bottom, 8)

            // Tree List
            if filteredTree.isEmpty {
                VStack {
                    Spacer()
                    Text("未找到匹配的文件")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredTree) { entry in
                            fileTreeNode(entry: entry, level: 0)
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
        }
        .frame(minWidth: 220, idealWidth: 260, maxWidth: 320)
        .background(.ultraThinMaterial)
    }

    // MARK: - Recursive File Tree Node
    @ViewBuilder
    private func fileTreeNode(entry: FileEntry, level: Int) -> some View {
        if entry.isDirectory {
            DisclosureGroup {
                ForEach(entry.children) { child in
                    AnyView(fileTreeNode(entry: child, level: level + 1))
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.accentColor)
                        .frame(width: 16)

                    Text(entry.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    if !entry.children.isEmpty {
                        Text("\(entry.children.count)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .padding(.leading, CGFloat(level) * 14)
                .contentShape(Rectangle())
            }
        } else {
            Button {
                selectFile(entry)
            } label: {
                HStack(spacing: 6) {
                    let icon = fileIcon(for: entry.name)
                    let color = fileColor(for: entry.name)

                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundColor(color)
                        .frame(width: 16)

                    Text(entry.name)
                        .font(.system(size: 13))
                        .foregroundColor(selectedFile?.id == entry.id ? .accentColor : .primary)
                        .lineLimit(1)

                    Spacer()

                    if entry.size > 0 {
                        Text(formatFileSize(entry.size))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .padding(.leading, CGFloat(level) * 14)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(selectedFile?.id == entry.id ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(Color.clear))
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Right: Preview Panel
    private var previewPanel: some View {
        VStack(spacing: 0) {
            if let file = selectedFile {
                fileInfoHeader(file)
                fileContentPreview
            } else {
                noSelectionView
            }
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - File Info Header
    private func fileInfoHeader(_ file: FileEntry) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                let icon = fileIcon(for: file.name)
                let color = fileColor(for: file.name)

                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text(file.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(file.path)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer()

                GlassBadge(text: fileTypeLabel(file.name), color: color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            // Stats Row
            HStack(spacing: 16) {
                statItem(icon: "doc", label: "大小", value: formatFileSize(file.size))
                statItem(icon: "calendar", label: "修改时间", value: "-")
                statItem(icon: "barcode", label: "CRC32", value: file.crc32.isEmpty ? "-" : file.crc32)
                if !file.compressionMethod.isEmpty {
                    statItem(icon: "rectangle.compress.vertical", label: "压缩", value: file.compressionMethod)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()
                .background(.white.opacity(0.1))
        }
        .background(.thinMaterial)
    }

    private func statItem(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - File Content Preview
    @ViewBuilder
    private var fileContentPreview: some View {
        if isLoadingContent {
            Spacer()
            ProgressView("加载中...")
                .foregroundStyle(.secondary)
            Spacer()
        } else if let file = selectedFile {
            let ext = (file.name as NSString).pathExtension.lowercased()

            switch ext {
            case "smali":
                syntaxHighlightPreview(content: fileContent, language: "smali")
            case "xml":
                syntaxHighlightPreview(content: fileContent, language: "xml")
            case "json":
                syntaxHighlightPreview(content: fileContent, language: "json")
            case "txt", "cfg", "pro", "mf", "sf", "yaml", "yml":
                plainTextPreview(content: fileContent)
            case "png", "jpg", "jpeg", "webp", "gif", "bmp":
                imagePreviewView
            case "dex":
                hexPreviewView
            default:
                if !fileContent.isEmpty {
                    plainTextPreview(content: fileContent)
                } else if !hexContent.isEmpty {
                    hexPreviewView
                } else {
                    unsupportedPreviewView(file)
                }
            }
        }
    }

    // MARK: - Plain Text Preview
    private func plainTextPreview(content: String) -> some View {
        ScrollView([.horizontal, .vertical]) {
            Text(content)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Syntax Highlight Preview
    private func syntaxHighlightPreview(content: String, language: String) -> some View {
        ScrollView([.horizontal, .vertical]) {
            Text(highlightAttributedString(for: content, language: language))
                .font(.system(size: 13, design: .monospaced))
                .textSelection(.enabled)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Image Preview
    private var imagePreviewView: some View {
        VStack {
            if let data = imageData, let uiImage = UIImage(data: data) {
                ScrollView([.horizontal, .vertical]) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(16)
                }
                .overlay(alignment: .bottomTrailing) {
                    Text("\(Int(uiImage.size.width)) x \(Int(uiImage.size.height)) px")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(12)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("无法加载图片")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Hex Preview
    private var hexPreviewView: some View {
        ScrollView([.vertical]) {
            if hexContent.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "number.square")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("无二进制数据")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<hexRowCount(), id: \.self) { rowIndex in
                        hexRow(rowIndex: rowIndex)
                    }
                }
                .padding(16)
            }
        }
    }

    private func hexRowCount() -> Int {
        (hexContent.count + 15) / 16
    }

    private func hexRow(rowIndex: Int) -> some View {
        let start = rowIndex * 16
        let end = min(start + 16, hexContent.count)
        let chunk = Array(hexContent[start..<end])

        return HStack(spacing: 12) {
            // Offset
            Text(String(format: "%08X", start))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.tertiary)

            // Hex bytes
            HStack(spacing: 4) {
                ForEach(0..<16, id: \.self) { i in
                    if i < chunk.count {
                        Text(String(format: "%02X", chunk[i]))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.primary)
                    } else {
                        Text("  ")
                            .font(.system(size: 11, design: .monospaced))
                    }
                }
            }

            // ASCII
            HStack(spacing: 0) {
                ForEach(0..<16, id: \.self) { i in
                    if i < chunk.count {
                        let byte = chunk[i]
                        if byte >= 32 && byte < 127 {
                            Text(String(UnicodeScalar(byte)))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.green)
                        } else {
                            Text(".")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        Text(" ")
                            .font(.system(size: 11, design: .monospaced))
                    }
                }
            }
        }
    }

    // MARK: - Unsupported Preview
    private func unsupportedPreviewView(_ file: FileEntry) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "doc.questionmark")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)

            Text("不支持预览此文件类型")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(file.name)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.tertiary)

            Text("该文件类型暂无预览支持，可尝试以十六进制方式查看")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - No Selection
    private var noSelectionView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)

            Text("请在左侧选择文件")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("支持预览 Smali、XML、JSON、文本、图片等格式")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 80)

            Image(systemName: "folder")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("暂无文件数据")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text("请先导入并分析 APK 文件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - File Selection
    private func selectFile(_ entry: FileEntry) {
        selectedFile = entry
        isLoadingContent = true
        fileContent = ""
        hexContent = []
        imageData = nil

        let ext = (entry.name as NSString).pathExtension.lowercased()
        let filePath: String

        if !appState.extractedPath.isEmpty {
            filePath = appState.extractedPath + "/" + entry.path
        } else {
            filePath = entry.path
        }

        // Check if file exists on disk and load it
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            isLoadingContent = false
            return
        }

        switch ext {
        case "png", "jpg", "jpeg", "webp", "gif", "bmp":
            DispatchQueue.global(qos: .userInitiated).async {
                let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
                DispatchQueue.main.async {
                    self.imageData = data
                    self.isLoadingContent = false
                }
            }

        case "smali", "xml", "json", "txt", "cfg", "pro", "mf", "sf", "yaml", "yml":
            DispatchQueue.global(qos: .userInitiated).async {
                if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.fileContent = content
                        self.isLoadingContent = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoadingContent = false
                    }
                }
            }

        default:
            // Try as text first, fall back to hex
            DispatchQueue.global(qos: .userInitiated).async {
                if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.fileContent = content
                        self.isLoadingContent = false
                    }
                } else if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                    let bytes = [UInt8](data.prefix(8192))
                    DispatchQueue.main.async {
                        self.hexContent = bytes
                        self.isLoadingContent = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoadingContent = false
                    }
                }
            }
        }
    }

    // MARK: - File Tree Building (from flat list)
    private func buildFileTree(from flatFiles: [FileEntry]) -> [FileEntry] {
        var rootEntries: [FileEntry] = []
        var pathMap: [String: FileEntry] = [:]

        for file in flatFiles.sorted(by: { $0.path < $1.path }) {
            let components = file.path.components(separatedBy: "/").filter { !$0.isEmpty }
            var currentPath = ""

            for (index, component) in components.enumerated() {
                let isLast = index == components.count - 1
                let parentPath = currentPath
                currentPath = currentPath.isEmpty ? component : "\(currentPath)/\(component)"

                if pathMap[currentPath] != nil {
                    continue
                }

                let entry: FileEntry
                if isLast {
                    entry = file
                } else {
                    entry = FileEntry(
                        name: component,
                        path: currentPath,
                        size: 0,
                        isDirectory: true
                    )
                }

                pathMap[currentPath] = entry

                if parentPath.isEmpty {
                    rootEntries.append(entry)
                } else if var parent = pathMap[parentPath] {
                    parent.children.append(entry)
                    pathMap[parentPath] = parent
                }
            }
        }

        return rootEntries
    }

    // MARK: - Tree Filtering
    private func filterTreeEntries(_ entries: [FileEntry], matching query: String) -> [FileEntry] {
        entries.compactMap { entry in
            if entry.name.localizedCaseInsensitiveContains(query) {
                return entry
            }
            if entry.isDirectory {
                let filteredChildren = filterTreeEntries(entry.children, matching: query)
                if !filteredChildren.isEmpty {
                    var copy = entry
                    copy.children = filteredChildren
                    return copy
                }
            }
            return nil
        }
    }

    // MARK: - File Type Detection
    private func fileTypeLabel(_ filename: String) -> String {
        let ext = (filename as NSString).pathExtension.uppercased()
        return ext.isEmpty ? "FILE" : ext
    }

    // MARK: - File Icons
    private func fileIcon(for name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "dex": return "cube"
        case "smali": return "chevron.left.forwardslash.chevron.right"
        case "so": return "square.stack.3d.up"
        case "xml": return "chevron.left.slash.chevron.right"
        case "arsc": return "tablecells"
        case "png", "jpg", "jpeg", "webp", "gif", "bmp": return "photo"
        case "ttf", "otf": return "textformat"
        case "json": return "curlybraces"
        case "pro", "cfg": return "gearshape"
        case "rsa", "dsa", "ec": return "signature"
        case "mf", "sf": return "doc.text"
        case "txt": return "doc.plaintext"
        case "jar": return "shippingbox"
        case "zip": return "archivebox"
        case "yaml", "yml": return "list.bullet"
        default: return "doc"
        }
    }

    private func fileColor(for name: String) -> Color {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "dex": return .orange
        case "smali": return .purple
        case "so": return .green
        case "xml": return .blue
        case "arsc": return .cyan
        case "png", "jpg", "jpeg", "webp", "gif", "bmp": return .pink
        case "json": return .yellow
        case "rsa", "dsa", "ec": return .red
        default: return .secondary
        }
    }

    // MARK: - Format Helpers
    private func formatFileSize(_ size: Int64) -> String {
        if size < 1024 { return "\(size) B" }
        if size < 1024 * 1024 { return String(format: "%.1f KB", Double(size) / 1024) }
        return String(format: "%.1f MB", Double(size) / (1024 * 1024))
    }

    // MARK: - Syntax Highlighting
    private func highlightAttributedString(for text: String, language: String) -> AttributedString {
        switch language {
        case "smali": return highlightSmali(text)
        case "xml": return highlightXML(text)
        case "json": return highlightJSON(text)
        default: return AttributedString(text)
        }
    }

    private func highlightSmali(_ text: String) -> AttributedString {
        let lines = text.components(separatedBy: "\n")
        var result = AttributedString()

        for (index, line) in lines.enumerated() {
            if index > 0 {
                result.append(AttributedString("\n"))
            }

            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let leadingSpaces = line.prefix(line.count - line.drop(while: { $0 == " " || $0 == "\t" }).count)
            var leadAttr = AttributedString(String(leadingSpaces))
            leadAttr.foregroundColor = .primary
            result.append(leadAttr)

            if trimmedLine.hasPrefix("#") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .green
                result.append(attr)
            } else if trimmedLine.hasPrefix(".class") || trimmedLine.hasPrefix(".super") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .purple
                result.append(attr)
            } else if trimmedLine.hasPrefix(".method") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .blue
                result.append(attr)
            } else if trimmedLine.hasPrefix(".field") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .cyan
                result.append(attr)
            } else if trimmedLine.hasPrefix("invoke-") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .orange
                result.append(attr)
            } else if trimmedLine.hasPrefix("const") || trimmedLine.hasPrefix("const-") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .yellow
                result.append(attr)
            } else if trimmedLine.hasPrefix("if-") || trimmedLine.hasPrefix("goto") || trimmedLine.hasPrefix("return") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .pink
                result.append(attr)
            } else if trimmedLine.hasPrefix(".end") || trimmedLine.hasPrefix(".line") ||
                      trimmedLine.hasPrefix(".local") || trimmedLine.hasPrefix(".param") ||
                      trimmedLine.hasPrefix(".prologue") || trimmedLine.hasPrefix(".annotation") ||
                      trimmedLine.hasPrefix(".registers") || trimmedLine.hasPrefix(".locals") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .gray
                result.append(attr)
            } else if trimmedLine.hasPrefix("move") || trimmedLine.hasPrefix("move-") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .mint
                result.append(attr)
            } else if trimmedLine.hasPrefix("new-") || trimmedLine.hasPrefix("iget") ||
                      trimmedLine.hasPrefix("iput") || trimmedLine.hasPrefix("sget") ||
                      trimmedLine.hasPrefix("sput") {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .teal
                result.append(attr)
            } else {
                var attr = AttributedString(trimmedLine)
                attr.foregroundColor = .primary
                result.append(attr)
            }
        }
        return result
    }

    private func highlightXML(_ text: String) -> AttributedString {
        var result = AttributedString()

        let pattern = "(<\\/?[\\w:.\\-]+)|([\\w:.\\-]+=\"[^\"]*\")|(>[^<]+<)|(<!--[\\s\\S]*?-->)"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return AttributedString(text)
        }

        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        var lastEnd = 0
        for match in matches {
            if match.range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                var beforeStr = AttributedString(nsString.substring(with: beforeRange))
                beforeStr.foregroundColor = .primary
                result.append(beforeStr)
            }

            let matchText = nsString.substring(with: match.range)

            if match.range(at: 1).location != NSNotFound {
                var tagAttr = AttributedString(matchText)
                tagAttr.foregroundColor = .purple
                result.append(tagAttr)
            } else if match.range(at: 2).location != NSNotFound {
                var attrText = AttributedString(matchText)
                attrText.foregroundColor = .cyan
                result.append(attrText)
            } else if match.range(at: 3).location != NSNotFound {
                let content = String(matchText.dropFirst().dropLast())
                var contentAttr = AttributedString(content)
                contentAttr.foregroundColor = .orange
                result.append(contentAttr)
            } else if match.range(at: 4).location != NSNotFound {
                var commentAttr = AttributedString(matchText)
                commentAttr.foregroundColor = .green
                result.append(commentAttr)
            }

            lastEnd = match.range.location + match.range.length
        }

        if lastEnd < nsString.length {
            let remainingRange = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            var remaining = AttributedString(nsString.substring(with: remainingRange))
            remaining.foregroundColor = .primary
            result.append(remaining)
        }

        return result
    }

    private func highlightJSON(_ text: String) -> AttributedString {
        var result = AttributedString()

        let pattern = "(\"[^\"]*\"\\s*:)|(\"[^\"]*\")|(\\b-?\\d+\\.?\\d*\\b)|(true|false|null)"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return AttributedString(text)
        }

        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        var lastEnd = 0
        for match in matches {
            if match.range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                var beforeStr = AttributedString(nsString.substring(with: beforeRange))
                beforeStr.foregroundColor = .primary
                result.append(beforeStr)
            }

            let matchText = nsString.substring(with: match.range)

            if match.range(at: 1).location != NSNotFound {
                var keyAttr = AttributedString(matchText)
                keyAttr.foregroundColor = .blue
                result.append(keyAttr)
            } else if match.range(at: 2).location != NSNotFound {
                var strAttr = AttributedString(matchText)
                strAttr.foregroundColor = .green
                result.append(strAttr)
            } else if match.range(at: 3).location != NSNotFound {
                var numAttr = AttributedString(matchText)
                numAttr.foregroundColor = .orange
                result.append(numAttr)
            } else if match.range(at: 4).location != NSNotFound {
                var boolAttr = AttributedString(matchText)
                boolAttr.foregroundColor = .pink
                result.append(boolAttr)
            }

            lastEnd = match.range.location + match.range.length
        }

        if lastEnd < nsString.length {
            let remainingRange = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            var remaining = AttributedString(nsString.substring(with: remainingRange))
            remaining.foregroundColor = .primary
            result.append(remaining)
        }

        return result
    }
}

// MARK: - Preview
struct FilePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        FilePreviewView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}