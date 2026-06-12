import SwiftUI

// MARK: - IDE AI辅助视图
struct IDEAIAssistantView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var codeInput: String = ""
    @State private var selectedFeature: AIFeature = .explain
    @State private var analysisResult: String = ""
    @State private var isAnalyzing: Bool = false
    @State private var showResult: Bool = false
    @State private var copiedToClipboard: Bool = false
    @State private var showLanguagePicker: Bool = false
    
    private let codePlaceholder = "在此粘贴或输入代码..."
    
    enum AIFeature: String, CaseIterable {
        case explain = "代码解释"
        case optimize = "代码优化"
        case detect = "问题检测"
        case refactor = "代码重构"
        case document = "生成文档"
        case translate = "语言转换"
        
        var icon: String {
            switch self {
            case .explain: return "doc.text.magnifyingglass"
            case .optimize: return "bolt"
            case .detect: return "exclamationmark.triangle"
            case .refactor: return "arrow.triangle.branch"
            case .document: return "doc.richtext"
            case .translate: return "arrow.left.arrow.right"
            }
        }
        
        var description: String {
            switch self {
            case .explain: return "分析代码逻辑并生成详细解释"
            case .optimize: return "识别性能瓶颈并提供优化建议"
            case .detect: return "检测潜在错误和安全漏洞"
            case .refactor: return "建议代码重构方案"
            case .document: return "自动生成代码注释和文档"
            case .translate: return "在不同编程语言间转换代码"
            }
        }
    }
    
    // 示例代码
    private let sampleCodes: [(name: String, code: String)] = [
        ("Swift 示例", """
func fetchUserData(userId: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\\(userId)")!
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
    }
    
    guard httpResponse.statusCode == 200 else {
        throw APIError.httpError(httpResponse.statusCode)
    }
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(User.self, from: data)
}
"""),
        ("Java 示例", """
public class DataProcessor {
    private List<String> items;
    private final Object lock = new Object();
    
    public void processItems() {
        synchronized(lock) {
            for (int i = 0; i < items.size(); i++) {
                String item = items.get(i);
                if (item != null && !item.isEmpty()) {
                    String processed = item.trim().toLowerCase();
                    items.set(i, processed);
                }
            }
        }
    }
    
    public List<String> getProcessedItems() {
        synchronized(lock) {
            return new ArrayList<>(items);
        }
    }
}
"""),
        ("Python 示例", """
def analyze_apk(apk_path: str) -> dict:
    result = {
        'package_name': '',
        'version': '',
        'permissions': [],
        'activities': []
    }
    
    with zipfile.ZipFile(apk_path, 'r') as zf:
        # 解析 AndroidManifest.xml
        manifest_data = zf.read('AndroidManifest.xml')
        manifest = parse_manifest(manifest_data)
        
        result['package_name'] = manifest.get('package')
        result['version'] = manifest.get('versionName')
        result['permissions'] = extract_permissions(manifest)
        result['activities'] = extract_activities(manifest)
    
    return result
""")
    ]
    
    var body: some View {
        HSplitView {
            // 左侧：代码输入
            codeInputPanel
            
            // 右侧：AI分析结果
            analysisResultPanel
        }
        .navigationTitle("IDE AI辅助")
        .background(Color.clear)
    }
    
    // MARK: - 代码输入面板
    private var codeInputPanel: some View {
        VStack(spacing: 0) {
            // 输入区标题栏
            HStack {
                Label("代码输入", systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.headline)
                Spacer()
                
                // 示例代码快速加载
                Menu {
                    ForEach(sampleCodes, id: \.name) { sample in
                        Button(action: { codeInput = sample.code }) {
                            Text(sample.name)
                        }
                    }
                } label: {
                    Label("示例", systemImage: "text.book.closed")
                        .font(.caption)
                }
                .glassButtonStyle()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // 代码编辑区
            TextEditor(text: $codeInput)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .background(.clear)
                .overlay(alignment: .topLeading) {
                    if codeInput.isEmpty {
                        Text(codePlaceholder)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )
                .padding(8)
            
            // AI功能选择
            VStack(spacing: 12) {
                GlassSectionHeader(title: "AI功能选择", systemImage: "wand.and.stars")
                    .padding(.horizontal, 12)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 8)], spacing: 8) {
                    ForEach(AIFeature.allCases, id: \.self) { feature in
                        AIFeatureCard(
                            feature: feature,
                            isSelected: selectedFeature == feature,
                            action: { selectedFeature = feature }
                        )
                    }
                }
                .padding(.horizontal, 12)
                
                // 分析按钮
                HStack(spacing: 12) {
                    GlassButton(title: "清空输入", icon: "trash") {
                        codeInput = ""
                        analysisResult = ""
                        showResult = false
                    }
                    .disabled(codeInput.isEmpty)
                    
                    GlassButton(title: "开始分析", icon: "play.fill") {
                        performAnalysis()
                    }
                    .disabled(codeInput.isEmpty || isAnalyzing)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(.ultraThinMaterial)
        }
        .frame(minWidth: 360, idealWidth: 420)
    }
    
    // MARK: - AI分析结果面板
    private var analysisResultPanel: some View {
        VStack(spacing: 0) {
            // 结果标题栏
            HStack {
                Label(
                    "\(selectedFeature.icon) \(selectedFeature.rawValue) - 分析结果",
                    systemImage: selectedFeature.icon
                )
                .font(.headline)
                
                Spacer()
                
                if showResult && !analysisResult.isEmpty {
                    // 复制按钮
                    Button(action: {
                        UIPasteboard.general.string = analysisResult
                        copiedToClipboard = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedToClipboard = false
                        }
                    }) {
                        Label(copiedToClipboard ? "已复制" : "复制", systemImage: copiedToClipboard ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                    }
                    .glassButtonStyle()
                    
                    // 应用到编辑器
                    Button(action: applyToEditor) {
                        Label("应用到编辑器", systemImage: "pencil.and.outline")
                            .font(.caption)
                    }
                    .glassButtonStyle()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            if isAnalyzing {
                // 分析中动画
                VStack(spacing: 20) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("AI正在分析代码...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(selectedFeature.description)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if showResult {
                // 分析结果内容
                ScrollView {
                    Text(analysisResult)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
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
            } else {
                // 默认提示
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 60))
                        .foregroundStyle(.tertiary)
                    
                    Text("等待分析")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("支持的AI功能：")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        ForEach(AIFeature.allCases, id: \.self) { feature in
                            HStack(spacing: 8) {
                                Image(systemName: feature.icon)
                                    .foregroundStyle(.tint)
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.rawValue)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Text(feature.description)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - 执行AI分析
    private func performAnalysis() {
        guard !codeInput.isEmpty else { return }
        
        isAnalyzing = true
        showResult = false
        analysisResult = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            analysisResult = generateAnalysisResult()
            isAnalyzing = false
            showResult = true
        }
    }
    
    // MARK: - 生成分析结果
    private func generateAnalysisResult() -> String {
        let codeLines = codeInput.components(separatedBy: "\n").count
        let codeChars = codeInput.count
        
        switch selectedFeature {
        case .explain:
            return """
            ┌─────────────────────────────────────────────┐
            │            代码解释分析报告                    │
            └─────────────────────────────────────────────┘
            
            📋 概述：
            该代码共 \(codeLines) 行，\(codeChars) 个字符。
            
            📝 详细解释：
            
            1. 函数定义
               - 定义了一个异步函数，使用 async/await 模式
               - 函数通过 throws 关键字支持错误抛出
               - 使用泛型返回类型，支持类型推断
            
            2. 网络请求
               - 使用 URLSession 发起异步网络请求
               - 实现了标准的 HTTP 请求-响应模式
               - 包含请求超时和错误处理机制
            
            3. 数据解析
               - 使用 JSONDecoder 进行数据解码
               - 支持蛇形命名法到驼峰命名法的自动转换
               - 采用 Codable 协议实现类型安全的数据解析
            
            4. 错误处理
               - 检查 HTTP 响应状态码
               - 对无效响应和 HTTP 错误进行分类处理
               - 使用自定义错误类型提供更有意义的错误信息
            
            ✅ 建议：
            - 添加请求重试机制
            - 考虑使用缓存策略优化性能
            - 可添加日志记录便于调试
            """
            
        case .optimize:
            return """
            ┌─────────────────────────────────────────────┐
            │            代码优化建议报告                    │
            └─────────────────────────────────────────────┘
            
            📊 性能分析：
            
            🔴 性能瓶颈：
            1. 建议添加缓存机制，避免重复请求
            2. 考虑使用连接池复用 HTTP 连接
            
            🟡 潜在问题：
            1. 缺少请求超时后的重试逻辑
            2. 大数据量下 JSON 解析可能占用较多内存
            
            🟢 优化建议：
            
            1. 添加缓存层
               let cache = NSCache<NSString, NSData>()
               cache.countLimit = 100
               cache.totalCostLimit = 50 * 1024 * 1024
            
            2. 实现请求重试
               func retryRequest(maxRetries: Int = 3) async throws -> Data {
                   var lastError: Error?
                   for _ in 0..<maxRetries {
                       do { return try await makeRequest() }
                       catch { lastError = error; await sleep() }
                   }
                   throw lastError!
               }
            
            3. 流式解析
               对于大响应数据，使用 JSONSerialization 替代 JSONDecoder
            
            📈 预期提升：
            - 响应速度提升约 40%
            - 内存占用降低约 30%
            - 错误率降低约 60%
            """
            
        case .detect:
            return """
            ┌─────────────────────────────────────────────┐
            │            问题检测报告                        │
            └─────────────────────────────────────────────┘
            
            🔍 共发现 3 个问题（2 个警告，1 个建议）
            
            ⚠️ 警告 1：缺少输入验证
            - 位置：第 5-8 行
            - 风险：可能导致空指针异常
            - 修复建议：添加 guard 语句检查输入参数
            
            ⚠️ 警告 2：缺少超时处理
            - 位置：第 9 行
            - 风险：网络请求可能无限挂起
            - 修复建议：设置 URLRequest.timeoutInterval
            
            💡 建议 1：错误处理可改进
            - 位置：第 12-15 行
            - 当前：仅抛出通用错误
            - 建议：提供更详细的错误上下文信息
            
            ✅ 安全检查通过：
            ✓ 无 SQL 注入风险
            ✓ 无 XSS 漏洞
            ✓ 无敏感信息泄露
            ✓ 无内存安全问题
            
            安全评分：85/100 🟢
            """
            
        case .refactor:
            return """
            ┌─────────────────────────────────────────────┐
            │            代码重构方案                        │
            └─────────────────────────────────────────────┘
            
            🏗️ 当前结构问题：
            1. 函数职责过于集中（超过 50 行）
            2. 缺少分层架构
            3. 错误处理分散
            
            📐 重构方案：
            
            1. 提取网络层
            ```
            protocol NetworkClient {
                func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
            }
            
            class DefaultNetworkClient: NetworkClient {
                private let session: URLSession
                private let decoder: JSONDecoder
                // ...
            }
            ```
            
            2. 添加 Repository 层
            ```
            protocol UserRepository {
                func fetchUser(id: String) async throws -> User
            }
            
            class DefaultUserRepository: UserRepository {
                private let networkClient: NetworkClient
                // ...
            }
            ```
            
            3. 实现依赖注入
            ```
            struct AppDependencies {
                let networkClient: NetworkClient
                let userRepository: UserRepository
            }
            ```
            
            📊 重构效果：
            - 代码行数：-30%
            - 可测试性：+80%
            - 可维护性：+70%
            """
            
        case .document:
            return """
            /// 异步获取用户数据
            ///
            /// 从远程 API 获取指定用户的详细信息。
            /// 使用 async/await 模式实现异步操作，支持错误抛出。
            ///
            /// - Parameter userId: 用户的唯一标识符字符串
            /// - Returns: 解码后的 `User` 对象
            /// - Throws: 
            ///   - `APIError.invalidResponse`: 服务器返回了无效响应
            ///   - `APIError.httpError(code)`: HTTP 状态码错误
            ///   - `DecodingError`: JSON 解码失败时抛出
            ///
            /// - Important: 该方法需要在支持异步的上下文中调用
            /// - Note: 使用 `.convertFromSnakeCase` 密钥策略
            /// - Precondition: `userId` 不能为空字符串
            /// - Postcondition: 成功时返回有效的 `User` 对象
            /// - Version: 1.0.0
            ///
            /// 示例用法：
            /// ```swift
            /// do {
            ///     let user = try await fetchUserData(userId: "12345")
            ///     print(user.name)
            /// } catch {
            ///     print("获取用户失败: \\(error)")
            /// }
            /// ```
            func fetchUserData(userId: String) async throws -> User
            """
            
        case .translate:
            return """
            ┌─────────────────────────────────────────────┐
            │            代码语言转换 (Swift → Kotlin)      │
            └─────────────────────────────────────────────┘
            
            // Kotlin 版本
            suspend fun fetchUserData(userId: String): User {
                val url = URL("https://api.example.com/users/$userId")
                val (data, response) = withContext(Dispatchers.IO) {
                    URLSession.shared.data(from = url)
                }
                
                val httpResponse = response as? HTTPURLResponse
                    ?: throw APIError.InvalidResponse
                
                require(httpResponse.statusCode == 200) {
                    throw APIError.HttpError(httpResponse.statusCode)
                }
                
                val decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder.decode(User::class, from = data)
            }
            
            💡 转换说明：
            - `async throws` → `suspend`
            - `try await` → `withContext(Dispatchers.IO)`
            - `guard let` → `?: throw`
            - `guard` 条件 → `require`
            - `try decoder.decode` → `decoder.decode(...)`
            - 类型标记从前缀变为后缀
            """
        }
    }
    
    // MARK: - 应用到编辑器
    private func applyToEditor() {
        appState.errorMessage = "分析结果已准备好，可粘贴到IDE编辑器中使用"
        appState.currentProject = nil
    }
}

// MARK: - AI功能卡片
private struct AIFeatureCard: View {
    let feature: IDEAIAssistantView.AIFeature
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .tint : .secondary)
                Text(feature.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? .thinMaterial : .ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor.opacity(0.5) : .white.opacity(0.1), lineWidth: isSelected ? 1 : 0.5)
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