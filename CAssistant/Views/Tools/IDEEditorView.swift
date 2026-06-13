import SwiftUI

// MARK: - IDE Editor View
struct IDEEditorView: View {
    @EnvironmentObject var appState: AppState
    @State private var codeContent = ""
    @State private var currentFile = ""
    @State private var showLineNumbers = true
    @State private var showFindReplace = false
    @State private var showHighlightedPreview = false
    @State private var findText = ""
    @State private var replaceText = ""
    @State private var cursorLine: Int = 1
    @State private var cursorColumn: Int = 1

    // MARK: - Computed Properties
    private var detectedLanguage: String {
        let ext = (currentFile as NSString).pathExtension.lowercased()
        switch ext {
        case "smali": return "smali"
        case "java": return "java"
        case "xml": return "xml"
        case "json": return "json"
        case "txt": return "txt"
        default: return "smali"
        }
    }

    private var languageLabel: String {
        switch detectedLanguage {
        case "smali": return "Smali"
        case "java": return "Java"
        case "xml": return "XML"
        case "json": return "JSON"
        case "txt": return "Text"
        default: return "Smali"
        }
    }

    private var languageColor: Color {
        switch detectedLanguage {
        case "smali": return .purple
        case "java": return .orange
        case "xml": return .blue
        case "json": return .yellow
        case "txt": return .secondary
        default: return .purple
        }
    }

    private var totalLines: Int {
        codeContent.components(separatedBy: "\n").count
    }

    private var fileSizeString: String {
        let data = codeContent.data(using: .utf8)
        let size = data?.count ?? 0
        if size < 1024 { return "\(size) B" }
        if size < 1024 * 1024 { return String(format: "%.1f KB", Double(size) / 1024) }
        return String(format: "%.1f MB", Double(size) / (1024 * 1024))
    }

    private var fileEncoding: String {
        "UTF-8"
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            toolbarView

            if showHighlightedPreview {
                syntaxHighlightedPreview
            } else {
                GlassCodeEditor(text: $codeContent, language: detectedLanguage)
                    .onChange(of: codeContent) { _, newValue in
                        updateCursorPosition()
                    }
            }

            statusBarView

            if showFindReplace {
                findReplacePanel
            }
        }
    }

    // MARK: - Toolbar
    private var toolbarView: some View {
        HStack(spacing: 8) {
            GlassButton(title: "打开", icon: "folder", color: .accentColor) {
                openFile()
            }

            GlassButton(title: "保存", icon: "square.and.arrow.down", color: .green) {
                saveFile()
            }

            GlassButton(
                title: showFindReplace ? "关闭查找" : "查找替换",
                icon: "magnifyingglass",
                color: showFindReplace ? .orange : .accentColor
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showFindReplace.toggle()
                }
            }

            Spacer()

            GlassBadge(text: languageLabel, color: languageColor)

            Button {
                showHighlightedPreview.toggle()
            } label: {
                Image(systemName: showHighlightedPreview ? "pencil" : "eye")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
            )
            .foregroundColor(.accentColor)

            Button {
                showLineNumbers.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: showLineNumbers ? "list.number" : "list.bullet")
                        .font(.system(size: 12))
                    Text("行号")
                        .font(.system(size: 12))
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(showLineNumbers ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.thinMaterial))
            )
            .foregroundColor(showLineNumbers ? .accentColor : .secondary)

            if !currentFile.isEmpty {
                Text(currentFile.components(separatedBy: "/").last ?? currentFile)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Syntax Highlighted Preview
    private var syntaxHighlightedPreview: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                if showLineNumbers {
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(1...totalLines, id: \.self) { i in
                            Text("\(i)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .frame(minWidth: 32, alignment: .trailing)
                                .padding(.trailing, 8)
                                .padding(.vertical, 1)
                        }
                    }
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                }

                Text(highlightedAttributedString(for: codeContent, language: detectedLanguage))
                    .font(.system(size: 13, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
    }

    // MARK: - Status Bar
    private var statusBarView: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.and.down.text.horizontal")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text("行 \(cursorLine)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "arrow.left.and.right.text.vertical")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text("列 \(cursorColumn)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "textformat")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text(fileEncoding)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "doc")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text(fileSizeString)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text("\(totalLines) 行")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Find / Replace Panel
    private var findReplacePanel: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                GlassSearchBar(text: $findText, placeholder: "查找...")
                    .frame(maxWidth: .infinity)

                TextField("替换为...", text: $replaceText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.thinMaterial)
                    )
                    .frame(maxWidth: .infinity)

                GlassButton(title: "替换", icon: "arrow.triangle.swap", color: .orange) {
                    performReplace()
                }

                GlassButton(title: "全部", icon: "text.line.first.and.arrowtriangle.forward", color: .orange) {
                    performReplaceAll()
                }
            }

            if !findText.isEmpty {
                let occurrences = findOccurrencesCount()
                Text(occurrences > 0 ? "找到 \(occurrences) 处匹配" : "未找到匹配")
                    .font(.system(size: 11))
                    .foregroundColor(occurrences > 0 ? .secondary : .red)
                    .padding(.horizontal, 4)
            }
        }
        .padding(12)
        .background(
            Rectangle()
                .fill(.thinMaterial)
        )
    }

    // MARK: - Syntax Highlighting
    private func highlightedAttributedString(for text: String, language: String) -> AttributedString {
        switch language {
        case "smali": return highlightSmali(text)
        case "xml": return highlightXML(text)
        case "json": return highlightJSON(text)
        case "java": return highlightJava(text)
        default: return AttributedString(text)
        }
    }

    // MARK: - Smali Syntax Highlighting
    private func highlightSmali(_ text: String) -> AttributedString {
        let lines = text.components(separatedBy: "\n")
        var result = AttributedString()

        for (index, line) in lines.enumerated() {
            if index > 0 {
                result.append(AttributedString("\n"))
            }

            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let leadingSpaces = line.prefix(line.count - line.drop(while: { $0 == " " || $0 == "\t" }).count)
            var lineAttr = AttributedString(String(leadingSpaces))
            lineAttr.foregroundColor = .primary
            result.append(lineAttr)

            if trimmedLine.hasPrefix("#") {
                var comment = AttributedString(trimmedLine)
                comment.foregroundColor = .green
                result.append(comment)
            } else if trimmedLine.hasPrefix(".class") {
                var classToken = AttributedString(trimmedLine)
                classToken.foregroundColor = .purple
                result.append(classToken)
            } else if trimmedLine.hasPrefix(".super") {
                var superToken = AttributedString(trimmedLine)
                superToken.foregroundColor = .purple
                result.append(superToken)
            } else if trimmedLine.hasPrefix(".field") {
                var fieldToken = AttributedString(trimmedLine)
                fieldToken.foregroundColor = .cyan
                result.append(fieldToken)
            } else if trimmedLine.hasPrefix(".method") {
                var methodToken = AttributedString(trimmedLine)
                methodToken.foregroundColor = .blue
                result.append(methodToken)
            } else if trimmedLine.hasPrefix(".end method") || trimmedLine.hasPrefix(".end field") {
                var endToken = AttributedString(trimmedLine)
                endToken.foregroundColor = .gray
                result.append(endToken)
            } else if trimmedLine.hasPrefix("invoke-") {
                var invokeToken = AttributedString(trimmedLine)
                invokeToken.foregroundColor = .orange
                result.append(invokeToken)
            } else if trimmedLine.hasPrefix("const") || trimmedLine.hasPrefix("const-") {
                var constToken = AttributedString(trimmedLine)
                constToken.foregroundColor = .yellow
                result.append(constToken)
            } else if trimmedLine.hasPrefix("move") || trimmedLine.hasPrefix("move-") {
                var moveToken = AttributedString(trimmedLine)
                moveToken.foregroundColor = .mint
                result.append(moveToken)
            } else if trimmedLine.hasPrefix("if-") || trimmedLine.hasPrefix("goto") || trimmedLine.hasPrefix("return") {
                var flowToken = AttributedString(trimmedLine)
                flowToken.foregroundColor = .pink
                result.append(flowToken)
            } else if trimmedLine.hasPrefix("new-") || trimmedLine.hasPrefix("iget") || trimmedLine.hasPrefix("iput") ||
                      trimmedLine.hasPrefix("sget") || trimmedLine.hasPrefix("sput") {
                var token = AttributedString(trimmedLine)
                token.foregroundColor = .teal
                result.append(token)
            } else if trimmedLine.hasPrefix(".line") || trimmedLine.hasPrefix(".local") ||
                      trimmedLine.hasPrefix(".param") || trimmedLine.hasPrefix(".prologue") ||
                      trimmedLine.hasPrefix(".annotation") || trimmedLine.hasPrefix(".end annotation") ||
                      trimmedLine.hasPrefix(".registers") || trimmedLine.hasPrefix(".locals") {
                var metaToken = AttributedString(trimmedLine)
                metaToken.foregroundColor = .gray
                result.append(metaToken)
            } else {
                var defaultText = AttributedString(trimmedLine)
                defaultText.foregroundColor = .primary
                result.append(defaultText)
            }
        }

        return result
    }

    // MARK: - XML Syntax Highlighting
    private func highlightXML(_ text: String) -> AttributedString {
        var result = AttributedString()

        // Simple regex-based highlighting for XML
        let pattern = "(<\\/?[\\w:.\\-]+)|([\\w:.\\-]+=\"[^\"]*\")|(>[^<]+<)|(<!--[\\s\\S]*?-->)"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return AttributedString(text)
        }

        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        var lastEnd = 0
        for match in matches {
            // Append text before this match
            if match.range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                var beforeStr = AttributedString(nsString.substring(with: beforeRange))
                beforeStr.foregroundColor = .primary
                result.append(beforeStr)
            }

            let matchText = nsString.substring(with: match.range)

            if match.range(at: 1).location != NSNotFound {
                // Tag: <tag> or </tag>
                var tagAttr = AttributedString(matchText)
                tagAttr.foregroundColor = .purple
                result.append(tagAttr)
            } else if match.range(at: 2).location != NSNotFound {
                // Attribute: attr="value"
                var attrText = AttributedString(matchText)
                attrText.foregroundColor = .cyan
                result.append(attrText)
            } else if match.range(at: 3).location != NSNotFound {
                // Text content
                let content = String(matchText.dropFirst().dropLast())
                var contentAttr = AttributedString(content)
                contentAttr.foregroundColor = .orange
                result.append(contentAttr)
            } else if match.range(at: 4).location != NSNotFound {
                // Comment
                var commentAttr = AttributedString(matchText)
                commentAttr.foregroundColor = .green
                result.append(commentAttr)
            }

            lastEnd = match.range.location + match.range.length
        }

        // Append remaining text
        if lastEnd < nsString.length {
            let remainingRange = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            var remaining = AttributedString(nsString.substring(with: remainingRange))
            remaining.foregroundColor = .primary
            result.append(remaining)
        }

        return result
    }

    // MARK: - JSON Syntax Highlighting
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
                // Key: "key":
                var keyAttr = AttributedString(matchText)
                keyAttr.foregroundColor = .blue
                result.append(keyAttr)
            } else if match.range(at: 2).location != NSNotFound {
                // String value
                var strAttr = AttributedString(matchText)
                strAttr.foregroundColor = .green
                result.append(strAttr)
            } else if match.range(at: 3).location != NSNotFound {
                // Number
                var numAttr = AttributedString(matchText)
                numAttr.foregroundColor = .orange
                result.append(numAttr)
            } else if match.range(at: 4).location != NSNotFound {
                // Boolean/null
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

    // MARK: - Java Syntax Highlighting
    private func highlightJava(_ text: String) -> AttributedString {
        var result = AttributedString()

        let keywords = ["public", "private", "protected", "static", "final", "class", "interface",
                        "extends", "implements", "void", "int", "long", "float", "double", "boolean",
                        "char", "byte", "short", "return", "if", "else", "for", "while", "do",
                        "switch", "case", "break", "continue", "new", "try", "catch", "finally",
                        "throw", "throws", "import", "package", "this", "super", "null", "true", "false"]

        let keywordPattern = "\\b(" + keywords.joined(separator: "|") + ")\\b"
        let pattern = "(//[^\n]*)|(\\/\\*[\\s\\S]*?\\*\\/)|(\"[^\"]*\")|" + keywordPattern

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

            if match.range(at: 1).location != NSNotFound || match.range(at: 2).location != NSNotFound {
                // Comments
                var commentAttr = AttributedString(matchText)
                commentAttr.foregroundColor = .green
                result.append(commentAttr)
            } else if match.range(at: 3).location != NSNotFound {
                // Strings
                var strAttr = AttributedString(matchText)
                strAttr.foregroundColor = .orange
                result.append(strAttr)
            } else if match.range(at: 4).location != NSNotFound {
                // Keywords
                var kwAttr = AttributedString(matchText)
                kwAttr.foregroundColor = .purple
                result.append(kwAttr)
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

    // MARK: - Actions
    private func openFile() {
        // Open file from appState smaliFiles
        if let firstFile = appState.smaliFiles.first {
            currentFile = firstFile
            if let content = try? String(contentsOfFile: firstFile, encoding: .utf8) {
                codeContent = content
            }
        }
    }

    private func saveFile() {
        guard !currentFile.isEmpty, !codeContent.isEmpty else { return }
        try? codeContent.write(toFile: currentFile, atomically: true, encoding: .utf8)
    }

    private func updateCursorPosition() {
        let lines = codeContent.components(separatedBy: "\n")
        cursorLine = max(1, lines.count)
        cursorColumn = max(1, (lines.last?.count ?? 0) + 1)
    }

    private func performReplace() {
        guard !findText.isEmpty else { return }
        codeContent = codeContent.replacingOccurrences(of: findText, with: replaceText)
    }

    private func performReplaceAll() {
        guard !findText.isEmpty else { return }
        codeContent = codeContent.replacingOccurrences(of: findText, with: replaceText)
    }

    private func findOccurrencesCount() -> Int {
        guard !findText.isEmpty else { return 0 }
        var count = 0
        var searchRange = codeContent.startIndex..<codeContent.endIndex
        while let range = codeContent.range(of: findText, options: .caseInsensitive, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<codeContent.endIndex
        }
        return count
    }
}

// MARK: - Preview
struct IDEEditorView_Previews: PreviewProvider {
    static var previews: some View {
        IDEEditorView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}