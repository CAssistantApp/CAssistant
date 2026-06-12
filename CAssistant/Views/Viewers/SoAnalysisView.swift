import SwiftUI

// MARK: - ELF 文件信息模型
private struct ELFInfo {
    var architecture: String = ""
    var fileSize: String = ""
    var fileType: String = ""
    var endianness: String = ""
    var entryPoint: String = ""
    var sectionCount: Int = 0
    var symbolCount: Int = 0

    var symbols: [ELFSymbol] = []
    var dependencies: [String] = []
}

private struct ELFSymbol: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let size: String
    let type: ELFSymbolType
    let binding: String
    let visibility: String
    let section: String
}

private enum ELFSymbolType: String {
    case function = "函数"
    case object = "对象"
    case section = "节区"
    case file = "文件"
    case notype = "无类型"
    case tls = "TLS"

    var icon: String {
        switch self {
        case .function: return "f.square"
        case .object: return "o.square"
        case .section: return "s.square"
        case .file: return "doc"
        case .notype: return "questionmark.square"
        case .tls: return "lock"
        }
    }

    var color: Color {
        switch self {
        case .function: return .blue
        case .object: return .green
        case .section: return .orange
        case .file: return .gray
        case .notype: return .secondary
        case .tls: return .purple
        }
    }
}

// MARK: - SoAnalysisView
struct SoAnalysisView: View {
    @EnvironmentObject private var appState: AppState

    @State private var selectedTab: SoTab = .info
    @State private var searchText = ""
    @State private var selectedSymbol: ELFSymbol?
    @State private var showSymbolDetail = false

    // 模拟 ELF 信息
    private let elfInfo = ELFInfo(
        architecture: "ARM64 (AArch64)",
        fileSize: "1.2 MB",
        fileType: "共享目标文件 (Shared Object)",
        endianness: "小端序 (Little Endian)",
        entryPoint: "0x4F8A0",
        sectionCount: 28,
        symbolCount: 342,
        symbols: mockSymbols,
        dependencies: mockDependencies
    )

    private var filteredSymbols: [ELFSymbol] {
        if searchText.isEmpty {
            return elfInfo.symbols
        }
        return elfInfo.symbols.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.section.localizedCaseInsensitiveContains(searchText)
        }
    }

    enum SoTab: String, CaseIterable {
        case info = "基本信息"
        case symbols = "符号表"
        case dependencies = "依赖库"

        var icon: String {
            switch self {
            case .info: return "info.circle"
            case .symbols: return "list.bullet"
            case .dependencies: return "link"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            toolbarView

            // 标签页切换
            tabBar

            // 内容
            ScrollView {
                switch selectedTab {
                case .info:
                    infoContentView
                case .symbols:
                    symbolsContentView
                case .dependencies:
                    dependenciesContentView
                }
            }
        }
        .glassBackground()
        .sheet(isPresented: $showSymbolDetail) {
            if let symbol = selectedSymbol {
                symbolDetailSheet(symbol: symbol)
            }
        }
    }

    // MARK: - 工具栏
    private var toolbarView: some View {
        HStack {
            Text("SO 分析")
                .font(.title2.bold())

            Spacer()

            if selectedTab == .symbols {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("搜索符号...", text: $searchText)
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
            }

            GlassButton(title: "导出", icon: "square.and.arrow.up") {
                // 导出功能
            }
        }
        .padding()
        .glassCard()
    }

    // MARK: - 标签栏
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(SoTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation { selectedTab = tab }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.caption)
                        Text(tab.rawValue)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        selectedTab == tab ?
                            Color.accentColor.opacity(0.2) :
                            Color.clear
                    )
                    .overlay(
                        Rectangle()
                            .fill(selectedTab == tab ? Color.accentColor : Color.clear)
                            .frame(height: 2),
                        alignment: .bottom
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - 基本信息
    private var infoContentView: some View {
        LazyVStack(spacing: 16) {
            // 文件信息卡片
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    GlassSectionHeader(title: "ELF 文件信息", systemImage: "doc.text.magnifyingglass")

                    GlassInfoRow(label: "架构", value: elfInfo.architecture, icon: "cpu")
                    GlassInfoRow(label: "文件大小", value: elfInfo.fileSize, icon: "internaldrive")
                    GlassInfoRow(label: "文件类型", value: elfInfo.fileType, icon: "doc")
                    GlassInfoRow(label: "字节序", value: elfInfo.endianness, icon: "arrow.left.arrow.right")
                    GlassInfoRow(label: "入口点", value: elfInfo.entryPoint, icon: "arrow.right.doc")
                    GlassInfoRow(label: "节区数量", value: "\(elfInfo.sectionCount)", icon: "square.split.2x2")
                    GlassInfoRow(label: "符号数量", value: "\(elfInfo.symbolCount)", icon: "number")
                }
            }

            // 架构信息卡片
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    GlassSectionHeader(title: "架构详情", systemImage: "cpu")

                    HStack(spacing: 20) {
                        archBadge(title: "AArch64", icon: "cpu", color: .blue)
                        archBadge(title: "ARMv8-A", icon: "cpu.2", color: .green)
                        archBadge(title: "小端序", icon: "arrow.left.arrow.right", color: .orange)
                        archBadge(title: "64位", icon: "64.square", color: .purple)
                    }
                    .padding(.vertical, 8)
                }
            }

            // 节区统计卡片
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    GlassSectionHeader(title: "节区统计", systemImage: "chart.pie")

                    sectionStatRow(name: ".text", size: "456 KB", percent: 38)
                    sectionStatRow(name: ".data", size: "128 KB", percent: 11)
                    sectionStatRow(name: ".bss", size: "64 KB", percent: 5)
                    sectionStatRow(name: ".rodata", size: "240 KB", percent: 20)
                    sectionStatRow(name: ".dynamic", size: "32 KB", percent: 3)
                    sectionStatRow(name: "其他", size: "280 KB", percent: 23)
                }
            }
        }
        .padding()
    }

    private func archBadge(title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }

    private func sectionStatRow(name: String, size: String, percent: Int) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(name)
                    .font(.system(.body, design: .monospaced))
                Spacer()
                Text(size)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.regularMaterial)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(percent) / 100, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
    }

    // MARK: - 符号表
    private var symbolsContentView: some View {
        LazyVStack(spacing: 4) {
            // 表头
            HStack(spacing: 8) {
                Text("地址")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                Text("名称")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 150, alignment: .leading)
                Text("类型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 60)
                Text("绑定")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 60)
                Text("节区")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 80)
                Text("大小")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 60)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)

            ForEach(filteredSymbols) { symbol in
                Button {
                    selectedSymbol = symbol
                    showSymbolDetail = true
                } label: {
                    HStack(spacing: 8) {
                        Text(symbol.address)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)

                        HStack(spacing: 4) {
                            Image(systemName: symbol.type.icon)
                                .font(.caption)
                                .foregroundColor(symbol.type.color)
                            Text(symbol.name)
                                .font(.system(size: 12, design: .monospaced))
                                .lineLimit(1)
                        }
                        .frame(minWidth: 150, alignment: .leading)

                        Text(symbol.type.rawValue)
                            .font(.caption)
                            .foregroundColor(symbol.type.color)
                            .frame(width: 60)

                        Text(symbol.binding)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 60)

                        Text(symbol.section)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 80)

                        Text(symbol.size)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 60)

                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.tertiary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.regularMaterial)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }

    // MARK: - 依赖库
    private var dependenciesContentView: some View {
        LazyVStack(spacing: 12) {
            GlassSectionHeader(title: "动态链接库依赖 (\(elfInfo.dependencies.count))", systemImage: "link")
                .padding(.horizontal)

            ForEach(Array(elfInfo.dependencies.enumerated()), id: \.offset) { index, dep in
                GlassCard {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dep)
                                .font(.system(.body, design: .monospaced))
                            Text("动态库")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("已加载")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green.opacity(0.15))
                            )
                    }
                    .padding(4)
                }
            }

            // 依赖关系图提示
            GlassCard {
                VStack(spacing: 8) {
                    GlassSectionHeader(title: "依赖关系图", systemImage: "arrow.triangle.branch")
                    Text("动态库依赖关系可视化功能即将推出")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .padding()
    }

    // MARK: - 符号详情 Sheet
    private func symbolDetailSheet(symbol: ELFSymbol) -> some View {
        VStack(spacing: 16) {
            GlassSectionHeader(title: "符号详情", systemImage: "info.circle")

            GlassInfoRow(label: "符号名称", value: symbol.name, icon: "tag")
            GlassInfoRow(label: "地址", value: symbol.address, icon: "location")
            GlassInfoRow(label: "大小", value: symbol.size, icon: "arrow.up.arrow.down")
            GlassInfoRow(label: "类型", value: symbol.type.rawValue, icon: symbol.type.icon)
            GlassInfoRow(label: "绑定属性", value: symbol.binding, icon: "link")
            GlassInfoRow(label: "可见性", value: symbol.visibility, icon: "eye")
            GlassInfoRow(label: "所在节区", value: symbol.section, icon: "square.split.2x2")

            Spacer()

            GlassButton(title: "关闭", icon: "xmark") {
                showSymbolDetail = false
            }
        }
        .padding()
        .frame(width: 360, height: 480)
        .glassBackground()
    }
}

// MARK: - 模拟数据
private let mockSymbols: [ELFSymbol] = [
    ELFSymbol(name: "Java_com_example_app_MainActivity_nativeInit", address: "0x4F8A0", size: "128", type: .function, binding: "GLOBAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "Java_com_example_app_MainActivity_nativeProcess", address: "0x4F920", size: "256", type: .function, binding: "GLOBAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "Java_com_example_app_utils_NativeUtils_encrypt", address: "0x4FA50", size: "320", type: .function, binding: "GLOBAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "Java_com_example_app_utils_NativeUtils_decrypt", address: "0x4FB90", size: "288", type: .function, binding: "GLOBAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "native_hash_password", address: "0x4FCC0", size: "96", type: .function, binding: "LOCAL", visibility: "HIDDEN", section: ".text"),
    ELFSymbol(name: "native_verify_signature", address: "0x4FD20", size: "192", type: .function, binding: "LOCAL", visibility: "HIDDEN", section: ".text"),
    ELFSymbol(name: "aes_init", address: "0x4FDE0", size: "64", type: .function, binding: "LOCAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "aes_encrypt_block", address: "0x4FE20", size: "160", type: .function, binding: "LOCAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "aes_decrypt_block", address: "0x4FEC0", size: "160", type: .function, binding: "LOCAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "base64_encode", address: "0x4FF60", size: "120", type: .function, binding: "LOCAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "base64_decode", address: "0x4FFD8", size: "144", type: .function, binding: "LOCAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "init_ssl_context", address: "0x50058", size: "208", type: .function, binding: "LOCAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "g_key", address: "0x600A0", size: "32", type: .object, binding: "GLOBAL", visibility: "DEFAULT", section: ".data"),
    ELFSymbol(name: "g_iv", address: "0x600C0", size: "16", type: .object, binding: "GLOBAL", visibility: "DEFAULT", section: ".data"),
    ELFSymbol(name: "g_debug_mode", address: "0x600D0", size: "4", type: .object, binding: "GLOBAL", visibility: "DEFAULT", section: ".data"),
    ELFSymbol(name: "s_callback_table", address: "0x600D8", size: "64", type: .object, binding: "LOCAL", visibility: "HIDDEN", section: ".data"),
    ELFSymbol(name: "kAESKey", address: "0x70000", size: "256", type: .object, binding: "LOCAL", visibility: "DEFAULT", section: ".rodata"),
    ELFSymbol(name: "kErrorMessage", address: "0x70100", size: "128", type: .object, binding: "LOCAL", visibility: "DEFAULT", section: ".rodata"),
    ELFSymbol(name: "kVersionString", address: "0x70180", size: "32", type: .object, binding: "LOCAL", visibility: "DEFAULT", section: ".rodata"),
    ELFSymbol(name: "JNI_OnLoad", address: "0x4F800", size: "72", type: .function, binding: "GLOBAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "JNI_OnUnload", address: "0x4F848", size: "32", type: .function, binding: "GLOBAL", visibility: "DEFAULT", section: ".text"),
    ELFSymbol(name: "malloc", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
    ELFSymbol(name: "free", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
    ELFSymbol(name: "memcpy", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
    ELFSymbol(name: "strlen", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
    ELFSymbol(name: "strcmp", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
    ELFSymbol(name: "dlopen", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
    ELFSymbol(name: "dlsym", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
    ELFSymbol(name: "pthread_create", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
    ELFSymbol(name: "pthread_mutex_lock", address: "0x0", size: "0", type: .function, binding: "WEAK", visibility: "DEFAULT", section: "UNDEF"),
]

private let mockDependencies: [String] = [
    "libc.so (Bionic C 库)",
    "libm.so (数学库)",
    "libdl.so (动态链接库)",
    "liblog.so (Android 日志库)",
    "libjnigraphics.so (JNI 图形库)",
    "libcrypto.so (OpenSSL 加密库)",
    "libz.so (压缩库)",
    "libstdc++.so (C++ 标准库)",
    "libutils.so (Android 工具库)",
    "libcutils.so (Android C 工具库)",
]