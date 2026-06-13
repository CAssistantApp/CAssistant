import SwiftUI

struct ReverseEngineeringView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText: String = ""
    @State private var searchResults: [FileEntry] = []
    @State private var isSearching: Bool = false
    @State private var showSearchResults: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 工具列表
                toolListSection

                // 字符串搜索
                searchSection

                // 搜索结果
                if showSearchResults && !searchResults.isEmpty {
                    searchResultsSection
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .navigationTitle("逆向工程")
    }

    // MARK: - 工具列表
    private var toolListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "逆向工具", icon: "arrow.triangle.2.circlepath")

            GlassCard {
                VStack(spacing: 4) {
                    NavigationLink(value: "dexViewer") {
                        GlassNavRow(
                            title: "DEX 转 Jar",
                            icon: "arrow.triangle.swap",
                            subtitle: "使用 dex2jar 将 DEX 转为 JAR 文件"
                        ) {}
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: "smaliViewer") {
                        GlassNavRow(
                            title: "Smali 编辑",
                            icon: "chevron.left.forwardslash.chevron.right",
                            subtitle: "查看和编辑 Smali 代码"
                        ) {}
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: "soAnalysis") {
                        GlassNavRow(
                            title: "SO 库分析",
                            icon: "square.stack.3d.up",
                            subtitle: "分析 Native 库的符号和依赖"
                        ) {}
                    }
                    .buttonStyle(.plain)

                    GlassNavRow(
                        title: "字符串搜索",
                        icon: "magnifyingglass.circle.fill",
                        subtitle: "在所有文件中搜索字符串"
                    ) {
                        withAnimation { showSearchResults = true }
                    }

                    NavigationLink(value: "classStructure") {
                        GlassNavRow(
                            title: "方法交叉引用",
                            icon: "arrow.triangle.branch",
                            subtitle: "查找方法的调用者和被调用者"
                        ) {}
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: "arscViewer") {
                        GlassNavRow(
                            title: "资源提取",
                            icon: "photo.on.rectangle.angled",
                            subtitle: "提取 APK 中的图片和资源文件"
                        ) {}
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - 搜索区域
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "字符串搜索", icon: "magnifyingglass.circle.fill")

            HStack(spacing: 8) {
                GlassSearchBar(text: $searchText, placeholder: "搜索 Smali/XML/TXT 文件内容...")

                GlassButton(title: "搜索", icon: "magnifyingglass", color: .accentColor) {
                    performSearch()
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - 搜索结果
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "搜索结果 (\(searchResults.count))", icon: "list.bullet")

            GlassCard {
                VStack(spacing: 2) {
                    ForEach(searchResults) { file in
                        resultRow(file)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func resultRow(_ file: FileEntry) -> some View {
        HStack(spacing: 10) {
            Image(systemName: fileIcon(for: file.name))
                .font(.caption)
                .foregroundColor(.accentColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(file.path)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(formatFileSize(file.size))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - 搜索逻辑
    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        defer { isSearching = false }

        searchResults = appState.files.filter { file in
            guard !file.isDirectory else { return false }
            let name = file.name.lowercased()
            let isMatchable = name.hasSuffix(".smali")
                || name.hasSuffix(".xml")
                || name.hasSuffix(".txt")
                || name.hasSuffix(".java")
                || name.hasSuffix(".kt")
                || name.hasSuffix(".properties")
                || name.hasSuffix(".json")

            guard isMatchable else { return false }

            // 在文件名和路径中搜索
            let fileNameMatch = name.contains(query.lowercased())
            let pathMatch = file.path.lowercased().contains(query.lowercased())

            return fileNameMatch || pathMatch
        }

        showSearchResults = true
    }

    // MARK: - 辅助方法
    private func fileIcon(for name: String) -> String {
        let lower = name.lowercased()
        if lower.hasSuffix(".smali") { return "chevron.left.forwardslash.chevron.right" }
        if lower.hasSuffix(".xml") { return "chevron.left.slash.chevron.right" }
        if lower.hasSuffix(".txt") { return "doc.text" }
        if lower.hasSuffix(".java") || lower.hasSuffix(".kt") { return "curlybraces" }
        if lower.hasSuffix(".json") { return "curlybraces" }
        if lower.hasSuffix(".properties") { return "gearshape" }
        return "doc"
    }

    private func formatFileSize(_ size: Int64) -> String {
        if size < 1024 { return "\(size) B" }
        if size < 1024 * 1024 { return String(format: "%.1f KB", Double(size) / 1024.0) }
        return String(format: "%.1f MB", Double(size) / (1024.0 * 1024.0))
    }
}

// MARK: - Preview
struct ReverseEngineeringView_Previews: PreviewProvider {
    static var previews: some View {
        ReverseEngineeringView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}