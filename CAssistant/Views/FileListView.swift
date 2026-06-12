import SwiftUI

struct FileListView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var expandedPaths: Set<String> = []

    private var rootEntries: [FileEntry] {
        buildFileTree(from: appState.files)
    }

    private var filteredRootEntries: [FileEntry] {
        if searchText.isEmpty {
            return rootEntries
        }
        return filterEntries(rootEntries, matching: searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            if appState.files.isEmpty {
                emptyStateView
            } else {
                // 搜索栏
                GlassSearchBar(text: $searchText, placeholder: "搜索文件...")
                    .padding(8)

                // 文件统计
                fileStatsHeader

                // 文件列表
                if filteredRootEntries.isEmpty {
                    VStack {
                        Spacer()
                        Text("未找到匹配的文件")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredRootEntries) { entry in
                            if entry.isDirectory {
                                directorySection(entry)
                            } else {
                                fileRow(entry, level: 0)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("文件列表")
        .onAppear {
            // 默认展开根目录
            for entry in rootEntries where entry.isDirectory {
                expandedPaths.insert(entry.path)
            }
        }
    }

    // MARK: - File Stats Header
    private var fileStatsHeader: some View {
        HStack(spacing: 12) {
            statBadge(label: "文件", value: "\(appState.files.count)", icon: "doc.on.doc", color: .blue)
            statBadge(label: "DEX", value: "\(appState.dexFiles.count)", icon: "cube", color: .orange)
            statBadge(label: "Smali", value: "\(appState.smaliFiles.count)", icon: "chevron.left.forwardslash.chevron.right", color: .purple)
            statBadge(label: "SO", value: "\(appState.soFiles.count)", icon: "square.stack.3d.up", color: .green)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func statBadge(label: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Directory Section
    private func directorySection(_ entry: FileEntry) -> AnyView {
        AnyView(
        Section {
            if expandedPaths.contains(entry.path) {
                ForEach(entry.children) { child in
                    if child.isDirectory {
                        directorySection(child)
                    } else {
                        fileRow(child, level: nestingLevel(for: child.path))
                    }
                }
            }
        } header: {
            Button {
                withAnimation {
                    if expandedPaths.contains(entry.path) {
                        expandedPaths.remove(entry.path)
                    } else {
                        expandedPaths.insert(entry.path)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: expandedPaths.contains(entry.path) ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(width: 12)

                    Image(systemName: expandedPaths.contains(entry.path) ? "folder.fill" : "folder")
                        .foregroundColor(.accentColor)
                        .frame(width: 16)

                    Text(entry.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(entry.children.count) 项")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
            }
            .buttonStyle(.plain)
        }
        )
    }

    // MARK: - File Row
    private func fileRow(_ entry: FileEntry, level: Int) -> some View {
        HStack(spacing: 6) {
            // 缩进
            if level > 0 {
                Spacer()
                    .frame(width: CGFloat(level) * 16)
            }

            Image(systemName: fileIcon(for: entry.name))
                .font(.caption)
                .foregroundColor(fileColor(for: entry.name))
                .frame(width: 16)

            Text(entry.name)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()

            if entry.size > 0 {
                Text(formatFileSize(entry.size))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.thinMaterial)
        )
    }

    // MARK: - File Tree Building
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

                if let existing = pathMap[currentPath] {
                    continue
                }

                let entry = isLast ? file : FileEntry(
                    name: component,
                    path: currentPath,
                    size: 0,
                    isDirectory: true
                )

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

    private func nestingLevel(for path: String) -> Int {
        let components = path.components(separatedBy: "/").filter { !$0.isEmpty }
        return max(0, components.count - 1)
    }

    // MARK: - Filtering
    private func filterEntries(_ entries: [FileEntry], matching query: String) -> [FileEntry] {
        entries.compactMap { entry in
            if entry.name.localizedCaseInsensitiveContains(query) {
                return entry
            }
            if entry.isDirectory {
                let filteredChildren = filterEntries(entry.children, matching: query)
                if !filteredChildren.isEmpty {
                    var copy = entry
                    copy.children = filteredChildren
                    return copy
                }
            }
            return nil
        }
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
        case "png", "jpg", "jpeg", "webp", "gif": return "photo"
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
        case "png", "jpg", "jpeg", "webp", "gif": return .pink
        case "json": return .yellow
        case "rsa", "dsa", "ec": return .red
        default: return .secondary
        }
    }

    // MARK: - Helpers
    private func formatFileSize(_ size: Int64) -> String {
        if size < 1024 { return "\(size) B" }
        if size < 1024 * 1024 { return String(format: "%.1f KB", Double(size) / 1024) }
        return String(format: "%.1f MB", Double(size) / (1024 * 1024))
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

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
}

// MARK: - Preview
struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        FileListView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}