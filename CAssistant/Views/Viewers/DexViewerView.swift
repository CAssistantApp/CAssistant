import SwiftUI

// MARK: - Dex 类信息模型
private struct DexClassInfo: Identifiable {
    let id = UUID()
    let name: String
    let package: String
    let simpleName: String
    let methods: [DexMethodInfo]
    let fields: [DexFieldInfo]
    let accessFlags: String
    let superClass: String
    let interfaces: [String]
}

private struct DexMethodInfo: Identifiable {
    let id = UUID()
    let name: String
    let returnType: String
    let parameters: [String]
    let accessFlags: String
}

private struct DexFieldInfo: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let accessFlags: String
    let value: String?
}

// MARK: - 包分组
private struct PackageGroup: Identifiable {
    let id = UUID()
    let name: String
    let classes: [DexClassInfo]
}

// MARK: - DexViewerView
struct DexViewerView: View {
    @EnvironmentObject private var appState: AppState

    @State private var searchText = ""
    @State private var selectedClass: DexClassInfo?
    @State private var selectedPackage: String?
    @State private var expandedPackages: Set<String> = []
    @State private var showOnlyMethods = false
    @State private var showOnlyFields = false

    // 模拟 Dex 类数据（按包分组）
    private let mockPackages: [PackageGroup] = [
        PackageGroup(name: "com.example.app", classes: [
            DexClassInfo(name: "com.example.app.MainActivity", package: "com.example.app",
                         simpleName: "MainActivity",
                         methods: [
                            DexMethodInfo(name: "onCreate", returnType: "void", parameters: ["android.os.Bundle"], accessFlags: "protected"),
                            DexMethodInfo(name: "onStart", returnType: "void", parameters: [], accessFlags: "protected"),
                            DexMethodInfo(name: "onResume", returnType: "void", parameters: [], accessFlags: "protected"),
                            DexMethodInfo(name: "onPause", returnType: "void", parameters: [], accessFlags: "protected"),
                            DexMethodInfo(name: "onStop", returnType: "void", parameters: [], accessFlags: "protected"),
                            DexMethodInfo(name: "onDestroy", returnType: "void", parameters: [], accessFlags: "protected"),
                            DexMethodInfo(name: "onClick", returnType: "void", parameters: ["android.view.View"], accessFlags: "public"),
                            DexMethodInfo(name: "initViews", returnType: "void", parameters: [], accessFlags: "private"),
                            DexMethodInfo(name: "loadData", returnType: "void", parameters: [], accessFlags: "private"),
                            DexMethodInfo(name: "showToast", returnType: "void", parameters: ["java.lang.String"], accessFlags: "private"),
                         ],
                         fields: [
                            DexFieldInfo(name: "TAG", type: "java.lang.String", accessFlags: "private static final", value: "\"MainActivity\""),
                            DexFieldInfo(name: "binding", type: "com.example.app.databinding.ActivityMainBinding", accessFlags: "private", value: nil),
                            DexFieldInfo(name: "userViewModel", type: "com.example.app.viewmodel.UserViewModel", accessFlags: "private", value: nil),
                            DexFieldInfo(name: "networkState", type: "com.example.app.util.NetworkState", accessFlags: "private", value: nil),
                            DexFieldInfo(name: "sInstance", type: "com.example.app.MainActivity", accessFlags: "private static", value: nil),
                         ], accessFlags: "public", superClass: "androidx.appcompat.app.AppCompatActivity",
                         interfaces: ["android.view.View.OnClickListener"]),
            DexClassInfo(name: "com.example.app.MainActivity$1", package: "com.example.app",
                         simpleName: "MainActivity$1",
                         methods: [
                            DexMethodInfo(name: "run", returnType: "void", parameters: [], accessFlags: "public"),
                         ],
                         fields: [
                            DexFieldInfo(name: "this$0", type: "com.example.app.MainActivity", accessFlags: "final synthetic", value: nil),
                         ], accessFlags: "public", superClass: "java.lang.Object",
                         interfaces: ["java.lang.Runnable"]),
        ]),
        PackageGroup(name: "com.example.app.utils", classes: [
            DexClassInfo(name: "com.example.app.utils.StringUtils", package: "com.example.app.utils",
                         simpleName: "StringUtils",
                         methods: [
                            DexMethodInfo(name: "isEmpty", returnType: "boolean", parameters: ["java.lang.String"], accessFlags: "public static"),
                            DexMethodInfo(name: "isNotEmpty", returnType: "boolean", parameters: ["java.lang.String"], accessFlags: "public static"),
                            DexMethodInfo(name: "capitalize", returnType: "java.lang.String", parameters: ["java.lang.String"], accessFlags: "public static"),
                            DexMethodInfo(name: "trimToEmpty", returnType: "java.lang.String", parameters: ["java.lang.String"], accessFlags: "public static"),
                         ],
                         fields: [
                            DexFieldInfo(name: "EMPTY", type: "java.lang.String", accessFlags: "public static final", value: "\"\""),
                         ], accessFlags: "public", superClass: "java.lang.Object",
                         interfaces: []),
            DexClassInfo(name: "com.example.app.utils.NetworkUtils", package: "com.example.app.utils",
                         simpleName: "NetworkUtils",
                         methods: [
                            DexMethodInfo(name: "isNetworkAvailable", returnType: "boolean", parameters: ["android.content.Context"], accessFlags: "public static"),
                            DexMethodInfo(name: "getNetworkType", returnType: "java.lang.String", parameters: ["android.content.Context"], accessFlags: "public static"),
                            DexMethodInfo(name: "isWifiConnected", returnType: "boolean", parameters: ["android.content.Context"], accessFlags: "public static"),
                            DexMethodInfo(name: "getIPAddress", returnType: "java.lang.String", parameters: [], accessFlags: "public static"),
                         ],
                         fields: [
                            DexFieldInfo(name: "TAG", type: "java.lang.String", accessFlags: "private static final", value: "\"NetworkUtils\""),
                            DexFieldInfo(name: "sNetworkState", type: "com.example.app.util.NetworkState", accessFlags: "private static", value: nil),
                         ], accessFlags: "public", superClass: "java.lang.Object",
                         interfaces: []),
        ]),
        PackageGroup(name: "com.example.app.model", classes: [
            DexClassInfo(name: "com.example.app.model.UserInfo", package: "com.example.app.model",
                         simpleName: "UserInfo",
                         methods: [
                            DexMethodInfo(name: "<init>", returnType: "void", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "<init>", returnType: "void", parameters: ["java.lang.String", "java.lang.String", "java.lang.String"], accessFlags: "public"),
                            DexMethodInfo(name: "getUserId", returnType: "java.lang.String", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "setUserId", returnType: "void", parameters: ["java.lang.String"], accessFlags: "public"),
                            DexMethodInfo(name: "getUsername", returnType: "java.lang.String", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "setUsername", returnType: "void", parameters: ["java.lang.String"], accessFlags: "public"),
                            DexMethodInfo(name: "getEmail", returnType: "java.lang.String", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "setEmail", returnType: "void", parameters: ["java.lang.String"], accessFlags: "public"),
                            DexMethodInfo(name: "isVip", returnType: "boolean", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "setVip", returnType: "void", parameters: ["boolean"], accessFlags: "public"),
                            DexMethodInfo(name: "toString", returnType: "java.lang.String", parameters: [], accessFlags: "public"),
                         ],
                         fields: [
                            DexFieldInfo(name: "userId", type: "java.lang.String", accessFlags: "private", value: nil),
                            DexFieldInfo(name: "username", type: "java.lang.String", accessFlags: "private", value: nil),
                            DexFieldInfo(name: "email", type: "java.lang.String", accessFlags: "private", value: nil),
                            DexFieldInfo(name: "avatarUrl", type: "java.lang.String", accessFlags: "private", value: nil),
                            DexFieldInfo(name: "age", type: "int", accessFlags: "private", value: "0"),
                            DexFieldInfo(name: "isVip", type: "boolean", accessFlags: "private", value: "false"),
                            DexFieldInfo(name: "tags", type: "java.util.List", accessFlags: "private", value: nil),
                         ], accessFlags: "public", superClass: "java.lang.Object",
                         interfaces: []),
            DexClassInfo(name: "com.example.app.model.UserInfo$Builder", package: "com.example.app.model",
                         simpleName: "UserInfo$Builder",
                         methods: [
                            DexMethodInfo(name: "<init>", returnType: "void", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "setUserId", returnType: "com.example.app.model.UserInfo.Builder", parameters: ["java.lang.String"], accessFlags: "public"),
                            DexMethodInfo(name: "setUsername", returnType: "com.example.app.model.UserInfo.Builder", parameters: ["java.lang.String"], accessFlags: "public"),
                            DexMethodInfo(name: "build", returnType: "com.example.app.model.UserInfo", parameters: [], accessFlags: "public"),
                         ],
                         fields: [
                            DexFieldInfo(name: "userId", type: "java.lang.String", accessFlags: "private", value: nil),
                            DexFieldInfo(name: "username", type: "java.lang.String", accessFlags: "private", value: nil),
                         ], accessFlags: "public", superClass: "java.lang.Object",
                         interfaces: []),
        ]),
        PackageGroup(name: "android.support.v4.app", classes: [
            DexClassInfo(name: "android.support.v4.app.Fragment", package: "android.support.v4.app",
                         simpleName: "Fragment",
                         methods: [
                            DexMethodInfo(name: "<init>", returnType: "void", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "getActivity", returnType: "android.support.v4.app.FragmentActivity", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "getView", returnType: "android.view.View", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "getResources", returnType: "android.content.res.Resources", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "getString", returnType: "java.lang.String", parameters: ["int"], accessFlags: "public"),
                            DexMethodInfo(name: "isAdded", returnType: "boolean", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "isVisible", returnType: "boolean", parameters: [], accessFlags: "public"),
                            DexMethodInfo(name: "onCreateView", returnType: "android.view.View", parameters: ["android.view.LayoutInflater", "android.view.ViewGroup", "android.os.Bundle"], accessFlags: "public"),
                            DexMethodInfo(name: "onViewCreated", returnType: "void", parameters: ["android.view.View", "android.os.Bundle"], accessFlags: "public"),
                            DexMethodInfo(name: "onActivityCreated", returnType: "void", parameters: ["android.os.Bundle"], accessFlags: "public"),
                         ],
                         fields: [
                            DexFieldInfo(name: "USE_DEFAULT_TRANSITION", type: "java.lang.Object", accessFlags: "static final", value: nil),
                            DexFieldInfo(name: "mAdded", type: "boolean", accessFlags: "", value: "false"),
                            DexFieldInfo(name: "mFragmentId", type: "int", accessFlags: "", value: "0"),
                            DexFieldInfo(name: "mContainerId", type: "int", accessFlags: "", value: "0"),
                            DexFieldInfo(name: "mTag", type: "java.lang.String", accessFlags: "", value: nil),
                            DexFieldInfo(name: "mView", type: "android.view.View", accessFlags: "", value: nil),
                            DexFieldInfo(name: "mFragmentManager", type: "android.support.v4.app.FragmentManagerImpl", accessFlags: "", value: nil),
                         ], accessFlags: "public", superClass: "java.lang.Object",
                         interfaces: ["android.content.ComponentCallbacks", "android.view.View.OnCreateContextMenuListener"]),
        ]),
    ]

    // 搜索过滤后的包
    private var filteredPackages: [PackageGroup] {
        if searchText.isEmpty {
            return mockPackages
        }
        return mockPackages.compactMap { group in
            let filteredClasses = group.classes.filter { cls in
                cls.simpleName.localizedCaseInsensitiveContains(searchText) ||
                cls.name.localizedCaseInsensitiveContains(searchText) ||
                cls.methods.contains(where: { $0.name.localizedCaseInsensitiveContains(searchText) }) ||
                cls.fields.contains(where: { $0.name.localizedCaseInsensitiveContains(searchText) })
            }
            if filteredClasses.isEmpty {
                return nil
            }
            return PackageGroup(name: group.name, classes: filteredClasses)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            toolbarView

            // 主内容
            HSplitView {
                // 类结构树
                classTreeView
                    .frame(minWidth: 280)

                // 类详情
                if let cls = selectedClass {
                    classDetailView(cls: cls)
                } else {
                    emptyDetailView
                }
            }
        }
        .glassBackground()
    }

    // MARK: - 工具栏
    private var toolbarView: some View {
        HStack {
            Text("Dex 结构查看器")
                .font(.title2.bold())

            Spacer()

            // 搜索
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索类/方法/字段...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))
            .frame(width: 240)

            HStack(spacing: 4) {
                Toggle(isOn: $showOnlyMethods) {
                    Image(systemName: "function")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .glassButtonStyle()

                Toggle(isOn: $showOnlyFields) {
                    Image(systemName: "text.alignleft")
                        .font(.caption)
                }
                .toggleStyle(.button)
                .glassButtonStyle()
            }

            GlassButton(title: "统计", icon: "number") {
                // 统计功能
            }
        }
        .padding()
        .glassCard()
    }

    // MARK: - 类结构树
    private var classTreeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                GlassSectionHeader(title: "类结构树 (\(totalClassCount) 类)", systemImage: "tree")
                Spacer()
                Text("\(filteredPackages.count) 包")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(filteredPackages) { group in
                        packageSection(group: group)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func packageSection(group: PackageGroup) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            // 包名行
            Button {
                withAnimation {
                    if expandedPackages.contains(group.name) {
                        expandedPackages.remove(group.name)
                    } else {
                        expandedPackages.insert(group.name)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: expandedPackages.contains(group.name) ? "chevron.down" : "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Image(systemName: "package")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(group.name)
                        .font(.system(size: 13, design: .monospaced))
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(group.classes.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.regularMaterial)
                        )
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
            }
            .buttonStyle(.plain)

            // 类列表
            if expandedPackages.contains(group.name) {
                ForEach(group.classes) { cls in
                    Button {
                        selectedClass = cls
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: accessFlagIcon(cls.accessFlags))
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(cls.simpleName)
                                .font(.system(size: 12, design: .monospaced))
                                .lineLimit(1)
                            Spacer()
                            Text("\(cls.methods.count)M \(cls.fields.count)F")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 24)
                        .padding(.vertical, 4)
                        .padding(.trailing, 8)
                        .background(
                            selectedClass?.id == cls.id ?
                                RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.2)) :
                                nil
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 类详情
    private func classDetailView(cls: DexClassInfo) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 类信息卡片
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "类信息", systemImage: "info.circle.fill")

                        GlassInfoRow(label: "类名", value: cls.name, icon: "doc.text")
                        GlassInfoRow(label: "访问标志", value: cls.accessFlags, icon: "lock.shield")
                        GlassInfoRow(label: "父类", value: cls.superClass, icon: "arrow.triangle.branch")
                        if !cls.interfaces.isEmpty {
                            GlassInfoRow(label: "接口", value: cls.interfaces.joined(separator: "\n"), icon: "square.split.diagonal")
                        }
                    }
                }

                // 方法列表
                if !showOnlyFields {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            GlassSectionHeader(title: "方法列表 (\(cls.methods.count))", systemImage: "function")

                            ForEach(cls.methods) { method in
                                methodRow(method)
                            }
                        }
                    }
                }

                // 字段列表
                if !showOnlyMethods {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            GlassSectionHeader(title: "字段列表 (\(cls.fields.count))", systemImage: "text.alignleft")

                            ForEach(cls.fields) { field in
                                fieldRow(field)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func methodRow(_ method: DexMethodInfo) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "function")
                .font(.caption)
                .foregroundColor(.purple)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(method.name)
                    .font(.system(size: 13, design: .monospaced))
                    .fontWeight(.medium)

                Text("(\(method.parameters.isEmpty ? "" : method.parameters.joined(separator: ", "))) -> \(method.returnType)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(method.accessFlags)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.ultraThinMaterial)
                )
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
        )
    }

    private func fieldRow(_ field: DexFieldInfo) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "text.alignleft")
                .font(.caption)
                .foregroundColor(.green)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(field.name)
                    .font(.system(size: 13, design: .monospaced))
                    .fontWeight(.medium)

                Text("\(field.type)\(field.value != nil ? " = \(field.value!)" : "")")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(field.accessFlags)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.ultraThinMaterial)
                )
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
        )
    }

    // MARK: - 空详情
    private var emptyDetailView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tree")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            Text("从左侧选择一个类查看详情")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("支持按包名分组浏览类结构")
                .font(.caption)
                .foregroundColor(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 辅助
    private var totalClassCount: Int {
        mockPackages.reduce(0) { $0 + $1.classes.count }
    }

    private func accessFlagIcon(_ flags: String) -> String {
        if flags.contains("private") { return "lock.fill" }
        if flags.contains("protected") { return "lock.open" }
        return "doc.text"
    }
}