import SwiftUI
import UniformTypeIdentifiers

// MARK: - 主视图（自适应iPhone/iPad布局）
struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedCategory: NavigationCategory? = .analysis
    @State private var selectedItem: NavigationItem? = nil
    @State private var showFileImporter = false
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {
                sidebarContent
                    .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
            },
            content: {
                contentList
                    .navigationSplitViewColumnWidth(min: 260, ideal: 320, max: 400)
            },
            detail: {
                detailView
            }
        )
        .navigationSplitViewStyle(.balanced)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: FileImportManager.supportedTypes,
            allowsMultipleSelection: true
        ) { result in
            handleFileImportResult(result)
        }
    }
    
    // MARK: - 侧边栏
    private var sidebarContent: some View {
        List(NavigationCategory.allCases, selection: $selectedCategory) { category in
            Label(category.title, systemImage: category.icon)
                .listRowBackground(category == selectedCategory ?
                    AnyView(RoundedRectangle(cornerRadius: 10).fill(.thinMaterial)) :
                    AnyView(Color.clear)
                )
                .padding(.vertical, 4)
        }
        .navigationTitle("CAssistant")
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: { showFileImporter = true }) {
                    Label("导入文件", systemImage: "doc.badge.plus")
                }
                .glassBackground()
                
                Button(action: { appState.isDarkMode.toggle() }) {
                    Label("主题", systemImage: appState.isDarkMode ? "sun.max" : "moon")
                }
                .glassBackground()
            }
        }
    }
    
    // MARK: - 内容列表
    private var contentList: some View {
        Group {
            if let category = selectedCategory {
                List(category.items, selection: $selectedItem) { item in
                    NavigationLink(value: item) {
                        HStack(spacing: 12) {
                            Image(systemName: item.icon)
                                .foregroundStyle(.tint)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.body)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(item == selectedItem ?
                        AnyView(RoundedRectangle(cornerRadius: 10).fill(.thinMaterial)) :
                        AnyView(Color.clear)
                    )
                }
                .navigationTitle(category.title)
            }
        }
    }
    
    // MARK: - 详情视图
    @ViewBuilder
    private var detailView: some View {
        if let item = selectedItem {
            destinationView(for: item)
        } else {
            WelcomeView()
        }
    }
    
    // MARK: - 路由到对应视图
    @ViewBuilder
    private func destinationView(for item: NavigationItem) -> some View {
        switch item.id {
        case "apk_analyzer": ApkAnalyzerView()
        case "apk_info": ApkInfoView()
        case "permissions": PermissionAnalysisView()
        case "components": ComponentAnalysisView()
        case "class_structure": ClassStructureView()
        case "certificate": CertificateView()
        case "manifest": ManifestView()
        case "file_list": FileListView()
        case "smali_viewer": SmaliViewerView()
        case "dex_viewer": DexViewerView()
        case "arsc_viewer": ArscViewerView()
        case "so_analysis": SoAnalysisView()
        case "ai_chat": AIChatView()
        case "ai_config": AIConfigView()
        case "project_manager": ProjectManagerView()
        case "terminal": TerminalView()
        case "environment": EnvironmentConfigView()
        case "new_project": NewProjectView()
        case "reverse_engineering": ReverseEngineeringView()
        case "cert_manager": CertificateManagerView()
        case "file_preview": FilePreviewView()
        case "ide_editor": IDEEditorView()
        case "ide_ai": IDEAIAssistantView()
        case "theme_settings": ThemeSettingsView()
        case "about": AboutView()
        default: WelcomeView()
        }
    }
    
    // MARK: - 安全文件导入处理
    private func handleFileImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                
                do {
                    let fileData = try Data(contentsOf: url)
                    let fileName = url.lastPathComponent
                    let fileExt = url.pathExtension.lowercased()
                    
                    let imported = ImportedFile(
                        name: fileName,
                        extension: fileExt,
                        data: fileData,
                        url: url
                    )
                    appState.importedFiles.append(imported)
                    appState.selectedFile = imported
                    
                    // 自动解析APK
                    if fileExt == "apk" {
                        appState.currentAPKPath = url
                        Task { await appState.parseAPK(url) }
                    }
                } catch {
                    appState.errorMessage = "无法读取文件: \(error.localizedDescription)"
                }
            }
        case .failure(let error):
            appState.errorMessage = "导入失败: \(error.localizedDescription)"
        }
    }
}

// MARK: - 导航分类
enum NavigationCategory: String, CaseIterable {
    case analysis = "analysis"
    case viewers = "viewers"
    case ai = "ai"
    case project = "project"
    case tools = "tools"
    case settings = "settings"
    
    var title: String {
        switch self {
        case .analysis: return "分析工具"
        case .viewers: return "查看器"
        case .ai: return "AI功能"
        case .project: return "项目管理"
        case .tools: return "工具"
        case .settings: return "设置"
        }
    }
    
    var icon: String {
        switch self {
        case .analysis: return "magnifyingglass.circle"
        case .viewers: return "eye"
        case .ai: return "brain"
        case .project: return "folder"
        case .tools: return "wrench.and.screwdriver"
        case .settings: return "gear"
        }
    }
    
    var items: [NavigationItem] {
        switch self {
        case .analysis: return [
            NavigationItem(id: "apk_analyzer", title: "APK分析", subtitle: "解析APK文件结构", icon: "doc.text.magnifyingglass"),
            NavigationItem(id: "apk_info", title: "基本信息", subtitle: "包名、版本、SDK等", icon: "info.circle"),
            NavigationItem(id: "permissions", title: "权限分析", subtitle: "权限列表与风险评估", icon: "hand.raised"),
            NavigationItem(id: "components", title: "组件分析", subtitle: "Activity/Service等", icon: "square.grid.2x2"),
            NavigationItem(id: "class_structure", title: "类结构", subtitle: "类/方法/字段", icon: "square.stack.3d.up"),
            NavigationItem(id: "certificate", title: "签名信息", subtitle: "证书与签名", icon: "certificate"),
            NavigationItem(id: "manifest", title: "Manifest", subtitle: "AndroidManifest.xml", icon: "doc.xml"),
            NavigationItem(id: "file_list", title: "文件列表", subtitle: "APK内部文件结构", icon: "list.bullet"),
        ]
        case .viewers: return [
            NavigationItem(id: "smali_viewer", title: "Smali查看器", subtitle: "Dalvik字节码", icon: "chevron.left.forwardslash.chevron.right"),
            NavigationItem(id: "dex_viewer", title: "Dex结构", subtitle: "类/方法/字段树", icon: "tree"),
            NavigationItem(id: "arsc_viewer", title: "资源表Arsc", subtitle: "strings/drawables", icon: "paintpalette"),
            NavigationItem(id: "so_analysis", title: "SO分析", subtitle: "Native库ELF分析", icon: "cpu"),
            NavigationItem(id: "file_preview", title: "文件预览", subtitle: "各类文件内容", icon: "doc.viewfinder"),
        ]
        case .ai: return [
            NavigationItem(id: "ai_chat", title: "AI助手", subtitle: "智能分析辅助", icon: "message"),
            NavigationItem(id: "ai_config", title: "AI配置", subtitle: "API密钥与模型", icon: "gearshape.2"),
            NavigationItem(id: "ide_ai", title: "IDE AI辅助", subtitle: "代码智能分析", icon: "wand.and.stars"),
        ]
        case .project: return [
            NavigationItem(id: "project_manager", title: "项目管理", subtitle: "管理与浏览项目", icon: "folder"),
            NavigationItem(id: "new_project", title: "新建项目", subtitle: "创建逆向项目", icon: "folder.badge.plus"),
            NavigationItem(id: "reverse_engineering", title: "逆向工程", subtitle: "APK反编译", icon: "hammer"),
            NavigationItem(id: "terminal", title: "终端", subtitle: "命令执行", icon: "terminal"),
            NavigationItem(id: "environment", title: "环境配置", subtitle: "JDK/SDK/工具路径", icon: "gearshape"),
        ]
        case .tools: return [
            NavigationItem(id: "cert_manager", title: "证书管理", subtitle: "签名与密钥管理", icon: "lock.shield"),
            NavigationItem(id: "ide_editor", title: "IDE编辑器", subtitle: "代码编辑", icon: "pencil.and.outline"),
        ]
        case .settings: return [
            NavigationItem(id: "theme_settings", title: "主题设置", subtitle: "外观与字体", icon: "paintbrush"),
            NavigationItem(id: "about", title: "关于", subtitle: "版本与许可", icon: "info.circle.fill"),
        ]
        }
    }
}

// MARK: - 导航项
struct NavigationItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    
    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - WelcomeView
struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if #available(iOS 17.0, *) {
            Image(systemName: "ant.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
                .symbolEffect(.pulse)
        } else {
            Image(systemName: "ant.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
        }
            
            Text("CAssistant")
                .font(.largeTitle.bold())
            
            Text("APK逆向工程辅助工具")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text("从左侧选择一个功能开始")
                .font(.body)
                .foregroundStyle(.tertiary)
            
            Button(action: { appState.showFileImporter = true }) {
                Label("从文件管理器导入APK", systemImage: "doc.badge.plus")
                    .padding()
                    .glassBackground()
            }
            
            if !appState.importedFiles.isEmpty {
                Text("已导入 \(appState.importedFiles.count) 个文件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear)
    }
}