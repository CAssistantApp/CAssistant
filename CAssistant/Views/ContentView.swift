import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTab: AppTab = .analyze
    @State private var showingFileImporter = false
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var navigationPath = NavigationPath()
    @State private var showAnnouncements = false
    @State private var showNewProject = false

    var body: some View {
        ZStack(alignment: .top) {
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
            announcementBanner
        }
        .onAppear {
            appState.loadAnnouncements()
        }
    }

    // MARK: - 云端公告横幅
    @ViewBuilder
    private var announcementBanner: some View {
        if let latest = appState.announcements.first(where: { !$0.isRead }) {
            VStack(spacing: 0) {
                Button {
                    showAnnouncements = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: latest.level.icon)
                            .foregroundColor(latest.level.color)
                            .font(.caption)
                        Text(latest.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Spacer()
                        GlassBadge(text: latest.level.rawValue, color: latest.level.color)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(latest.level.color.opacity(0.3), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.top, fullSafeAreaTop)
            }
            .sheet(isPresented: $showAnnouncements) {
                CloudAnnouncementView()
            }
        }
    }

    private var fullSafeAreaTop: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.top + 8
        }
        return 54
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

                ProjectTabView(showNewProject: $showNewProject)
                    .tabItem { Label("项目", systemImage: "folder.circle.fill") }
                    .tag(AppTab.project)

                ToolsTabView()
                    .tabItem { Label("工具", systemImage: "wrench.and.screwdriver.fill") }
                    .tag(AppTab.tools)
            }
            .toolbar { toolbarContent }
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: FileImportManager.supportedTypes, allowsMultipleSelection: false) { result in
                handleFileImport(result)
            }
            .navigationDestination(for: String.self) { dest in
                destinationView(for: dest)
            }
        }
        .sheet(isPresented: $showNewProject) {
            NewProjectView()
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
            Divider()
            GlassNavRow(title: "云端公告", icon: "bell.badge.fill", subtitle: "最新动态通知") { showAnnouncements = true }
        }
        .listStyle(.sidebar)
        .sheet(isPresented: $showAnnouncements) {
            CloudAnnouncementView()
        }
    }

    @ViewBuilder
    private var contentViewForSelectedTab: some View {
        switch selectedTab {
        case .analyze: ApkAnalyzerView()
        case .viewer: ApkInfoView()
        case .ai: AIAssistantView()
        case .project: ProjectTabView(showNewProject: $showNewProject)
        case .tools: ToolsTabView()
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

    // MARK: - Navigation Destinations
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
        case "cloudAnnouncements": CloudAnnouncementView()
        case "envConfig": EnvironmentConfigView()
        case "newProject": NewProjectView()
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
            HStack(spacing: 6) {
                Button { showAnnouncements = true } label: {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                GlassButton(title: "导入", icon: "doc.badge.plus", color: .accentColor) {
                    showingFileImporter = true
                }
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

// MARK: - Project Tab View (with proper navigation)
struct ProjectTabView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showNewProject: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if appState.selectedFileName.isEmpty {
                        VStack(spacing: 20) {
                            Spacer().frame(height: 60)
                            Image(systemName: "folder.circle")
                                .font(.system(size: 64))
                                .foregroundStyle(.tertiary)
                            Text("项目文件管理")
                                .font(.title2).fontWeight(.medium)
                            Text("请先导入 APK 文件以浏览项目结构")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            GlassButton(title: "新建项目", icon: "plus.circle.fill", color: .accentColor) {
                                showNewProject = true
                            }
                            Spacer()
                        }
                    } else {
                        GlassSectionHeader(title: "项目资源", icon: "folder.circle.fill")
                        VStack(spacing: 8) {
                            NavigationLink(value: "fileList") {
                                navLabel("文件列表", "list.bullet", "\(appState.files.count) 个文件")
                            }
                            NavigationLink(value: "dexViewer") {
                                navLabel("DEX 查看器", "cube", "\(appState.dexFiles.count) 个 DEX 文件")
                            }
                            NavigationLink(value: "smaliViewer") {
                                navLabel("Smali 代码", "chevron.left.forwardslash.chevron.right", "\(appState.smaliFiles.count) 个文件")
                            }
                            NavigationLink(value: "soAnalysis") {
                                navLabel("SO 库分析", "square.stack.3d.up", "\(appState.soFiles.count) 个 SO 库")
                            }
                            NavigationLink(value: "arscViewer") {
                                navLabel("ARSC 资源", "tablecells", "\(appState.arscFiles.count) 个资源")
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 0.5))

                        GlassSectionHeader(title: "项目管理", icon: "gearshape.2.fill")
                        VStack(spacing: 8) {
                            NavigationLink(value: "projectManager") {
                                navLabel("项目管理", "folder.badge.gearshape", "导出、清理")
                            }
                            NavigationLink(value: "reverseEngineering") {
                                navLabel("逆向工程", "arrow.triangle.2.circlepath", "反编译工具")
                            }
                            NavigationLink(value: "terminal") {
                                navLabel("终端", "terminal", "命令行")
                            }
                            NavigationLink(value: "newProject") {
                                navLabel("新建项目", "plus.rectangle.on.folder", "创建新分析项目")
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 0.5))

                        FileListView()
                    }
                }
                .padding()
            }
            .navigationTitle("项目")
        }
    }

    private func navLabel(_ title: String, _ icon: String, _ subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 28).foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .medium)).foregroundColor(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
    }
}

// MARK: - Tools Tab View (with proper navigation)
struct ToolsTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    GlassSectionHeader(title: "实用工具", icon: "wrench.and.screwdriver.fill")
                    VStack(spacing: 8) {
                        NavigationLink(value: "ideEditor") {
                            toolLabel("IDE 编辑器", "curlybraces", "代码编辑，语法高亮")
                        }
                        NavigationLink(value: "certManager") {
                            toolLabel("证书管理", "signature", "查看签名证书")
                        }
                        NavigationLink(value: "filePreview") {
                            toolLabel("文件预览", "doc.text.magnifyingglass", "预览文件内容")
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 0.5))

                    GlassSectionHeader(title: "配置与帮助", icon: "gearshape.fill")
                    VStack(spacing: 8) {
                        NavigationLink(value: "envConfig") {
                            toolLabel("环境配置", "building.2", "SDK/NDK 路径")
                        }
                        NavigationLink(value: "settings") {
                            toolLabel("主题设置", "paintpalette", "外观与编辑器")
                        }
                        NavigationLink(value: "about") {
                            toolLabel("关于应用", "info.circle", "版本与致谢")
                        }
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

    private func toolLabel(_ title: String, _ icon: String, _ subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 28).foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .medium)).foregroundColor(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
    }
}

// MARK: - AI Assistant View
struct AIAssistantView: View {
    @EnvironmentObject var appState: AppState
    @State private var showChat = false
    @State private var showConfig = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassSectionHeader(title: "AI 智能助手", icon: "bolt.circle.fill")
                VStack(spacing: 12) {
                    GlassNavRow(title: "AI 对话", icon: "message.fill", subtitle: "智能对话分析") {
                        showChat = true
                    }
                    GlassNavRow(title: "AI 配置", icon: "gearshape.2.fill", subtitle: "API 密钥和模型") {
                        showConfig = true
                    }
                    GlassNavRow(title: "代码分析", icon: "chevron.left.forwardslash.chevron.right", subtitle: "AI 辅助分析代码") {}
                    GlassNavRow(title: "安全审计", icon: "shield.checkered", subtitle: "AI 驱动安全检测") {}
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
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.thinMaterial))
                }
            }
        }
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