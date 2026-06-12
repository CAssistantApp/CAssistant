import SwiftUI

// MARK: - Smali 语法高亮配色
private struct SmaliSyntaxColors {
    static let keyword = Color.blue
    static let type = Color.purple
    static let string = Color.green
    static let comment = Color.gray
    static let number = Color.orange
    static let instruction = Color.red
    static let register = Color.teal
    static let annotation = Color.yellow
    static let `default` = Color.primary
}

// MARK: - 文件树节点
private struct SmaliFileNode: Identifiable {
    let id = UUID()
    let name: String
    let isDirectory: Bool
    let children: [SmaliFileNode]?
    let content: String?
    
    init(name: String, isDirectory: Bool, children: [SmaliFileNode]? = nil, content: String? = nil) {
        self.name = name
        self.isDirectory = isDirectory
        self.children = children
        self.content = content
    }
}

// MARK: - 代码统计
private struct SmaliCodeStats {
    var methodCount: Int = 0
    var fieldCount: Int = 0
    var annotationCount: Int = 0
    var lineCount: Int = 0
}

// MARK: - Smali 语法高亮引擎
private struct SmaliSyntaxHighlighter {
    static func highlight(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        let keywords = [".class", ".super", ".source", ".implements", ".field",
                        ".method", ".end method", ".parameter", ".locals",
                        ".registers", ".prologue", ".line", ".annotation",
                        ".end annotation", ".enum", ".interface", ".abstract",
                        ".public", ".private", ".protected", ".static",
                        ".final", ".synthetic", ".constructor", ".volatile",
                        ".transient", ".native", ".strictfp", ".synchronized",
                        ".bridge", ".varargs", ".deprecated"]
        
        let instructions = ["invoke-virtual", "invoke-super", "invoke-direct",
                            "invoke-static", "invoke-interface", "invoke-virtual/range",
                            "invoke-super/range", "invoke-direct/range",
                            "invoke-static/range", "invoke-interface/range",
                            "move", "move-result", "move-result-wide",
                            "move-result-object", "move-exception",
                            "return-void", "return", "return-wide", "return-object",
                            "const", "const/4", "const/16", "const-wide",
                            "const-string", "const-class", "new-instance",
                            "check-cast", "instance-of", "array-length",
                            "if-eq", "if-ne", "if-lt", "if-ge", "if-gt", "if-le",
                            "if-eqz", "if-nez", "if-ltz", "if-gez", "if-gtz", "if-lez",
                            "aget", "aput", "iget", "iput", "sget", "sput",
                            "goto", "packed-switch", "sparse-switch",
                            "cmp-long", "cmpl-float", "cmpg-float",
                            "monitor-enter", "monitor-exit",
                            "throw", "fill-array-data", "nop"]
        
        let lines = text.components(separatedBy: "\n")
        var lineOffset = 0
        
        for line in lines {
            let lineLength = line.count + 1 // +1 for newline
            let lineRange = NSRange(location: lineOffset, length: min(lineLength, text.count - lineOffset))
            defer { lineOffset += lineLength }
            
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 注释行
            if trimmed.hasPrefix("#") {
                if let range = Range(lineRange, in: text),
                   let attrRange = Range(lineRange, in: result) {
                    result[attrRange].foregroundColor = SmaliSyntaxColors.comment
                }
                continue
            }
            
            // 关键词匹配
            for kw in keywords {
                if trimmed.hasPrefix(kw) {
                    let kwRange = NSRange(location: lineRange.location, length: kw.count)
                    if let range = Range(kwRange, in: result) {
                        result[range].foregroundColor = SmaliSyntaxColors.keyword
                        result[range].font = .system(.body, design: .monospaced).bold()
                    }
                    break
                }
            }
            
            // 指令匹配
            for inst in instructions {
                if trimmed.hasPrefix(inst) {
                    let instRange = NSRange(location: lineRange.location, length: inst.count)
                    if let range = Range(instRange, in: result) {
                        result[range].foregroundColor = SmaliSyntaxColors.instruction
                    }
                    break
                }
            }
            
            // 寄存器高亮 (v0-p999, p0-p999)
            let pattern = try? NSRegularExpression(pattern: "[vp]\\d+")
            if let matches = pattern?.matches(in: line, range: NSRange(location: 0, length: line.count)) {
                for match in matches {
                    let adjusted = NSRange(location: lineRange.location + match.range.location, length: match.range.length)
                    if let range = Range(adjusted, in: result) {
                        result[range].foregroundColor = SmaliSyntaxColors.register
                    }
                }
            }
            
            // 字符串高亮
            let strPattern = try? NSRegularExpression(pattern: "\"[^\"]*\"")
            if let matches = strPattern?.matches(in: line, range: NSRange(location: 0, length: line.count)) {
                for match in matches {
                    let adjusted = NSRange(location: lineRange.location + match.range.location, length: match.range.length)
                    if let range = Range(adjusted, in: result) {
                        result[range].foregroundColor = SmaliSyntaxColors.string
                    }
                }
            }
        }
        
        return result
    }
}

// MARK: - SmaliViewerView
struct SmaliViewerView: View {
    @EnvironmentObject private var appState: AppState

    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedFile: SmaliFileNode?
    @State private var showFileTree = true
    @State private var showStats = false
    @State private var stats = SmaliCodeStats()

    // 模拟 Smali 文件树
    private let mockFileTree: [SmaliFileNode] = [
        SmaliFileNode(name: "com", isDirectory: true, children: [
            SmaliFileNode(name: "example", isDirectory: true, children: [
                SmaliFileNode(name: "app", isDirectory: true, children: [
                    SmaliFileNode(name: "MainActivity.smali", isDirectory: false, children: nil, content: mockMainActivity),
                    SmaliFileNode(name: "MainActivity$1.smali", isDirectory: false, children: nil, content: mockAnonymousClass),
                ]),
                SmaliFileNode(name: "utils", isDirectory: true, children: [
                    SmaliFileNode(name: "StringUtils.smali", isDirectory: false, children: nil, content: mockStringUtils),
                    SmaliFileNode(name: "NetworkUtils.smali", isDirectory: false, children: nil, content: mockNetworkUtils),
                ]),
                SmaliFileNode(name: "model", isDirectory: true, children: [
                    SmaliFileNode(name: "UserInfo.smali", isDirectory: false, children: nil, content: mockUserInfo),
                ]),
            ]),
        ]),
        SmaliFileNode(name: "android", isDirectory: true, children: [
            SmaliFileNode(name: "support", isDirectory: true, children: [
                SmaliFileNode(name: "v4", isDirectory: true, children: [
                    SmaliFileNode(name: "Fragment.smali", isDirectory: false, children: nil, content: mockFragment),
                ]),
            ]),
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            toolbarView

            // 主内容区
            GlassSplitView {
                // 文件树
                if showFileTree {
                    fileTreeView
                        .frame(minWidth: 260)
                }

                // 代码区域
                codeView
            }
        }
        .glassBackground()
    }

    // MARK: - 工具栏
    private var toolbarView: some View {
        HStack {
            Text("Smali 查看器")
                .font(.title2.bold())

            Spacer()

            // 搜索
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索代码...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
            )
            .frame(width: 240)

            Button {
                withAnimation { showFileTree.toggle() }
            } label: {
                Image(systemName: showFileTree ? "sidebar.left" : "sidebar.right")
            }
            .glassButtonStyle()

            Button {
                withAnimation { showStats.toggle() }
            } label: {
                Image(systemName: "chart.bar")
            }
            .glassButtonStyle()

            GlassButton(title: "统计", icon: "number") {
                calculateStats()
                showStats = true
            }
        }
        .padding()
        .glassCard()
    }

    // MARK: - 文件树
    private var fileTreeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "文件结构", systemImage: "folder.tree")

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(mockFileTree) { node in
                        fileTreeNodeView(node: node, level: 0)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func fileTreeNodeView(node: SmaliFileNode, level: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                if !node.isDirectory {
                    selectedFile = node
                    calculateStats()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: node.isDirectory ? "folder.fill" : "doc.text.fill")
                        .foregroundColor(node.isDirectory ? .yellow : .blue)
                        .font(.caption)
                    Text(node.name)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(selectedFile?.id == node.id ? .white : .primary)
                    Spacer()
                }
                .padding(.leading, CGFloat(level * 16) + 8)
                .padding(.vertical, 4)
                .padding(.trailing, 8)
                .background(
                    selectedFile?.id == node.id ?
                        RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.3)) :
                        nil
                )
            }
            .buttonStyle(.plain)

            if let children = node.children {
                ForEach(children) { child in
                    AnyView(fileTreeNodeView(node: child, level: level + 1))
                }
            }
        }
    }

    // MARK: - 代码显示
    private var codeView: some View {
        VStack(spacing: 0) {
            if let file = selectedFile, let content = file.content {
                // 文件头
                HStack {
                    Text(file.name)
                        .font(.system(.headline, design: .monospaced))
                    Spacer()
                    if showStats {
                        statsView
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)

                // 代码内容
                ScrollView([.horizontal, .vertical]) {
                    VStack(alignment: .leading, spacing: 0) {
                        let highlighted = SmaliSyntaxHighlighter.highlight(content)
                        Text(highlighted)
                            .font(.system(size: 13, design: .monospaced))
                            .lineSpacing(2)
                            .padding()
                    }
                    .frame(minWidth: 600, alignment: .leading)
                }
            } else {
                // 空状态
                VStack(spacing: 20) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 56))
                        .foregroundColor(.secondary)
                    Text("从左侧文件树选择一个 Smali 文件")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("文件将显示在此处，支持语法高亮")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - 统计信息
    private var statsView: some View {
        HStack(spacing: 12) {
            Label("方法: \(stats.methodCount)", systemImage: "function")
                .font(.caption)
            Label("字段: \(stats.fieldCount)", systemImage: "text.alignleft")
                .font(.caption)
            Label("注解: \(stats.annotationCount)", systemImage: "number")
                .font(.caption)
            Label("行数: \(stats.lineCount)", systemImage: "text.alignleft")
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.regularMaterial)
        )
    }

    // MARK: - 统计计算
    private func calculateStats() {
        guard let file = selectedFile, let content = file.content else { return }
        let lines = content.components(separatedBy: "\n")
        stats.lineCount = lines.count
        stats.methodCount = 0
        stats.fieldCount = 0
        stats.annotationCount = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix(".method") {
                stats.methodCount += 1
            } else if trimmed.hasPrefix(".field") {
                stats.fieldCount += 1
            } else if trimmed.hasPrefix(".annotation") {
                stats.annotationCount += 1
            }
        }
    }

    // MARK: - 弹出统计 Sheet
    private var statsSheet: some View {
        VStack(spacing: 20) {
            GlassSectionHeader(title: "代码统计", systemImage: "chart.bar.fill")
                .padding(.top)

            GlassInfoRow(label: "方法数", value: "\(stats.methodCount)", icon: "function")
            GlassInfoRow(label: "字段数", value: "\(stats.fieldCount)", icon: "text.alignleft")
            GlassInfoRow(label: "注解数", value: "\(stats.annotationCount)", icon: "number")
            GlassInfoRow(label: "总行数", value: "\(stats.lineCount)", icon: "text.alignleft")

            Spacer()
        }
        .padding()
        .frame(width: 320, height: 300)
        .glassBackground()
    }
}

// MARK: - 模拟 Smali 数据
private let mockMainActivity = """
.class public Lcom/example/app/MainActivity;
.super Landroidx/appcompat/app/AppCompatActivity;
.source "MainActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;

# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/example/app/MainActivity$NetworkCallback;
    }
.end annotation

# static fields
.field private static final TAG:Ljava/lang/String; = "MainActivity"

.field private static sInstance:Lcom/example/app/MainActivity;

# instance fields
.field private binding:Lcom/example/app/databinding/ActivityMainBinding;

.field private userViewModel:Lcom/example/app/viewmodel/UserViewModel;

.field private networkState:Lcom/example/app/util/NetworkState;

# direct methods
.method public constructor <init>()V
    .registers 1
    .prologue
    invoke-direct {p0}, Landroidx/appcompat/app/AppCompatActivity;-><init>()V
    return-void
.end method

# virtual methods
.method protected onCreate(Landroid/os/Bundle;)V
    .registers 4
    .param p1, "savedInstanceState"

    invoke-super {p0, p1}, Landroidx/appcompat/app/AppCompatActivity;->onCreate(Landroid/os/Bundle;)V

    const v0, 0x7f0a002b
    invoke-virtual {p0, v0}, Lcom/example/app/MainActivity;->setContentView(I)V

    invoke-static {p0}, Landroidx/databinding/DataBindingUtil;->setContentView(Landroid/app/Activity;)Landroidx/databinding/ViewDataBinding;

    move-result-object v0
    check-cast v0, Lcom/example/app/databinding/ActivityMainBinding;

    iput-object v0, p0, Lcom/example/app/MainActivity;->binding:Lcom/example/app/databinding/ActivityMainBinding;

    new-instance v0, Lcom/example/app/viewmodel/UserViewModel;

    invoke-direct {v0}, Lcom/example/app/viewmodel/UserViewModel;-><init>()V

    iput-object v0, p0, Lcom/example/app/MainActivity;->userViewModel:Lcom/example/app/viewmodel/UserViewModel;

    const-string v0, "Activity Created"
    invoke-static {v0}, Lcom/example/app/util/Logger;->d(Ljava/lang/String;)V

    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .registers 4
    .param p1, "v"

    iget-object v0, p0, Lcom/example/app/MainActivity;->userViewModel:Lcom/example/app/viewmodel/UserViewModel;

    invoke-virtual {v0}, Lcom/example/app/viewmodel/UserViewModel;->fetchData()V

    const-string v0, "Button Clicked"
    invoke-static {v0}, Lcom/example/app/util/Logger;->i(Ljava/lang/String;)V

    return-void
.end method

.method protected onDestroy()V
    .registers 1
    invoke-super {p0}, Landroidx/appcompat/app/AppCompatActivity;->onDestroy()V
    const/4 v0, 0x0
    iput-object v0, p0, Lcom/example/app/MainActivity;->binding:Lcom/example/app/databinding/ActivityMainBinding;
    return-void
.end method
"""

private let mockAnonymousClass = """
.class Lcom/example/app/MainActivity$1;
.super Ljava/lang/Object;
.source "MainActivity.java"

# interfaces
.implements Ljava/lang/Runnable;

# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/example/app/MainActivity;->startBackgroundTask()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

# instance fields
.field final synthetic this$0:Lcom/example/app/MainActivity;

# direct methods
.method public constructor <init>(Lcom/example/app/MainActivity;)V
    .registers 2
    iput-object p1, p0, Lcom/example/app/MainActivity$1;->this$0:Lcom/example/app/MainActivity;
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public run()V
    .registers 3
    const-string v0, "Background task running"
    invoke-static {v0}, Lcom/example/app/util/Logger;->d(Ljava/lang/String;)V
    return-void
.end method
"""

private let mockStringUtils = """
.class public Lcom/example/app/utils/StringUtils;
.super Ljava/lang/Object;
.source "StringUtils.java"

# static methods
.method public static isEmpty(Ljava/lang/String;)Z
    .registers 2
    .param p0, "str"

    if-nez p0, :cond_4

    const/4 v0, 0x1
    return v0

    :cond_4
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    return v0
.end method

.method public static capitalize(Ljava/lang/String;)Ljava/lang/String;
    .registers 4
    .param p0, "str"

    invoke-static {p0}, Lcom/example/app/utils/StringUtils;->isEmpty(Ljava/lang/String;)Z

    move-result v0
    if-eqz v0, :cond_8

    return-object p0

    :cond_8
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v1, 0x0

    invoke-virtual {p0, v1}, Ljava/lang/String;->charAt(I)C

    move-result v2

    invoke-static {v2}, Ljava/lang/Character;->toUpperCase(C)C

    move-result v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    const/4 v2, 0x1

    invoke-virtual {p0, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

# static fields
.field private static final EMPTY_STRINGS:[Ljava/lang/String;
    const-string v0, ""
    const-string v1, "null"
    filled-new-array {v0, v1}, [Ljava/lang/String;
    return-object v0
.end method
"""

private let mockNetworkUtils = """
.class public Lcom/example/app/utils/NetworkUtils;
.super Ljava/lang/Object;
.source "NetworkUtils.java"

# static fields
.field private static final TAG:Ljava/lang/String; = "NetworkUtils"

.field private static sNetworkState:Lcom/example/app/util/NetworkState;

# direct methods
.method static constructor <clinit>()V
    .registers 1
    sget-object v0, Lcom/example/app/util/NetworkState;->UNKNOWN:Lcom/example/app/util/NetworkState;
    sput-object v0, Lcom/example/app/utils/NetworkUtils;->sNetworkState:Lcom/example/app/util/NetworkState;
    return-void
.end method

.method public static isNetworkAvailable(Landroid/content/Context;)Z
    .registers 4
    .param p0, "context"

    const-string v0, "connectivity"
    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0
    check-cast v0, Landroid/net/ConnectivityManager;

    invoke-virtual {v0}, Landroid/net/ConnectivityManager;->getActiveNetworkInfo()Landroid/net/NetworkInfo;

    move-result-object v0

    if-eqz v0, :cond_14

    invoke-virtual {v0}, Landroid/net/NetworkInfo;->isConnected()Z

    move-result v0

    if-eqz v0, :cond_14

    const/4 v0, 0x1
    return v0

    :cond_14
    const/4 v0, 0x0
    return v0
.end method

.method public static getNetworkType(Landroid/content/Context;)Ljava/lang/String;
    .registers 3
    .param p0, "context"

    const-string v0, "connectivity"
    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0
    check-cast v0, Landroid/net/ConnectivityManager;

    invoke-virtual {v0}, Landroid/net/ConnectivityManager;->getActiveNetworkInfo()Landroid/net/NetworkInfo;

    move-result-object v0

    if-eqz v0, :cond_16

    invoke-virtual {v0}, Landroid/net/NetworkInfo;->getTypeName()Ljava/lang/String;

    move-result-object v0

    return-object v0

    :cond_16
    const-string v0, "NONE"
    return-object v0
.end method
"""

private let mockUserInfo = """
.class public Lcom/example/app/model/UserInfo;
.super Ljava/lang/Object;
.source "UserInfo.java"

# instance fields
.field private userId:Ljava/lang/String;

.field private username:Ljava/lang/String;

.field private email:Ljava/lang/String;

.field private avatarUrl:Ljava/lang/String;

.field private age:I

.field private isVip:Z

.field private tags:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

# direct methods
.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .registers 4
    .param p1, "userId"
    .param p2, "username"
    .param p3, "email"

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/example/app/model/UserInfo;->userId:Ljava/lang/String;
    iput-object p2, p0, Lcom/example/app/model/UserInfo;->username:Ljava/lang/String;
    iput-object p3, p0, Lcom/example/app/model/UserInfo;->email:Ljava/lang/String;
    return-void
.end method

# virtual methods
.method public getUserId()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/UserInfo;->userId:Ljava/lang/String;
    return-object v0
.end method

.method public setUserId(Ljava/lang/String;)V
    .registers 2
    .param p1, "userId"
    iput-object p1, p0, Lcom/example/app/model/UserInfo;->userId:Ljava/lang/String;
    return-void
.end method

.method public getUsername()Ljava/lang/String;
    .registers 2
    iget-object v0, p0, Lcom/example/app/model/UserInfo;->username:Ljava/lang/String;
    return-object v0
.end method

.method public setUsername(Ljava/lang/String;)V
    .registers 2
    .param p1, "username"
    iput-object p1, p0, Lcom/example/app/model/UserInfo;->username:Ljava/lang/String;
    return-void
.end method

.method public isVip()Z
    .registers 2
    iget-boolean v0, p0, Lcom/example/app/model/UserInfo;->isVip:Z
    return v0
.end method

.method public setVip(Z)V
    .registers 2
    .param p1, "vip"
    iput-boolean p1, p0, Lcom/example/app/model/UserInfo;->isVip:Z
    return-void
.end method
"""

private let mockFragment = """
.class public Landroid/support/v4/app/Fragment;
.super Ljava/lang/Object;
.source "Fragment.java"

# interfaces
.implements Landroid/content/ComponentCallbacks;
.implements Landroid/view/View$OnCreateContextMenuListener;

# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Landroid/support/v4/app/Fragment$SavedState;,
        Landroid/support/v4/app/Fragment$InstantiationException;
    }
.end annotation

# static fields
.field static final USE_DEFAULT_TRANSITION:Ljava/lang/Object;

.field private static final sClassMap:Landroid/support/v4/util/SimpleArrayMap;

# instance fields
.field mAdded:Z

.field mAllowEnterTransitionOverlap:Ljava/lang/Boolean;

.field mAllowReturnTransitionOverlap:Ljava/lang/Boolean;

.field mCalled:Z

.field mChildFragmentManager:Landroid/support/v4/app/FragmentManagerImpl;

.field mContainer:Landroid/view/ViewGroup;

.field mContainerId:I

.field mDeferStart:Z

.field mDetached:Z

.field mFragmentId:I

.field mFragmentManager:Landroid/support/v4/app/FragmentManagerImpl;

.field mFromLayout:Z

.field mHasMenu:Z

.field mHidden:Z

.field mHost:Landroid/support/v4/app/FragmentHostCallback;

.field mInLayout:Z

.field mIndex:I

.field mInnerView:Landroid/view/View;

.field mIsNewlyAdded:Z

.field mLayoutInflater:Landroid/view/LayoutInflater;

.field mMenuVisible:Z

.field mParentFragment:Landroid/support/v4/app/Fragment;

.field mRemoving:Z

.field mRestored:Z

.field mRetainInstance:Z

.field mRetaining:Z

.field mSavedFragmentState:Landroid/os/Bundle;

.field mSavedState:Landroid/util/SparseArray;

.field mState:I

.field mTag:Ljava/lang/String;

.field mTarget:Landroid/support/v4/app/Fragment;

.field mTargetIndex:I

.field mTargetRequestCode:I

.field mUserVisibleHint:Z

.field mView:Landroid/view/View;

.field mWho:Ljava/lang/String;

# direct methods
.method static constructor <clinit>()V
    .registers 1
    new-instance v0, Landroid/support/v4/util/SimpleArrayMap;
    invoke-direct {v0}, Landroid/support/v4/util/SimpleArrayMap;-><init>()V
    sput-object v0, Landroid/support/v4/app/Fragment;->sClassMap:Landroid/support/v4/util/SimpleArrayMap;
    return-void
.end method

.method public constructor <init>()V
    .registers 4
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    const/4 v0, -0x1
    iput v0, p0, Landroid/support/v4/app/Fragment;->mIndex:I
    const/4 v0, 0x0
    iput v0, p0, Landroid/support/v4/app/Fragment;->mState:I
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v0
    invoke-virtual {v0}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v0
    iput-object v0, p0, Landroid/support/v4/app/Fragment;->mWho:Ljava/lang/String;
    const/4 v0, 0x1
    iput-boolean v0, p0, Landroid/support/v4/app/Fragment;->mMenuVisible:Z
    iput-boolean v0, p0, Landroid/support/v4/app/Fragment;->mUserVisibleHint:Z
    return-void
.end method

# virtual methods
.method public getActivity()Landroid/support/v4/app/FragmentActivity;
    .registers 2
    iget-object v0, p0, Landroid/support/v4/app/Fragment;->mHost:Landroid/support/v4/app/FragmentHostCallback;

    if-nez v0, :cond_6

    const/4 v0, 0x0
    return-object v0

    :cond_6
    iget-object v0, p0, Landroid/support/v4/app/Fragment;->mHost:Landroid/support/v4/app/FragmentHostCallback;

    invoke-virtual {v0}, Landroid/support/v4/app/FragmentHostCallback;->getActivity()Landroid/app/Activity;

    move-result-object v0

    check-cast v0, Landroid/support/v4/app/FragmentActivity;

    return-object v0
.end method

.method public getView()Landroid/view/View;
    .registers 2
    iget-object v0, p0, Landroid/support/v4/app/Fragment;->mView:Landroid/view/View;
    return-object v0
.end method

.method public isAdded()Z
    .registers 2
    iget-object v0, p0, Landroid/support/v4/app/Fragment;->mHost:Landroid/support/v4/app/FragmentHostCallback;

    if-eqz v0, :cond_8

    iget-boolean v0, p0, Landroid/support/v4/app/Fragment;->mAdded:Z

    if-eqz v0, :cond_8

    const/4 v0, 0x1
    return v0

    :cond_8
    const/4 v0, 0x0
    return v0
.end method
"""