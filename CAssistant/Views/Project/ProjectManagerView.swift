import SwiftUI

// MARK: - 项目模型
struct ProjectItem: Identifiable {
    let id = UUID()
    var name: String
    var path: String
    var type: ProjectType
    var createdAt: Date
    var files: [ProjectFileNode]
}

struct ProjectFileNode: Identifiable {
    let id = UUID()
    var name: String
    var isDirectory: Bool
    var children: [ProjectFileNode]?
}

enum ProjectType: String, CaseIterable {
    case apkReverse    = "APK逆向"
    case apkModify     = "APK修改"
    case apkDevelop    = "APK开发"
    case apkHook       = "Hook开发"

    var icon: String {
        switch self {
        case .apkReverse: return "magnifyingglass.circle"
        case .apkModify:  return "wrench.and.screwdriver"
        case .apkDevelop: return "hammer.circle"
        case .apkHook:    return "link.circle"
        }
    }
}

// MARK: - ProjectManagerView
struct ProjectManagerView: View {
    @EnvironmentObject private var appState: AppState

    @State private var projects: [ProjectItem] = []
    @State private var selectedProject: ProjectItem?
    @State private var showNewProject = false
    @State private var showFileTree = true

    // 模拟数据
    private let mockProjects: [ProjectItem] = [
        ProjectItem(
            name: "WeChatPlugin",
            path: "/Users/admin/Projects/WeChatPlugin",
            type: .apkHook,
            createdAt: Date().addingTimeInterval(-86400 * 10),
            files: [
                ProjectFileNode(name: "app", isDirectory: true, children: [
                    ProjectFileNode(name: "src", isDirectory: true, children: [
                        ProjectFileNode(name: "MainActivity.java", isDirectory: false, children: nil),
                        ProjectFileNode(name: "HookManager.java", isDirectory: false, children: nil)
                    ]),
                    ProjectFileNode(name: "res", isDirectory: true, children: [
                        ProjectFileNode(name: "layout", isDirectory: true, children: nil),
                        ProjectFileNode(name: "values", isDirectory: true, children: nil)
                    ]),
                    ProjectFileNode(name: "build.gradle", isDirectory: false, children: nil)
                ]),
                ProjectFileNode(name: "libs", isDirectory: true, children: [
                    ProjectFileNode(name: "dex2jar.jar", isDirectory: false, children: nil)
                ]),
                ProjectFileNode(name: "README.md", isDirectory: false, children: nil)
            ]
        ),
        ProjectItem(
            name: "TargetAppDecode",
            path: "/Users/admin/Projects/TargetAppDecode",
            type: .apkReverse,
            createdAt: Date().addingTimeInterval(-86400 * 3),
            files: [
                ProjectFileNode(name: "sources", isDirectory: true, children: [
                    ProjectFileNode(name: "com", isDirectory: true, children: nil)
                ]),
                ProjectFileNode(name: "smali", isDirectory: true, children: nil),
                ProjectFileNode(name: "AndroidManifest.xml", isDirectory: false, children: nil)
            ]
        ),
        ProjectItem(
            name: "ModGame",
            path: "/Users/admin/Projects/ModGame",
            type: .apkModify,
            createdAt: Date().addingTimeInterval(-86400 * 20),
            files: [
                ProjectFileNode(name: "original", isDirectory: true, children: nil),
                ProjectFileNode(name: "modified", isDirectory: true, children: nil),
                ProjectFileNode(name: "patches", isDirectory: true, children: nil)
            ]
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            toolbarView

            // 主内容区
            GlassSplitView {
                // 项目列表
                projectListView

                // 项目详情
                if let project = selectedProject {
                    projectDetailView(project: project)
                        .frame(minWidth: 400)
                } else {
                    emptyDetailView
                        .frame(minWidth: 400)
                }
            }
        }
        .glassBackground()
        .sheet(isPresented: $showNewProject) {
            NewProjectView()
        }
        .onAppear {
            projects = mockProjects
            if selectedProject == nil, let first = projects.first {
                selectedProject = first
            }
        }
    }

    // MARK: - 顶部工具栏
    private var toolbarView: some View {
        HStack {
            Text("项目管理")
                .font(.title2.bold())
                .foregroundColor(.white)

            Spacer()

            GlassButton(title: "新建项目", icon: "plus") {
                showNewProject = true
            }

            GlassButton(title: "打开项目", icon: "folder") {
                openProject()
            }

            GlassButton(title: "保存项目", icon: "square.and.arrow.down") {
                saveProject()
            }
        }
        .padding()
        .glassCard()
    }

    // MARK: - 项目列表
    private var projectListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "项目列表 (\(projects.count))")

            if projects.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.3))
                    Text("暂无项目")
                        .foregroundColor(.white.opacity(0.5))
                    GlassButton(title: "新建项目", icon: "plus") {
                        showNewProject = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(projects) { project in
                            projectRow(project)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .frame(minWidth: 280)
        .padding()
    }

    private func projectRow(_ project: ProjectItem) -> some View {
        GlassCard {
            Button {
                selectedProject = project
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: project.type.icon)
                        .font(.title2)
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(project.path)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text(project.type.rawValue)
                            .font(.caption2)
                            .foregroundColor(.blue.opacity(0.8))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formattedDate(project.createdAt))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                .padding(12)
            }
            .buttonStyle(.plain)
        }
        .overlay(
            selectedProject?.id == project.id ?
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                : nil
        )
    }

    // MARK: - 项目详情
    private func projectDetailView(project: ProjectItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 项目信息
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    GlassSectionHeader(title: "项目信息")

                    infoRow(label: "项目名称", value: project.name)
                    infoRow(label: "路径", value: project.path)
                    infoRow(label: "类型", value: project.type.rawValue)
                    infoRow(label: "创建时间", value: formattedDate(project.createdAt))
                }
                .padding()
            }

            // 文件树
            if showFileTree {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            GlassSectionHeader(title: "项目文件")
                            Spacer()
                            Button {
                                withAnimation { showFileTree.toggle() }
                            } label: {
                                Image(systemName: "eye.slash")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                        }

                        fileTreeView(nodes: project.files, level: 0)
                    }
                    .padding()
                }
            }

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private func fileTreeView(nodes: [ProjectFileNode], level: Int) -> some View {
        ForEach(nodes) { node in
            GlassListRow {
                HStack(spacing: 8) {
                    Image(systemName: node.isDirectory ? "folder" : "doc.text")
                        .foregroundColor(node.isDirectory ? .yellow.opacity(0.8) : .white.opacity(0.6))
                        .font(.system(size: 12))

                    Text(node.name)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.leading, CGFloat(level * 20))
                .padding(.vertical, 4)
            }

            if let children = node.children {
                Group {
                    fileTreeView(nodes: children, level: level + 1)
                }
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 80, alignment: .trailing)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
        }
    }

    // MARK: - 空详情
    private var emptyDetailView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.2))
            Text("请选择一个项目")
                .font(.title3)
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 辅助方法
    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm"
        fmt.locale = Locale(identifier: "zh_CN")
        return fmt.string(from: date)
    }

    private func openProject() {
        // 打开项目逻辑
    }

    private func saveProject() {
        // 保存项目逻辑
    }
}