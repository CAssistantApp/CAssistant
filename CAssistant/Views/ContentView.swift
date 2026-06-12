import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTab: AppTab = .analyze
    @State private var showingFileImporter = false
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var navigationPath = NavigationPath()

    var body: some View {
        if horizontalSizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout
    private var iPhoneLayout: some View {
        NavigationStack(path: $navigationPath) {
            TabView(selection: $selectedTab) {
                ApkAnalyzerView()
                    .tabItem { Label("分析", systemImage: "ant.circle.fill") }
                    .tag(AppTab.analyze)

                ApkInfoView()
                    .tabItem { Label("查看器", systemImage: "eye.circle.fill") }
                    .tag(AppTab.viewer)

                AIAssistantView()
                    .tabItem { Label("AI", systemImage: "bolt.circle.fill") }
                    .tag(AppTab.ai)

                ProjectFilesView()
                    .tabItem { Label("项目", systemImage: "folder.circle.fill") }
                    .tag(AppTab.project)

                ToolsHubView()
                    .tabItem { Label("工具", systemImage: "wrench.and.screwdriver.fill") }
                    .tag(AppTab.tools)
            }
            .toolbar { toolbarContent }
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: FileImportManager.supportedTypes, allowsMultipleSelection: false) { result in
                handleFileImport(result)
            }
            .navigationDestination(for: String.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    // MARK: - iPad Layout
    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebarList
                .navigationTitle("CAssistant")
        } content: {
            contentViewForSelectedTab
        } detail: {
            detailViewForSelectedTab
        }
        .toolbar { toolbarContent }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: FileImportManager.supportedTypes, allowsMultipleSelection: false) { result in
            handleFileImport(result)
        }
    }

    private var sidebarList: some View {
        List {
            GlassNavRow(title: "分析", icon: "ant.circle.fill", subtitle: "解析 APK 文件") { selectedTab = .analyze }
            GlassNavRow(title: "查看器", icon: "eye.circle.fill", subtitle: "查看详细信息") { selectedTab = .viewer }
            GlassNavRow(title: "AI 助手", icon: "bolt.circle.fill", subtitle: "智能分析") { selectedTab = .ai }
            GlassNavRow(title: "项目文件", icon: "folder.circle.fill", subtitle: "文件浏览") { selectedTab = .project }
            GlassNavRow(title: "工具", icon: "wrench.and.screwdriver.fill", subtitle: "实用工具") { selectedTab = .tools }
        }
        .listStyle(.sidebar)
    }

    @ViewBuilder
    private var contentViewForSelectedTab: some View {
        switch selectedTab {
        case .analyze: ApkAnalyzerView()
        case .viewer: ApkInfoView()
        case .ai: AIAssistantView()
        case .project: ProjectFilesView()
        case .tools: ToolsHubView()
        }
    }

    @ViewBuilder
    private var detailViewForSelectedTab: some View {
        switch selectedTab {
        case .analyze: ManifestView()
        case .viewer: PermissionAnalysisView()
        case .ai: CertificateView()
        case .project: ComponentAnalysisView()
        case .tools: ClassStructureView()
        }
    }

    @ViewBuilder
    private func destinationView(for dest: String) -> some View {
        switch dest {
        case "manifest": ManifestView()
        case "permissions": PermissionAnalysisView()
        case "certificate": CertificateView()
        case "components": ComponentAnalysisView()
        case "classStructure": ClassStructureView()
        case "fileList": FileListView()
        case "apkInfo": ApkInfoView()
        case "dexViewer": DexViewerView()
        case "smaliViewer": SmaliViewerView()
        case "soAnalysis": SoAnalysisView()
        case "arscViewer": ArscViewerView()
        case "aiChat": AIChatView()
        case "aiConfig": AIConfigView()
        case "projectManager": ProjectManagerView()
        case "reverseEngineering": ReverseEngineeringView()
        case "terminal": TerminalView()
        case "ideEditor": IDEEditorView()
        case "certManager": CertificateManagerView()
        case "filePreview": FilePreviewView()
        case "settings": SettingsView()
        case "about": AboutView()
        default: Text("未知页面")
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 6) {
                Text(appState.selectedFileName.isEmpty ? "CAssistant" : appState.selectedFileName)
                    .font(.headline)
                    .foregroundColor(.primary)
                if appState.isAnalyzing {
                    ProgressView().scaleEffect(0.7)
                }
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            GlassButton(title: "导入", icon: "doc.badge.plus", color: .accentColor) {
                showingFileImporter = true
            }
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let _ = url.startAccessingSecurityScopedResource()
            Task { await appState.parseAPK(url) }
        case .failure(let error):
            appState.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Tab Enum
enum AppTab: Int, Hashable {
    case analyze = 0
    case viewer
    case ai
    case project
    case tools
}

// MARK: - AI Assistant View (full implementation)
struct AIAssistantView: View {
    @EnvironmentObject var appState: AppState
    @State private var showChat = false
    @State private var showConfig = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassSectionHeader(title: "AI 智能助手", icon: "bolt.circle.fill")

                VStack(spacing: 12) {
                    GlassNavRow(title: "AI 对话", icon: "message.fill", subtitle: "与 AI 进行智能对话分析") {
                        showChat = true
                    }
                    GlassNavRow(title: "AI 配置", icon: "gearshape.2.fill", subtitle: "配置 API 密钥和模型参数") {
                        showConfig = true
                    }
                    GlassNavRow(title: "代码分析", icon: "chevron.left.forwardslash.chevron.right", subtitle: "分析 Smali/DEX 代码") {
                        // Navigate to AI code analysis
                    }
                    GlassNavRow(title: "安全审计", icon: "shield.checkered", subtitle: "AI 驱动的安全漏洞检测") {
                        // Navigate to security audit
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 0.5))

                if !appState.aiChatMessages.isEmpty {
                    recentChatsSection
                }
            }
            .padding()
        }
        .navigationTitle("AI 助手")
        .sheet(isPresented: $showChat) { AIChatView() }
        .sheet(isPresented: $showConfig) { AIConfigView() }
    }

    private var recentChatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "最近对话", icon: "clock.arrow.circlepath")
            VStack(spacing: 8) {
                ForEach(appState.aiChatMessages.prefix(5)) { msg in
                    HStack {
                        Circle()
                            .fill(msg.role == .user ? Color.accentColor : Color.green)
                            .frame(width: 8, height: 8)
                        Text(msg.content.prefix(60).appending(msg.content.count > 60 ? "..." : ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.thinMaterial))
                }
            }
        }
    }
}

// MARK: - Project Files View
struct ProjectFilesView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            if appState.selectedFileName.isEmpty {
                VStack(spacing: 20) {
                    Spacer().frame(height: 60)
                    Image(systemName: "folder.circle").font(.system(size: 64)).foregroundStyle(.tertiary)
                    Text("项目文件管理").font(.title2).fontWeight(.medium)
                    Text("请先导入 APK 文件以浏览项目结构").font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        GlassSectionHeader(title: "项目资源", icon: "folder.circle.fill")
                        VStack(spacing: 8) {
                            GlassNavRow(title: "文件列表", icon: "list.bullet", subtitle: "\(appState.files.count) 个文件") {
                                // Navigate
                            }
                            GlassNavRow(title: "DEX 查看器", icon: "cube", subtitle: "\(appState.dexFiles.count) 个 DEX 文件") {
                                // Navigate
                            }
                            GlassNavRow(title: "Smali 代码", icon: "chevron.left.forwardslash.chevron.right", subtitle: "\(appState.smaliFiles.count) 个 Smali 文件") {
                                // Navigate
                            }
                            GlassNavRow(title: "SO 库分析", icon: "square.stack.3d.up", subtitle: "\(appState.soFiles.count) 个 SO 库") {
                                // Navigate
                            }
                            GlassNavRow(title: "ARSC 资源", icon: "tablecells", subtitle: "\(appState.arscFiles.count) 个资源文件") {
                                // Navigate
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 0.5))

                        FileListView()
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("项目")
    }
}

// MARK: - Tools Hub View
struct ToolsHubView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassSectionHeader(title: "实用工具", icon: "wrench.and.screwdriver.fill")

                VStack(spacing: 8) {
                    GlassNavRow(title: "IDE 编辑器", icon: "curlybraces", subtitle: "代码编辑器，支持语法高亮") {}
                    GlassNavRow(title: "证书管理", icon: "signature", subtitle: "查看和管理签名证书") {}
                    GlassNavRow(title: "逆向工程", icon: "arrow.triangle.2.circlepath", subtitle: "反编译和逆向分析工具") {}
                    GlassNavRow(title: "终端", icon: "terminal", subtitle: "命令行工具") {}
                    GlassNavRow(title: "文件预览", icon: "doc.text.magnifyingglass", subtitle: "预览文件内容") {}
                    GlassNavRow(title: "设置", icon: "gearshape", subtitle: "应用设置和主题") {}
                    GlassNavRow(title: "关于", icon: "info.circle", subtitle: "版本信息和帮助") {}
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 0.5))
            }
            .padding()
        }
        .navigationTitle("工具")
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}