import SwiftUI
import UniformTypeIdentifiers

// MARK: - 文件列表视图
struct FileListView: View {
    @EnvironmentObject private var appState: AppState
    
    /// 模拟文件树结构
    private let sampleFileTree: [FileItem] = [
        FileItem(name: "AndroidManifest.xml", size: "2.4 KB", type: "XML配置", icon: "doc.xml"),
        FileItem(name: "classes.dex", size: "3.2 MB", type: "DEX字节码", icon: "doc.text.magnifyingglass"),
        FileItem(name: "classes2.dex", size: "1.1 MB", type: "DEX字节码", icon: "doc.text.magnifyingglass"),
        FileItem(name: "resources.arsc", size: "456 KB", type: "编译资源", icon: "paintpalette"),
        FileItem(name: "res/", size: "2.1 MB", type: "资源目录", icon: "folder"),
        FileItem(name: "lib/armeabi-v7a/", size: "1.8 MB", type: "Native库目录", icon: "folder"),
        FileItem(name: "lib/arm64-v8a/", size: "2.2 MB", type: "Native库目录", icon: "folder"),
        FileItem(name: "lib/x86/", size: "1.6 MB", type: "Native库目录", icon: "folder"),
        FileItem(name: "lib/x86_64/", size: "1.9 MB", type: "Native库目录", icon: "folder"),
        FileItem(name: "META-INF/", size: "8 KB", type: "签名信息目录", icon: "folder"),
        FileItem(name: "META-INF/MANIFEST.MF", size: "3.2 KB", type: "清单文件", icon: "doc.text"),
        FileItem(name: "META-INF/CERT.RSA", size: "1.5 KB", type: "证书文件", icon: "certificate"),
        FileItem(name: "META-INF/CERT.SF", size: "2.1 KB", type: "签名文件", icon: "signature"),
        FileItem(name: "assets/", size: "512 KB", type: "资产目录", icon: "folder"),
        FileItem(name: "kotlin/", size: "128 KB", type: "Kotlin元数据", icon: "folder"),
    ]
    
    @State private var searchText = ""
    @State private var sortBy: SortOption = .name
    
    enum SortOption: String, CaseIterable {
        case name = "文件名"
        case size = "大小"
        case type = "类型"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索与排序栏
            HStack(spacing: 12) {
                // 搜索
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("搜索文件名...", text: $searchText)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                )
                
                // 排序
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: { sortBy = option }) {
                            HStack {
                                Text(option.rawValue)
                                if sortBy == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("排序", systemImage: "arrow.up.arrow.down")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                        )
                }
            }
            .padding()
            
            // 统计栏
            HStack {
                Text("文件总数: \(filteredFiles.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("总大小: \(totalSize)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // 文件列表
            ScrollView {
                LazyVStack(spacing: 8) {
                    if filteredFiles.isEmpty {
                        emptyFilesView
                    } else {
                        ForEach(filteredFiles) { file in
                            fileCard(file: file)
                        }
                    }
                }
                .padding()
            }
        }
        .glassBackground()
        .navigationTitle("文件列表")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 文件卡片
    private func fileCard(file: FileItem) -> some View {
        GlassCard {
            HStack(spacing: 12) {
                // 文件图标
                Image(systemName: file.type.contains("目录") ? "folder" : file.icon)
                    .font(.title2)
                    .foregroundStyle(fileTypeColor(file.type))
                    .frame(width: 32)
                
                // 文件信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(file.name)
                        .font(.body.bold())
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // 类型标签
                        Text(file.type)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(fileTypeColor(file.type).opacity(0.2))
                            )
                            .foregroundStyle(fileTypeColor(file.type))
                        
                        // 大小
                        Text(file.size)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // 更多操作
                Image(systemName: "ellipsis")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
        }
    }
    
    // MARK: - 空文件视图
    private var emptyFilesView: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 40)
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("未找到匹配的文件")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - 计算属性
    private var filteredFiles: [FileItem] {
        var files = sampleFileTree
        
        if !searchText.isEmpty {
            files = files.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch sortBy {
        case .name:
            files.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .size:
            files.sort { fileSizeValue($0.size) > fileSizeValue($1.size) }
        case .type:
            files.sort { $0.type < $1.type }
        }
        
        return files
    }
    
    private var totalSize: String {
        let sizes = sampleFileTree.map { fileSizeValue($0.size) }
        let total = sizes.reduce(0, +)
        if total < 1024 {
            return "\(total) B"
        } else if total < 1024 * 1024 {
            return String(format: "%.1f KB", Double(total) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(total) / (1024.0 * 1024.0))
        }
    }
    
    private func fileSizeValue(_ size: String) -> Double {
        if size.contains("KB") {
            return Double(size.replacingOccurrences(of: " KB", with: "")) ?? 0
        } else if size.contains("MB") {
            return (Double(size.replacingOccurrences(of: " MB", with: "")) ?? 0) * 1024
        } else if size.contains("B") {
            return Double(size.replacingOccurrences(of: " B", with: "")) ?? 0
        }
        return 0
    }
    
    private func fileTypeColor(_ type: String) -> Color {
        if type.contains("目录") { return .blue }
        if type.contains("DEX") { return .purple }
        if type.contains("XML") { return .orange }
        if type.contains("资源") { return .pink }
        if type.contains("Native") || type.contains("库") { return .green }
        if type.contains("签名") || type.contains("证书") { return .teal }
        return .secondary
    }
}

// MARK: - 文件项模型
struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let size: String
    let type: String
    let icon: String
}

// MARK: - 预览
#Preview {
    FileListView()
        .environmentObject(AppState())
}