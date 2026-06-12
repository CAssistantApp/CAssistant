import SwiftUI
import UniformTypeIdentifiers

// MARK: - 类结构视图
struct ClassStructureView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var searchText = ""
    @State private var expandedPackages: Set<String> = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("搜索类名或包名...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .padding()
            
            // 类列表
            ScrollView {
                LazyVStack(spacing: 16) {
                    if let classes = appState.currentAPKInfo?.classes, !classes.isEmpty {
                        let filteredPackages = filteredPackageList(from: classes)
                        
                        if filteredPackages.isEmpty {
                            emptySearchView
                        } else {
                            ForEach(filteredPackages.sorted(by: { $0.key < $1.key }), id: \.key) { package, classList in
                                packageCard(package: package, classes: classList)
                            }
                        }
                    } else {
                        emptyClassView
                    }
                }
                .padding()
            }
        }
        .glassBackground()
        .navigationTitle("类结构")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 包卡片
    private func packageCard(package: String, classes: [String]) -> some View {
        let isExpanded = expandedPackages.contains(package)
        
        return GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                // 包名行（可点击展开/收起）
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isExpanded {
                            expandedPackages.remove(package)
                        } else {
                            expandedPackages.insert(package)
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "cube.box")
                            .font(.title3)
                            .foregroundStyle(.tint)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(package)
                                .font(.body.bold())
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Text("\(classes.count) 个类")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                // 类列表（展开时显示）
                if isExpanded {
                    Divider()
                        .opacity(0.3)
                    
                    ForEach(classes, id: \.self) { className in
                        HStack(spacing: 10) {
                            Image(systemName: "doc.text")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(className)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                        .padding(.leading, 4)
                    }
                }
            }
        }
    }
    
    // MARK: - 空类视图
    private var emptyClassView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 40)
            
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("暂无类结构信息")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("请先在APK分析页面导入并分析APK文件")
                .font(.body)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - 空搜索结果
    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 40)
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("未找到匹配的类或包")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - 过滤包列表
    private func filteredPackageList(from classes: [String: [String]]) -> [String: [String]] {
        if searchText.isEmpty {
            return classes
        }
        
        var result: [String: [String]] = [:]
        for (package, classList) in classes {
            // 包名匹配或内部类名匹配
            let matchedClasses = classList.filter { $0.localizedCaseInsensitiveContains(searchText) }
            if package.localizedCaseInsensitiveContains(searchText) || !matchedClasses.isEmpty {
                result[package] = matchedClasses.isEmpty ? classList : matchedClasses
            }
        }
        return result
    }
}

// MARK: - 预览
#Preview {
    ClassStructureView()
        .environmentObject(AppState())
}