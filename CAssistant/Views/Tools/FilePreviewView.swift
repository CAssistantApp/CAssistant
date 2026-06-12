import SwiftUI

// MARK: - 文件预览视图
struct FilePreviewView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var searchText: String = ""
    @State private var selectedFile: FileNode?
    @State private var fileNodes: [FileNode] = FileNode.sampleTree
    @State private var expandedNodes: Set<UUID> = []
    @State private var previewContent: String = ""
    @State private var showSearchBar: Bool = false
    
    var body: some View {
        GlassSplitView {
            // 左侧：文件树
            fileTreeSidebar
            
            // 右侧：文件预览
            previewPanel
        }
        .navigationTitle("文件预览")
        .background(Color.clear)
        .onAppear {
            // 默认选中第一个文件展开
            if let first = fileNodes.first {
                expandedNodes.insert(first.id)
            }
        }
    }
    
    // MARK: - 文件树侧边栏
    private var fileTreeSidebar: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("搜索文件...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
            
            // 文件树
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(filteredNodes) { node in
                        FileTreeNodeView(
                            node: node,
                            selectedFile: $selectedFile,
                            expandedNodes: $expandedNodes,
                            searchText: searchText,
                            onSelect: { fileNode in
                                loadFileContent(fileNode)
                            }
                        )
                    }
                }
                .padding(8)
            }
        }
        .frame(minWidth: 240, idealWidth: 280, maxWidth: 320)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 预览面板
    private var previewPanel: some View {
        VStack(spacing: 0) {
            if let file = selectedFile {
                // 文件信息栏
                GlassCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: file.icon)
                                    .foregroundStyle(.tint)
                                Text(file.name)
                                    .font(.headline)
                            }
                            
                            HStack(spacing: 16) {
                                Label(file.fileSize, systemImage: "arrow.up.doc")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Label(file.fileType, systemImage: "doc.text")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Label(file.path, systemImage: "folder")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                
                // 文件内容预览
                ScrollView([.horizontal, .vertical]) {
                    Text(previewContent)
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
                .padding()
            } else {
                // 未选择文件提示
                VStack(spacing: 16) {
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 60))
                        .foregroundStyle(.tertiary)
                    Text("请从左侧选择一个文件")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("浏览和预览APK内的文件内容")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - 过滤后的节点
    private var filteredNodes: [FileNode] {
        if searchText.isEmpty {
            return fileNodes
        }
        return fileNodes.compactMap { node in
            filterNode(node, query: searchText)
        }
    }
    
    private func filterNode(_ node: FileNode, query: String) -> FileNode? {
        let nameMatch = node.name.localizedCaseInsensitiveContains(query)
        var matchedChildren: [FileNode] = []
        
        for child in node.children {
            if let filtered = filterNode(child, query: query) {
                matchedChildren.append(filtered)
            }
        }
        
        if nameMatch || !matchedChildren.isEmpty {
            var result = node
            result.children = matchedChildren
            return result
        }
        return nil
    }
    
    // MARK: - 加载文件内容
    private func loadFileContent(_ file: FileNode) {
        selectedFile = file
        previewContent = file.sampleContent
    }
}

// MARK: - 文件节点
struct FileNode: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let fileSize: String
    let fileType: String
    let icon: String
    let isDirectory: Bool
    var children: [FileNode]
    let sampleContent: String
    
    init(name: String, path: String, fileSize: String = "", fileType: String = "", icon: String, isDirectory: Bool, children: [FileNode] = [], sampleContent: String = "") {
        self.name = name
        self.path = path
        self.fileSize = fileSize
        self.fileType = fileType
        self.icon = icon
        self.isDirectory = isDirectory
        self.children = children
        self.sampleContent = sampleContent
    }
    
    static let sampleTree: [FileNode] = [
        FileNode(
            name: "res",
            path: "/res",
            icon: "folder",
            isDirectory: true,
            children: [
                FileNode(
                    name: "layout",
                    path: "/res/layout",
                    icon: "folder",
                    isDirectory: true,
                    children: [
                        FileNode(name: "activity_main.xml", path: "/res/layout/activity_main.xml", fileSize: "2.3 KB", fileType: "XML", icon: "doc.xml", isDirectory: false, sampleContent: """
                        <?xml version="1.0" encoding="utf-8"?>
                        <LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
                            android:layout_width="match_parent"
                            android:layout_height="match_parent"
                            android:orientation="vertical">
                            
                            <TextView
                                android:id="@+id/titleText"
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:text="Hello World"
                                android:textSize="18sp" />
                                
                            <Button
                                android:id="@+id/btnSubmit"
                                android:layout_width="match_parent"
                                android:layout_height="48dp"
                                android:text="提交" />
                        </LinearLayout>
                        """),
                        FileNode(name: "content_view.xml", path: "/res/layout/content_view.xml", fileSize: "1.8 KB", fileType: "XML", icon: "doc.xml", isDirectory: false, sampleContent: """
                        <?xml version="1.0" encoding="utf-8"?>
                        <ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
                            android:layout_width="match_parent"
                            android:layout_height="match_parent">
                            <LinearLayout
                                android:layout_width="match_parent"
                                android:layout_height="wrap_content"
                                android:orientation="vertical">
                                <TextView ... />
                            </LinearLayout>
                        </ScrollView>
                        """)
                    ]
                ),
                FileNode(
                    name: "drawable",
                    path: "/res/drawable",
                    icon: "folder",
                    isDirectory: true,
                    children: [
                        FileNode(name: "ic_launcher.png", path: "/res/drawable/ic_launcher.png", fileSize: "12.5 KB", fileType: "PNG", icon: "photo", isDirectory: false, sampleContent: "[二进制文件 - 图片]"),
                        FileNode(name: "bg_main.xml", path: "/res/drawable/bg_main.xml", fileSize: "0.5 KB", fileType: "XML", icon: "doc.xml", isDirectory: false, sampleContent: """
                        <?xml version="1.0" encoding="utf-8"?>
                        <shape xmlns:android="http://schemas.android.com/apk/res/android">
                            <gradient android:startColor="#FF6200" android:endColor="#FF3700"/>
                            <corners android:radius="8dp"/>
                        </shape>
                        """)
                    ]
                ),
                FileNode(name: "values", path: "/res/values", icon: "folder", isDirectory: true, children: [
                    FileNode(name: "strings.xml", path: "/res/values/strings.xml", fileSize: "3.2 KB", fileType: "XML", icon: "doc.xml", isDirectory: false, sampleContent: """
                    <?xml version="1.0" encoding="utf-8"?>
                    <resources>
                        <string name="app_name">MyApp</string>
                        <string name="welcome">欢迎使用</string>
                        <string name="submit">提交</string>
                        <string name="cancel">取消</string>
                    </resources>
                    """),
                    FileNode(name: "colors.xml", path: "/res/values/colors.xml", fileSize: "0.3 KB", fileType: "XML", icon: "doc.xml", isDirectory: false, sampleContent: """
                    <?xml version="1.0" encoding="utf-8"?>
                    <resources>
                        <color name="primary">#FF6200EE</color>
                        <color name="secondary">#FF3700B3</color>
                        <color name="background">#FFFFFFFF</color>
                    </resources>
                    """)
                ])
            ]
        ),
        FileNode(
            name: "smali",
            path: "/smali",
            icon: "folder",
            isDirectory: true,
            children: [
                FileNode(
                    name: "com",
                    path: "/smali/com",
                    icon: "folder",
                    isDirectory: true,
                    children: [
                        FileNode(
                            name: "example",
                            path: "/smali/com/example",
                            icon: "folder",
                            isDirectory: true,
                            children: [
                                FileNode(name: "MainActivity.smali", path: "/smali/com/example/MainActivity.smali", fileSize: "4.5 KB", fileType: "Smali", icon: "chevron.left.forwardslash.chevron.right", isDirectory: false, sampleContent: """
                                .class public Lcom/example/app/MainActivity;
                                .super Landroid/app/Activity;
                                
                                .method protected onCreate(Landroid/os/Bundle;)V
                                    .registers 3
                                    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V
                                    const v0, 0x7f0a001c
                                    invoke-virtual {p0, v0}, Lcom/example/app/MainActivity;->setContentView(I)V
                                    return-void
                                .end method
                                
                                .method public onButtonClick(Landroid/view/View;)V
                                    .registers 2
                                    const-string v0, "Button Clicked"
                                    invoke-static {v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
                                    return-void
                                .end method
                                """),
                                FileNode(name: "Utils.smali", path: "/smali/com/example/Utils.smali", fileSize: "2.1 KB", fileType: "Smali", icon: "chevron.left.forwardslash.chevron.right", isDirectory: false, sampleContent: """
                                .class public Lcom/example/app/Utils;
                                .super Ljava/lang/Object;
                                
                                .method public static formatDate(Ljava/util/Date;)Ljava/lang/String;
                                    .registers 3
                                    new-instance v0, Ljava/text/SimpleDateFormat;
                                    const-string v1, "yyyy-MM-dd"
                                    invoke-direct {v0, v1}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;)V
                                    invoke-virtual {v0, p0}, Ljava/text/DateFormat;->format(Ljava/util/Date;)Ljava/lang/String;
                                    move-result-object v0
                                    return-object v0
                                .end method
                                """)
                            ]
                        )
                    ]
                )
            ]
        ),
        FileNode(
            name: "AndroidManifest.xml",
            path: "/AndroidManifest.xml",
            fileSize: "1.5 KB",
            fileType: "XML",
            icon: "doc.xml",
            isDirectory: false,
            sampleContent: """
            <?xml version="1.0" encoding="utf-8"?>
            <manifest xmlns:android="http://schemas.android.com/apk/res/android"
                package="com.example.app"
                android:versionCode="1"
                android:versionName="1.0.0">
                
                <uses-permission android:name="android.permission.INTERNET" />
                <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
                
                <application
                    android:allowBackup="true"
                    android:icon="@mipmap/ic_launcher"
                    android:label="@string/app_name"
                    android:theme="@style/Theme.MyApp">
                    
                    <activity android:name=".MainActivity">
                        <intent-filter>
                            <action android:name="android.intent.action.MAIN" />
                            <category android:name="android.intent.category.LAUNCHER" />
                        </intent-filter>
                    </activity>
                </application>
            </manifest>
            """
        ),
        FileNode(
            name: "classes.dex",
            path: "/classes.dex",
            fileSize: "1.2 MB",
            fileType: "DEX",
            icon: "doc.text.magnifyingglass",
            isDirectory: false,
            sampleContent: "[二进制文件 - DEX 字节码，请使用Dex查看器浏览]"
        )
    ]
}

// MARK: - 文件树节点视图
private struct FileTreeNodeView: View {
    let node: FileNode
    @Binding var selectedFile: FileNode?
    @Binding var expandedNodes: Set<UUID>
    let searchText: String
    let onSelect: (FileNode) -> Void
    
    private var isExpanded: Bool {
        expandedNodes.contains(node.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                if node.isDirectory {
                    if isExpanded {
                        expandedNodes.remove(node.id)
                    } else {
                        expandedNodes.insert(node.id)
                    }
                } else {
                    selectedFile = node
                    onSelect(node)
                }
            }) {
                HStack(spacing: 6) {
                    if node.isDirectory {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 10)
                    } else {
                        Spacer().frame(width: 10)
                    }
                    
                    Image(systemName: node.icon)
                        .font(.caption)
                        .foregroundStyle(node.isDirectory ? .accentColor : .secondary)
                        .frame(width: 16)
                    
                    Text(node.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    if !node.isDirectory {
                        Text(node.fileSize)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(selectedFile?.id == node.id ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.clear))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(selectedFile?.id == node.id ? Color.accentColor.opacity(0.3) : .clear, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            
            if node.isDirectory && isExpanded {
                ForEach(node.children) { child in
                    FileTreeNodeView(
                        node: child,
                        selectedFile: $selectedFile,
                        expandedNodes: $expandedNodes,
                        searchText: searchText,
                        onSelect: onSelect
                    )
                    .padding(.leading, 16)
                }
            }
        }
    }
}