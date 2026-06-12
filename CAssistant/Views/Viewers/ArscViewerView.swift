import SwiftUI

// MARK: - 资源条目模型
private struct ArscResourceItem: Identifiable {
    let id = UUID()
    let name: String
    let type: ArscResourceType
    let value: String
    let qualifier: String  // 限定符 (如 mdpi, hdpi, default)
}

// MARK: - 资源类型
private enum ArscResourceType: String, CaseIterable {
    case string = "string"
    case drawable = "drawable"
    case layout = "layout"
    case color = "color"
    case dimen = "dimen"
    case style = "style"
    case anim = "anim"
    case menu = "menu"
    case raw = "raw"
    case integer = "integer"
    case bool = "bool"
    case id = "id"
    case array = "array"
    case attr = "attr"
    case plurals = "plurals"

    var icon: String {
        switch self {
        case .string: return "textformat"
        case .drawable: return "photo"
        case .layout: return "rectangle.split.3x3"
        case .color: return "paintpalette"
        case .dimen: return "ruler"
        case .style: return "paintbrush"
        case .anim: return "play"
        case .menu: return "menucard"
        case .raw: return "doc"
        case .integer: return "number"
        case .bool: return "switch.2"
        case .id: return "number"
        case .array: return "list.bullet"
        case .attr: return "gearshape"
        case .plurals: return "text.word.spacing"
        }
    }

    var color: Color {
        switch self {
        case .string: return .green
        case .drawable: return .blue
        case .layout: return .orange
        case .color: return .purple
        case .dimen: return .teal
        case .style: return .pink
        case .anim: return .yellow
        case .menu: return .indigo
        case .raw: return .gray
        case .integer: return .red
        case .bool: return .cyan
        case .id: return .mint
        case .array: return .brown
        case .attr: return .primary
        case .plurals: return .secondary
        }
    }
}

// MARK: - ArscViewerView
struct ArscViewerView: View {
    @EnvironmentObject private var appState: AppState

    @State private var searchText = ""
    @State private var selectedType: ArscResourceType? = nil
    @State private var selectedResource: ArscResourceItem?
    @State private var showResourceDetail = false

    // 模拟资源数据
    private let mockResources: [ArscResourceItem] = {
        var items: [ArscResourceItem] = []

        // String 资源
        let strings = ["app_name", "hello_world", "ok", "cancel", "confirm",
                       "settings", "about", "version", "exit", "save",
                       "delete", "edit", "share", "loading", "error_network",
                       "error_empty", "retry", "home", "profile", "login"]
        for s in strings {
            items.append(ArscResourceItem(name: s, type: .string, value: s.capitalized.replacingOccurrences(of: "_", with: " "), qualifier: "default"))
        }
        // 增加一些多语言
        items.append(ArscResourceItem(name: "app_name", type: .string, value: "CAssistant", qualifier: "en"))
        items.append(ArscResourceItem(name: "app_name", type: .string, value: "CAssistant", qualifier: "zh"))
        items.append(ArscResourceItem(name: "hello_world", type: .string, value: "Hello World", qualifier: "en"))
        items.append(ArscResourceItem(name: "hello_world", type: .string, value: "你好世界", qualifier: "zh"))

        // Drawable 资源
        let drawables = ["ic_launcher", "ic_launcher_round", "ic_notification",
                         "bg_splash", "bg_card", "ic_arrow_right",
                         "ic_search", "ic_menu", "ic_close", "ic_back",
                         "ic_share", "ic_settings", "selector_button",
                         "shape_rounded_rect", "divider"]
        for d in drawables {
            items.append(ArscResourceItem(name: d, type: .drawable, value: "res/drawable/\(d).xml", qualifier: "default"))
        }

        // Layout 资源
        let layouts = ["activity_main", "activity_splash", "fragment_home",
                       "fragment_profile", "dialog_loading", "item_list",
                       "item_grid", "layout_header", "layout_footer",
                       "view_empty_state", "view_error", "toolbar_custom"]
        for l in layouts {
            items.append(ArscResourceItem(name: l, type: .layout, value: "res/layout/\(l).xml", qualifier: "default"))
        }

        // Color 资源
        let colors: [(String, String)] = [
            ("colorPrimary", "#FF6200EE"), ("colorPrimaryDark", "#FF3700B3"),
            ("colorAccent", "#FF03DAC5"), ("textPrimary", "#FF000000"),
            ("textSecondary", "#FF666666"), ("background", "#FFFFFFFF"),
            ("surface", "#FFFFFFFF"), ("error", "#FFB00020"),
            ("onPrimary", "#FFFFFFFF"), ("dividerColor", "#1F000000"),
        ]
        for (name, value) in colors {
            items.append(ArscResourceItem(name: name, type: .color, value: value, qualifier: "default"))
        }

        // Dimen 资源
        let dimenValues: [(String, String)] = [
            ("app_icon_size", "48dp"), ("padding_small", "8dp"),
            ("padding_medium", "16dp"), ("padding_large", "24dp"),
            ("corner_radius", "12dp"), ("elevation", "4dp"),
            ("text_size_small", "12sp"), ("text_size_body", "14sp"),
            ("text_size_title", "18sp"), ("text_size_headline", "24sp"),
        ]
        for (name, value) in dimenValues {
            items.append(ArscResourceItem(name: name, type: .dimen, value: value, qualifier: "default"))
        }

        // Style 资源
        let styles = ["AppTheme", "AppTheme.Light", "AppTheme.Dark",
                      "Widget.Button", "Widget.Card", "TextAppearance.Title",
                      "TextAppearance.Body", "AlertDialogTheme"]
        for s in styles {
            items.append(ArscResourceItem(name: s, type: .style, value: "<style name=\"\(s)\">", qualifier: "default"))
        }

        // Integer 资源
        let ints: [(String, String)] = [
            ("max_retry_count", "3"), ("connection_timeout", "30000"),
            ("page_size", "20"), ("animation_duration", "300"),
            ("max_cache_size", "10485760"),
        ]
        for (name, value) in ints {
            items.append(ArscResourceItem(name: name, type: .integer, value: value, qualifier: "default"))
        }

        // Bool 资源
        items.append(ArscResourceItem(name: "is_debug", type: .bool, value: "true", qualifier: "default"))
        items.append(ArscResourceItem(name: "enable_analytics", type: .bool, value: "false", qualifier: "default"))
        items.append(ArscResourceItem(name: "use_https", type: .bool, value: "true", qualifier: "default"))

        // Anim 资源
        let anims = ["fade_in", "fade_out", "slide_in_left", "slide_out_right",
                     "scale_in", "scale_out", "rotate", "bounce"]
        for a in anims {
            items.append(ArscResourceItem(name: a, type: .anim, value: "res/anim/\(a).xml", qualifier: "default"))
        }

        // Menu 资源
        let menus = ["menu_main", "menu_settings", "menu_context",
                     "menu_drawer", "menu_popup"]
        for m in menus {
            items.append(ArscResourceItem(name: m, type: .menu, value: "res/menu/\(m).xml", qualifier: "default"))
        }

        // Id 资源
        items.append(ArscResourceItem(name: "action_search", type: .id, value: "@+id/action_search", qualifier: "default"))
        items.append(ArscResourceItem(name: "action_settings", type: .id, value: "@+id/action_settings", qualifier: "default"))

        // Array 资源
        items.append(ArscResourceItem(name: "country_codes", type: .array, value: "[\"us\", \"cn\", \"jp\", \"kr\"]", qualifier: "default"))
        items.append(ArscResourceItem(name: "supported_locales", type: .array, value: "[\"en\", \"zh\", \"ja\"]", qualifier: "default"))

        return items
    }()

    // 类型统计
    private var typeCounts: [ArscResourceType: Int] {
        Dictionary(grouping: mockResources, by: { $0.type }).mapValues { $0.count }
    }

    // 过滤后的资源
    private var filteredResources: [ArscResourceItem] {
        var items = mockResources
        if let type = selectedType {
            items = items.filter { $0.type == type }
        }
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.value.localizedCaseInsensitiveContains(searchText)
            }
        }
        return items
    }

    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            toolbarView

            // 主内容
            HSplitView {
                // 左侧：类型筛选 + 资源列表
                VStack(spacing: 0) {
                    resourceTypeFilter
                    resourceListView
                }
                .frame(minWidth: 320)

                // 右侧：资源详情
                if let resource = selectedResource {
                    resourceDetailView(resource: resource)
                } else {
                    emptyDetailView
                }
            }
        }
        .glassBackground()
        .sheet(isPresented: $showResourceDetail) {
            if let resource = selectedResource {
                resourceDetailSheet(resource: resource)
            }
        }
    }

    // MARK: - 工具栏
    private var toolbarView: some View {
        HStack {
            Text("资源表查看器")
                .font(.title2.bold())

            Spacer()

            // 搜索
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索资源名称或值...", text: $searchText)
                    .textFieldStyle(.plain)
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

            GlassButton(title: "统计", icon: "number") {
                // 统计
            }
        }
        .padding()
        .glassCard()
    }

    // MARK: - 资源类型筛选
    private var resourceTypeFilter: some View {
        VStack(alignment: .leading, spacing: 4) {
            GlassSectionHeader(title: "资源类型", systemImage: "line.3.horizontal.decrease.circle")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    // 全部
                    Button {
                        withAnimation { selectedType = nil }
                    } label: {
                        VStack(spacing: 2) {
                            Text("全部")
                                .font(.caption)
                            Text("\(mockResources.count)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedType == nil ? Color.accentColor.opacity(0.3) : .regularMaterial)
                        )
                    }
                    .buttonStyle(.plain)

                    ForEach(ArscResourceType.allCases, id: \.self) { type in
                        Button {
                            withAnimation { selectedType = type }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: type.icon)
                                    .font(.caption)
                                Text(type.rawValue)
                                    .font(.caption)
                                if let count = typeCounts[type] {
                                    Text("\(count)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedType == type ? type.color.opacity(0.3) : .regularMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedType == type ? type.color : .clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - 资源列表
    private var resourceListView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                GlassSectionHeader(title: "资源列表 (\(filteredResources.count))", systemImage: "list.bullet")
                Spacer()
            }
            .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredResources) { item in
                        Button {
                            selectedResource = item
                            showResourceDetail = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: item.type.icon)
                                    .font(.caption)
                                    .foregroundColor(item.type.color)
                                    .frame(width: 20)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.primary)
                                    Text(item.value)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                if item.qualifier != "default" {
                                    Text(item.qualifier)
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                }

                                Text(item.type.rawValue)
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
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    // MARK: - 资源详情（内嵌）
    private func resourceDetailView(resource: ArscResourceItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "资源详情", systemImage: "info.circle.fill")

                        GlassInfoRow(label: "资源名称", value: resource.name, icon: "tag")
                        GlassInfoRow(label: "资源类型", value: resource.type.rawValue, icon: resource.type.icon)
                        GlassInfoRow(label: "资源值", value: resource.value, icon: "text.quote")
                        GlassInfoRow(label: "限定符", value: resource.qualifier, icon: "globe")

                        if resource.type == .color {
                            HStack(spacing: 12) {
                                Text("颜色预览")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorFromHex(resource.value))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.regularMaterial)
                            )
                        }
                    }
                }

                // 使用该资源的文件
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        GlassSectionHeader(title: "引用位置", systemImage: "link")

                        ForEach(0..<3) { i in
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("@\(resource.type.rawValue)/\(resource.name)")
                                    .font(.system(size: 12, design: .monospaced))
                                Spacer()
                            }
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.regularMaterial)
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - 资源详情 Sheet
    private func resourceDetailSheet(resource: ArscResourceItem) -> some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "资源详情", systemImage: "info.circle")

            GlassInfoRow(label: "名称", value: resource.name, icon: "tag")
            GlassInfoRow(label: "类型", value: resource.type.rawValue, icon: resource.type.icon)
            GlassInfoRow(label: "值", value: resource.value, icon: "text.quote")
            GlassInfoRow(label: "限定符", value: resource.qualifier, icon: "globe")

            Spacer()

            GlassButton(title: "关闭", icon: "xmark") {
                showResourceDetail = false
            }
        }
        .padding()
        .frame(width: 360, height: 400)
        .glassBackground()
    }

    // MARK: - 空详情
    private var emptyDetailView: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintpalette")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            Text("选择一个资源查看详情")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("支持按类型筛选和搜索资源")
                .font(.caption)
                .foregroundColor(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 辅助
    private func colorFromHex(_ hex: String) -> Color {
        var hexStr = hex
        if hexStr.hasPrefix("#") {
            hexStr = String(hexStr.dropFirst())
        }
        if hexStr.count == 8 {
            hexStr = String(hexStr.dropFirst(2))
        }
        guard let value = UInt64(hexStr, radix: 16) else {
            return .gray
        }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}