import SwiftUI

// MARK: - IDE编辑器视图
struct IDEEditorView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var codeContent: String = ""
    @State private var fileName: String = "untitled.swift"
    @State private var showFileTree: Bool = true
    @State private var showSearchPanel: Bool = false
    
    // 搜索替换
    @State private var searchText: String = ""
    @State private var replaceText: String = ""
    @State private var searchResults: [SearchResult] = []
    @State private var currentSearchIndex: Int = -1
    @State private var searchCaseSensitive: Bool = false
    
    // 文件树
    @State private var editorFiles: [EditorFile] = EditorFile.samples
    @State private var selectedFileId: UUID?
    
    // 行号
    @State private var lineCount: Int = 0
    
    // 语法高亮
    @State private var highlightedLines: [Int: AttributedString] = [:]
    
    // 文件操作
    @State private var showNewFileAlert = false
    @State private var newFileName: String = ""
    @State private var showFileImporter = false
    @State private var showSaveAlert = false
    @State private var saveMessage = ""
    
    var body: some View {
        HSplitView {
            // 左侧：文件树
            if showFileTree {
                fileTreePanel
            }
            
            // 右侧：编辑器主体
            VStack(spacing: 0) {
                // 工具栏
                toolbarArea
                
                // 搜索替换面板
                if showSearchPanel {
                    searchReplacePanel
                }
                
                // 编辑器区域
                editorArea
                
                // 底部状态栏
                statusBar
            }
        }
        .navigationTitle("IDE编辑器")
        .background(Color.clear)
        .onChange(of: codeContent) { newValue in
            updateLineCount(newValue)
            updateSyntaxHighlight(newValue)
        }
        .alert("新建文件", isPresented: $showNewFileAlert) {
            TextField("文件名", text: $newFileName)
            Button("取消", role: .cancel) { }
            Button("创建") {
                createNewFile()
            }
        } message: {
            Text("请输入新文件名（含扩展名）")
        }
        .alert("保存文件", isPresented: $showSaveAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(saveMessage)
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.plainText, .swiftSource, .sourceCode, .xml, .json, .yaml, .script],
            allowsMultipleSelection: false
        ) { result in
            openFile(result)
        }
        .onAppear {
            if let first = editorFiles.first {
                selectFile(first)
            }
        }
    }
    
    // MARK: - 文件树面板
    private var fileTreePanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text("文件")
                    .font(.headline)
                Spacer()
                Button(action: { showFileTree = false }) {
                    Image(systemName: "sidebar.left")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(editorFiles) { file in
                        EditorFileRow(
                            file: file,
                            isSelected: selectedFileId == file.id,
                            onSelect: { selectFile(file) }
                        )
                    }
                }
                .padding(4)
            }
        }
        .frame(minWidth: 200, idealWidth: 240, maxWidth: 280)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 工具栏
    private var toolbarArea: some View {
        HStack(spacing: 8) {
            // 文件操作
            Group {
                Button(action: { showNewFileAlert = true }) {
                    Label("新建", systemImage: "doc.badge.plus")
                        .font(.caption)
                }
                .glassButtonStyle()
                
                Button(action: { showFileImporter = true }) {
                    Label("打开", systemImage: "folder")
                        .font(.caption)
                }
                .glassButtonStyle()
                
                Button(action: saveFile) {
                    Label("保存", systemImage: "square.and.arrow.down")
                        .font(.caption)
                }
                .glassButtonStyle()
            }
            
            Divider()
                .frame(height: 20)
            
            // 显示切换
            if !showFileTree {
                Button(action: { showFileTree = true }) {
                    Image(systemName: "sidebar.left")
                }
                .glassButtonStyle()
            }
            
            Button(action: { showSearchPanel.toggle() }) {
                Label("搜索", systemImage: "magnifyingglass")
                    .font(.caption)
            }
            .glassButtonStyle()
            
            Spacer()
            
            // 文件名
            Text(fileName)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.thinMaterial)
    }
    
    // MARK: - 搜索替换面板
    private var searchReplacePanel: some View {
        VStack(spacing: 8) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("搜索...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                        .onChange(of: searchText) { _ in
                            performSearch()
                        }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ultraThinMaterial)
                )
                
                if !searchResults.isEmpty {
                    Text("\(currentSearchIndex + 1)/\(searchResults.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Button(action: previousSearchResult) {
                        Image(systemName: "chevron.up")
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: nextSearchResult) {
                        Image(systemName: "chevron.down")
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: { showSearchPanel = false }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            if !searchText.isEmpty {
                HStack {
                    HStack {
                        TextField("替换为...", text: $replaceText)
                            .textFieldStyle(.plain)
                            .font(.subheadline)
                    }
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.ultraThinMaterial)
                    )
                    
                    GlassButton(title: "替换", icon: "arrow.right") {
                        replaceCurrent()
                    }
                    
                    GlassButton(title: "全部替换", icon: "arrow.right.2") {
                        replaceAll()
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 编辑器区域
    private var editorArea: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                // 行号
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(1..<lineCount + 1, id: \.self) { lineNum in
                        Text("\(lineNum)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .frame(height: 20)
                            .padding(.trailing, 8)
                    }
                }
                .padding(.vertical, 8)
                .padding(.leading, 8)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50)
                )
                
                // 代码内容
                TextEditor(text: $codeContent)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(minWidth: 600, minHeight: 400)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.1), lineWidth: 0.5)
        )
        .padding(8)
    }
    
    // MARK: - 底部状态栏
    private var statusBar: some View {
        HStack(spacing: 16) {
            Label("\(lineCount) 行", systemImage: "text.alignleft")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Label("UTF-8", systemImage: "textformat")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if showSearchPanel {
                Label("\(searchResults.count) 个匹配", systemImage: "number")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Label("\(codeContent.count) 字符", systemImage: "character")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(.thinMaterial)
    }
    
    // MARK: - 方法
    
    private func selectFile(_ file: EditorFile) {
        selectedFileId = file.id
        fileName = file.name
        codeContent = file.content
        updateLineCount(codeContent)
        updateSyntaxHighlight(codeContent)
        searchResults = []
        currentSearchIndex = -1
    }
    
    private func createNewFile() {
        guard !newFileName.isEmpty else { return }
        let newFile = EditorFile(name: newFileName, content: "", icon: fileIcon(for: newFileName))
        editorFiles.append(newFile)
        selectFile(newFile)
        newFileName = ""
    }
    
    private func openFile(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let name = url.lastPathComponent
                let newFile = EditorFile(name: name, content: content, icon: fileIcon(for: name))
                editorFiles.append(newFile)
                selectFile(newFile)
            } catch {
                saveMessage = "无法打开文件: \(error.localizedDescription)"
                showSaveAlert = true
            }
        case .failure(let error):
            saveMessage = "文件选择失败: \(error.localizedDescription)"
            showSaveAlert = true
        }
    }
    
    private func saveFile() {
        saveMessage = "文件「\(fileName)」已保存"
        showSaveAlert = true
    }
    
    private func updateLineCount(_ content: String) {
        lineCount = max(content.components(separatedBy: "\n").count, 1)
    }
    
    private func fileIcon(for name: String) -> String {
        let ext = name.components(separatedBy: ".").last?.lowercased() ?? ""
        switch ext {
        case "swift": return "swift"
        case "kt", "kts": return "kotlin"
        case "java": return "java"
        case "py": return "python"
        case "js", "ts": return "javascript"
        case "xml": return "doc.xml"
        case "json": return "curlybraces"
        case "yaml", "yml": return "yaml"
        case "md": return "doc.text"
        case "txt": return "doc.text"
        default: return "doc"
        }
    }
    
    // MARK: - 搜索替换
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            currentSearchIndex = -1
            return
        }
        
        let options: String.CompareOptions = searchCaseSensitive ? [] : .caseInsensitive
        var results: [SearchResult] = []
        let lines = codeContent.components(separatedBy: "\n")
        
        for (lineIdx, line) in lines.enumerated() {
            var searchRange = line.startIndex..<line.endIndex
            while let range = line.range(of: searchText, options: options, range: searchRange) {
                let col = line.distance(from: line.startIndex, to: range.lowerBound)
                results.append(SearchResult(line: lineIdx + 1, column: col, range: range))
                searchRange = range.upperBound..<line.endIndex
            }
        }
        
        searchResults = results
        currentSearchIndex = results.isEmpty ? -1 : 0
    }
    
    private func nextSearchResult() {
        if !searchResults.isEmpty {
            currentSearchIndex = (currentSearchIndex + 1) % searchResults.count
        }
    }
    
    private func previousSearchResult() {
        if !searchResults.isEmpty {
            currentSearchIndex = (currentSearchIndex - 1 + searchResults.count) % searchResults.count
        }
    }
    
    private func replaceCurrent() {
        guard currentSearchIndex >= 0 && currentSearchIndex < searchResults.count else { return }
        let result = searchResults[currentSearchIndex]
        let lines = codeContent.components(separatedBy: "\n")
        var line = lines[result.line - 1]
        line.replaceSubrange(result.range, with: replaceText)
        lines[result.line - 1] = line
        codeContent = lines.joined(separator: "\n")
        performSearch()
    }
    
    private func replaceAll() {
        guard !searchText.isEmpty else { return }
        let options: String.CompareOptions = searchCaseSensitive ? [] : .caseInsensitive
        codeContent = codeContent.replacingOccurrences(of: searchText, with: replaceText, options: options)
        performSearch()
    }
    
    // MARK: - 简单语法高亮
    private func updateSyntaxHighlight(_ content: String) {
        let lines = content.components(separatedBy: "\n")
        highlightedLines = [:]
        
        let keywords = [
            "import", "struct", "class", "enum", "protocol", "extension",
            "func", "var", "let", "if", "else", "for", "while", "switch",
            "case", "return", "break", "continue", "guard", "defer",
            "throws", "rethrows", "async", "await", "actor", "mutating",
            "nonmutating", "override", "static", "private", "public",
            "internal", "fileprivate", "open", "final", "lazy", "weak",
            "unowned", "inout", "indirect", "required", "optional",
            "true", "false", "nil", "self", "super", "Type", "Protocol",
            "where", "associatedtype", "subscript", "init", "deinit"
        ]
        
        let typePatterns = [
            "Int", "String", "Double", "Float", "Bool", "Array",
            "Dictionary", "Set", "Data", "Date", "URL", "UUID",
            "Error", "Result", "Optional", "Any", "AnyObject",
            "CodingKey", "Codable", "Encodable", "Decodable",
            "View", "Shape", "Color", "Image", "Text"
        ]
        
        for (index, line) in lines.enumerated() {
            var attributed = AttributedString(line)
            
            // 关键字高亮
            for kw in keywords {
                var searchRange = attributed.startIndex..<attributed.endIndex
                while let range = attributed[searchRange].range(of: kw) {
                    if attributed[range].characters.allSatisfy({ $0.isLetter }) {
                        attributed[range].foregroundColor = .purple
                        attributed[range].font = .system(.body, design: .monospaced).bold()
                    }
                    searchRange = range.upperBound..<attributed.endIndex
                }
            }
            
            // 类型高亮
            for tp in typePatterns {
                var searchRange = attributed.startIndex..<attributed.endIndex
                while let range = attributed[searchRange].range(of: tp) {
                    attributed[range].foregroundColor = .teal
                    searchRange = range.upperBound..<attributed.endIndex
                }
            }
            
            // 注释高亮（//）
            if let commentRange = attributed.range(of: "//") {
                attributed[commentRange.lowerBound...].foregroundColor = .green
            }
            
            // 字符串高亮
            var strSearch = attributed.startIndex..<attributed.endIndex
            while let quoteStart = attributed[strSearch].range(of: "\"") {
                let afterQuote = quoteStart.upperBound
                if afterQuote < attributed.endIndex {
                    let remaining = afterQuote..<attributed.endIndex
                    if let quoteEnd = attributed[remaining].range(of: "\"") {
                        let fullRange = quoteStart.lowerBound..<quoteEnd.upperBound
                        attributed[fullRange].foregroundColor = .orange
                        strSearch = quoteEnd.upperBound..<attributed.endIndex
                    } else {
                        attributed[quoteStart.lowerBound...].foregroundColor = .orange
                        break
                    }
                } else {
                    break
                }
            }
            
            // 数字高亮
            var numSearch = attributed.startIndex..<attributed.endIndex
            while let numRange = attributed[numSearch].range(of: #"\b\d+(\.\d+)?\b"#, strategy: .regularExpression) {
                attributed[numRange].foregroundColor = .blue
                numSearch = numRange.upperBound..<attributed.endIndex
            }
            
            highlightedLines[index + 1] = attributed
        }
    }
}

// MARK: - 编辑器文件模型
struct EditorFile: Identifiable {
    let id = UUID()
    let name: String
    let content: String
    let icon: String
    
    static let samples: [EditorFile] = [
        EditorFile(name: "MainActivity.swift", content: """
import SwiftUI

struct MainActivity: View {
    @EnvironmentObject private var appState: AppState
    @State private var isLoading = false
    @State private var showDetail = false
    
    let title: String
    let items: [String]
    
    var body: some View {
        NavigationStack {
            List(items, id: \\.self) { item in
                HStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.tint)
                    Text(item)
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isLoading.toggle() }) {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    // 数据加载方法
    func loadData() async throws -> [String] {
        let url = URL(string: "https://api.example.com/data")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        return decoded
    }
}
""", icon: "swift"),
        EditorFile(name: "NetworkService.swift", content: """
import Foundation

// MARK: - 网络服务
final class NetworkService {
    static let shared = NetworkService()
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // 通用请求方法
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        type: T.Type
    ) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        return try decoder.decode(T.self, from: data)
    }
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingFailed
}
""", icon: "swift"),
        EditorFile(name: "config.json", content: """
{
    "app": {
        "name": "CAssistant",
        "version": "1.0.0",
        "build": 20260612
    },
    "analysis": {
        "maxFileSize": 104857600,
        "enableDeepScan": true,
        "supportedFormats": [
            "apk", "ipa", "dex", "so",
            "smali", "xml", "arsc"
        ]
    },
    "ai": {
        "provider": "openai",
        "model": "gpt-4",
        "temperature": 0.3,
        "maxTokens": 4096
    },
    "ui": {
        "theme": "dark",
        "fontSize": 14,
        "showLineNumbers": true
    }
}
""", icon: "curlybraces")
    ]
}

// MARK: - 搜索替换结果模型
private struct SearchResult {
    let line: Int
    let column: Int
    let range: Range<String.Index>
}

// MARK: - 文件行组件
private struct EditorFileRow: View {
    let file: EditorFile
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                Image(systemName: file.icon)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .tint : .secondary)
                Text(file.name)
                    .font(.subheadline)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? .thinMaterial : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.accentColor.opacity(0.3) : .clear, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - HSplitView 封装
private struct HSplitView<Left: View, Right: View>: View {
    let left: Left
    let right: Right
    
    init(@ViewBuilder content: () -> TupleView<(Left, Right)>) {
        let tuple = content()
        self.left = tuple.value.0
        self.right = tuple.value.1
    }
    
    var body: some View {
        HStack(spacing: 0) {
            left
            Divider()
            right
        }
    }
}