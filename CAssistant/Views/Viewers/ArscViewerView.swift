import SwiftUI

// MARK: - ARSC 资源数据模型
struct ArscPackageInfo {
    var packageCount: Int = 0
    var typeCount: Int = 0
    var entryCount: Int = 0
    var packageName: String = ""
}

struct ArscTypeGroup: Identifiable {
    let id = UUID()
    var typeName: String = ""
    var entryCount: Int = 0
    var entries: [ArscEntry] = []
}

struct ArscEntry: Identifiable {
    let id = UUID()
    var name: String = ""
    var value: String = ""
}

// MARK: - ARSC 资源查看器
struct ArscViewerView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedArscFile: String?
    @State private var searchText: String = ""
    @State private var resourceSearchText: String = ""
    @State private var packageInfo = ArscPackageInfo()
    @State private var typeGroups: [ArscTypeGroup] = []
    @State private var selectedTypeGroup: ArscTypeGroup?
    @State private var isLoading = false

    var filteredArscFiles: [String] {
        if searchText.isEmpty {
            return appState.arscFiles
        }
        return appState.arscFiles.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var filteredTypeGroups: [ArscTypeGroup] {
        if resourceSearchText.isEmpty {
            return typeGroups
        }
        return typeGroups.compactMap { group in
            let filteredEntries = group.entries.filter {
                $0.name.localizedCaseInsensitiveContains(resourceSearchText)
            }
            if filteredEntries.isEmpty && !group.typeName.localizedCaseInsensitiveContains(resourceSearchText) {
                return nil
            }
            var copy = group
            copy.entries = filteredEntries.isEmpty ? group.entries : filteredEntries
            return copy
        }
    }

    var body: some View {
        GlassSplitView(
            left: arscFileList,
            right: resourcePanel
        )
        .navigationTitle("ARSC 资源")
    }

    // MARK: - 左侧：ARSC 文件列表
    private var arscFileList: some View {
        VStack(spacing: 0) {
            GlassSectionHeader(title: "ARSC 文件", icon: "tablecells.fill")

            GlassSearchBar(text: $searchText, placeholder: "搜索 ARSC 文件...")
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

            if filteredArscFiles.isEmpty {
                emptyFileList
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredArscFiles, id: \.self) { file in
                            GlassFileTreeRow(
                                name: fileNameOnly(from: file),
                                icon: "tablecells",
                                isSelected: selectedArscFile == file,
                                level: 0,
                                action: {
                                    selectedArscFile = file
                                    parseArscFile(file)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
            }

            // 文件统计
            HStack {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("共 \(appState.arscFiles.count) 个 ARSC 文件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 右侧：资源面板
    private var resourcePanel: some View {
        VStack(spacing: 0) {
            if let selectedFile = selectedArscFile {
                ScrollView {
                    VStack(spacing: 16) {
                        fileTitleView(selectedFile)

                        // 资源包信息
                        packageInfoSection

                        // 资源搜索
                        resourceSearchSection

                        // 资源类型列表
                        if !filteredTypeGroups.isEmpty {
                            resourceTypesSection
                        }
                    }
                    .padding()
                }
            } else {
                emptySelectionView
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 文件标题
    private func fileTitleView(_ file: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "tablecells.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(fileNameOnly(from: file))
                    .font(.headline)
                    .foregroundColor(.primary)
                HStack(spacing: 8) {
                    GlassBadge(text: "\(packageInfo.packageCount) 包", color: .blue)
                    GlassBadge(text: "\(packageInfo.typeCount) 类型", color: .green)
                    GlassBadge(text: "\(packageInfo.entryCount) 条目", color: .orange)
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    // MARK: - 资源包信息
    private var packageInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "资源包信息", icon: "shippingbox.fill")

            GlassCard {
                VStack(spacing: 4) {
                    if !packageInfo.packageName.isEmpty {
                        GlassInfoRow(label: "包名", value: packageInfo.packageName, icon: "shippingbox")
                    }
                    GlassInfoRow(label: "包数量", value: "\(packageInfo.packageCount)", icon: "cube")
                    GlassInfoRow(label: "类型数量", value: "\(packageInfo.typeCount)", icon: "square.grid.3x3")
                    GlassInfoRow(label: "条目数量", value: "\(packageInfo.entryCount)", icon: "list.bullet")
                    GlassInfoRow(label: "文件", value: fileNameOnly(from: selectedArscFile ?? ""), icon: "doc")
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - 资源搜索
    private var resourceSearchSection: some View {
        VStack(spacing: 8) {
            if !typeGroups.isEmpty {
                GlassSearchBar(text: $resourceSearchText, placeholder: "搜索资源名称...")
                    .padding(.horizontal, 8)
            }
        }
    }

    // MARK: - 资源类型列表
    private var resourceTypesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "资源类型 (\(filteredTypeGroups.count))", icon: "square.grid.3x3.fill")

            ForEach(filteredTypeGroups) { group in
                resourceTypeGroupView(group)
            }
        }
    }

    private func resourceTypeGroupView(_ group: ArscTypeGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 类型标题行
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if selectedTypeGroup?.id == group.id {
                        selectedTypeGroup = nil
                    } else {
                        selectedTypeGroup = group
                    }
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: resourceTypeIcon(for: group.typeName))
                        .foregroundColor(resourceTypeColor(for: group.typeName))
                        .frame(width: 20)
                    Text(group.typeName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    GlassBadge(text: "\(group.entryCount)", color: resourceTypeColor(for: group.typeName))
                    Image(systemName: selectedTypeGroup?.id == group.id ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.thinMaterial)
                )
            }
            .buttonStyle(.plain)

            // 展开的资源条目
            if selectedTypeGroup?.id == group.id {
                VStack(spacing: 2) {
                    ForEach(group.entries) { entry in
                        GlassInfoRow(label: entry.name, value: entry.value, icon: "circle.fill")
                            .font(.system(size: 13))
                    }
                }
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
    }

    // MARK: - 空状态
    private var emptyFileList: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tablecells")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("无 ARSC 文件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("请导入包含 ARSC 资源的 APK 文件")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptySelectionView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "tablecells")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("选择 ARSC 文件")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("从左侧列表中选择一个 ARSC 文件查看资源")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - ARSC 解析
    private func fileNameOnly(from path: String) -> String {
        URL(fileURLWithPath: path).lastPathComponent
    }

    private func parseArscFile(_ filePath: String) {
        isLoading = true

        // 读取 ARSC 文件二进制数据
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            isLoading = false
            return
        }

        let bytes = [UInt8](data)

        // 检查 ARSC 文件头 (ARSC 文件以 0x02 0x00 0x0C 0x00 开头)
        if bytes.count >= 4 {
            let _ = readUInt16(bytes: bytes, offset: 0)
            let _ = readUInt16(bytes: bytes, offset: 2)

            // headerType 应为 RES_TABLE_TYPE (0x0002)
            // 标准 ARSC 以 0x0200 开头
        }

        // 提取资源包名和字符串
        var pkgName = ""
        var strings: [String] = []

        var currentString = ""
        for byte in bytes {
            if byte == 0 {
                if currentString.count > 1 {
                    strings.append(currentString)
                }
                currentString = ""
            } else if byte >= 32 && byte < 127 {
                currentString.append(Character(UnicodeScalar(byte)))
            } else {
                if currentString.count > 1 {
                    strings.append(currentString)
                }
                currentString = ""
            }
        }

        // 尝试找到包名（通常是 com.xxx.xxx 格式）
        let packagePattern = strings.first { $0.contains(".") && $0.components(separatedBy: ".").count >= 2 }
        pkgName = packagePattern ?? (appState.apkInfo.packageName.isEmpty ? "" : appState.apkInfo.packageName)

        // 分类资源类型
        var groups: [String: [ArscEntry]] = [
            "string": [],
            "color": [],
            "dimen": [],
            "layout": [],
            "drawable": [],
            "id": [],
            "style": [],
            "bool": [],
            "integer": [],
            "array": [],
            "attr": [],
            "anim": [],
            "animator": [],
            "interpolator": [],
            "menu": [],
            "mipmap": [],
            "raw": [],
            "transition": [],
            "xml": [],
            "其他": []
        ]

        for str in strings {
            // 跳过明显的包名、版本号等
            guard !str.hasPrefix("http") && str.count > 1 && str.count < 100 else { continue }

            let entry = ArscEntry(name: str, value: extractValue(for: str))

            // 根据字符串特征分类
            let category = categorizeResource(str)
            groups[category]?.append(entry)
        }

        // 构建 typeGroups
        typeGroups = groups.compactMap { key, entries in
            guard !entries.isEmpty else { return nil }
            return ArscTypeGroup(
                typeName: key,
                entryCount: entries.count,
                entries: Array(entries.prefix(100))
            )
        }.sorted { a, b in
            // 常见类型优先
            let order: [String: Int] = [
                "string": 0, "color": 1, "dimen": 2, "drawable": 3,
                "layout": 4, "id": 5, "style": 6, "bool": 7,
                "integer": 8, "array": 9, "attr": 10, "anim": 11,
                "mipmap": 12, "menu": 13, "xml": 14, "raw": 15
            ]
            let aOrder = order[a.typeName] ?? 99
            let bOrder = order[b.typeName] ?? 99
            return aOrder < bOrder
        }

        // 资源包信息
        let totalEntries = typeGroups.reduce(0) { $0 + $1.entryCount }
        packageInfo = ArscPackageInfo(
            packageCount: 1,
            typeCount: typeGroups.count,
            entryCount: totalEntries,
            packageName: pkgName
        )

        selectedTypeGroup = nil
        isLoading = false
    }

    private func categorizeResource(_ str: String) -> String {
        let lower = str.lowercased()

        // 十六进制颜色值
        if str.count == 8 && str.allSatisfy({ $0.isHexDigit }) {
            return "color"
        }
        if str.hasPrefix("#") && str.count >= 7 && str.count <= 9 {
            return "color"
        }

        // 尺寸值
        if lower.hasSuffix("dp") || lower.hasSuffix("sp")
            || lower.hasSuffix("px") || lower.hasSuffix("dip") {
            return "dimen"
        }

        // 布尔值
        if lower == "true" || lower == "false" {
            return "bool"
        }

        // ID 格式
        if str.hasPrefix("0x") && str.count >= 6 {
            return "id"
        }

        // 纯数字
        if Int(str) != nil {
            return "integer"
        }

        // 路径格式（layout/drawable等）
        if str.contains("/") && !str.hasPrefix("/") {
            let prefix = lower.components(separatedBy: "/").first ?? ""
            let knownTypes = ["layout", "drawable", "mipmap", "anim", "animator",
                              "menu", "xml", "raw", "color", "interpolator", "transition"]
            if knownTypes.contains(prefix) {
                return prefix
            }
        }

        // 基于常见资源前缀判断
        let knownPrefixes: [String: String] = [
            "abc_": "string", "app_": "string",
            "btn_": "drawable", "ic_": "drawable", "img_": "drawable",
            "activity_": "layout", "fragment_": "layout",
            "dialog_": "layout", "item_": "layout"
        ]

        for (prefix, type) in knownPrefixes {
            if lower.hasPrefix(prefix) {
                return type
            }
        }

        // 默认为 string 类型
        return "string"
    }

    private func extractValue(for str: String) -> String {
        if str.count > 50 {
            return "\"\(str.prefix(47))...\""
        }
        return "\"\(str)\""
    }

    private func readUInt16(bytes: [UInt8], offset: Int) -> UInt16 {
        guard offset + 1 < bytes.count else { return 0 }
        return UInt16(bytes[offset]) | (UInt16(bytes[offset + 1]) << 8)
    }

    // MARK: - 资源类型图标
    private func resourceTypeIcon(for type: String) -> String {
        switch type {
        case "string": return "text.quote"
        case "color": return "paintpalette"
        case "dimen": return "ruler"
        case "layout": return "rectangle.3.group"
        case "drawable": return "photo"
        case "id": return "number"
        case "style": return "textformat"
        case "bool": return "switch.2"
        case "integer": return "number.circle"
        case "array": return "list.bullet.rectangle"
        case "attr": return "gearshape"
        case "anim": return "sparkles"
        case "mipmap": return "photo.stack"
        case "menu": return "menubar.rectangle"
        case "xml": return "chevron.left.forwardslash.chevron.right"
        case "raw": return "doc"
        default: return "questionmark.circle"
        }
    }

    private func resourceTypeColor(for type: String) -> Color {
        switch type {
        case "string": return .green
        case "color": return .purple
        case "dimen": return .blue
        case "layout": return .orange
        case "drawable": return .pink
        case "id": return .gray
        case "style": return .teal
        case "bool": return .cyan
        case "integer": return .indigo
        case "array": return .mint
        case "anim": return .yellow
        case "mipmap": return .red
        default: return .accentColor
        }
    }
}

// MARK: - Preview
struct ArscViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ArscViewerView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}