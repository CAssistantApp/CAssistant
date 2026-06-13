import SwiftUI

// MARK: - ELF 数据模型
struct ELFHeaderInfo {
    var magic: String = ""
    var elfClass: String = ""
    var dataEncoding: String = ""
    var version: String = ""
    var osAbi: String = ""
    var abiVersion: String = ""
    var type: String = ""
    var machine: String = ""
    var entryPoint: String = ""
    var programHeaderOffset: String = ""
    var sectionHeaderOffset: String = ""
    var flags: String = ""
    var headerSize: String = ""
    var programHeaderEntrySize: String = ""
    var programHeaderCount: String = ""
    var sectionHeaderEntrySize: String = ""
    var sectionHeaderCount: String = ""
    var sectionStringTableIndex: String = ""
}

struct ELFSectionInfo: Identifiable {
    let id = UUID()
    var name: String = ""
    var address: String = ""
    var offset: String = ""
    var size: String = ""
    var type: String = ""
    var flags: String = ""
}

struct ELFSymbolInfo: Identifiable {
    let id = UUID()
    var name: String = ""
    var address: String = ""
    var size: String = ""
    var type: String = ""
    var bind: String = ""
}

// MARK: - SO 库分析视图
struct SoAnalysisView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSoFile: String?
    @State private var searchText: String = ""
    @State private var elfHeader = ELFHeaderInfo()
    @State private var sections: [ELFSectionInfo] = []
    @State private var symbols: [ELFSymbolInfo] = []
    @State private var neededLibs: [String] = []
    @State private var stringTable: [String] = []
    @State private var isLoading = false

    var filteredSoFiles: [String] {
        if searchText.isEmpty {
            return appState.soFiles
        }
        return appState.soFiles.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        GlassSplitView(
            left: soFileList,
            right: analysisPanel
        )
        .navigationTitle("SO 库分析")
    }

    // MARK: - 左侧：SO 文件列表
    private var soFileList: some View {
        VStack(spacing: 0) {
            GlassSectionHeader(title: "SO 库文件", icon: "square.stack.3d.up.fill")

            GlassSearchBar(text: $searchText, placeholder: "搜索 SO 文件...")
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

            if filteredSoFiles.isEmpty {
                emptyFileList
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredSoFiles, id: \.self) { file in
                            GlassFileTreeRow(
                                name: fileNameOnly(from: file),
                                icon: "shippingbox",
                                isSelected: selectedSoFile == file,
                                level: 0,
                                action: {
                                    selectedSoFile = file
                                    parseELFFile(file)
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
                Text("共 \(appState.soFiles.count) 个 SO 库")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 右侧：分析面板
    private var analysisPanel: some View {
        VStack(spacing: 0) {
            if let selectedFile = selectedSoFile {
                ScrollView {
                    VStack(spacing: 16) {
                        fileTitleView(selectedFile)

                        // ELF 文件头
                        elfHeaderSection

                        // 节区信息
                        if !sections.isEmpty {
                            sectionsSection
                        }

                        // 符号表
                        if !symbols.isEmpty {
                            symbolsSection
                        }

                        // 依赖库
                        if !neededLibs.isEmpty {
                            neededLibsSection
                        }

                        // 字符串表
                        if !stringTable.isEmpty {
                            stringTableSection
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
            Image(systemName: "shippingbox.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(fileNameOnly(from: file))
                    .font(.headline)
                    .foregroundColor(.primary)
                HStack(spacing: 8) {
                    if !elfHeader.machine.isEmpty {
                        GlassBadge(text: elfHeader.machine, color: .blue)
                    }
                    if !elfHeader.elfClass.isEmpty {
                        GlassBadge(text: elfHeader.elfClass, color: .green)
                    }
                    if !elfHeader.type.isEmpty {
                        GlassBadge(text: elfHeader.type, color: .orange)
                    }
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

    // MARK: - ELF 头部信息
    private var elfHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "ELF 文件头", icon: "info.circle.fill")

            GlassCard {
                VStack(spacing: 4) {
                    if !elfHeader.magic.isEmpty {
                        GlassInfoRow(label: "Magic", value: elfHeader.magic, icon: "sparkles")
                    }
                    if !elfHeader.elfClass.isEmpty {
                        GlassInfoRow(label: "Class", value: elfHeader.elfClass, icon: "memorychip")
                    }
                    if !elfHeader.dataEncoding.isEmpty {
                        GlassInfoRow(label: "编码", value: elfHeader.dataEncoding, icon: "arrow.left.arrow.right")
                    }
                    if !elfHeader.version.isEmpty {
                        GlassInfoRow(label: "版本", value: elfHeader.version, icon: "number")
                    }
                    if !elfHeader.osAbi.isEmpty {
                        GlassInfoRow(label: "OS/ABI", value: elfHeader.osAbi, icon: "desktopcomputer")
                    }
                    if !elfHeader.type.isEmpty {
                        GlassInfoRow(label: "类型", value: elfHeader.type, icon: "tag")
                    }
                    if !elfHeader.machine.isEmpty {
                        GlassInfoRow(label: "架构", value: elfHeader.machine, icon: "cpu")
                    }
                    if !elfHeader.entryPoint.isEmpty {
                        GlassInfoRow(label: "入口点", value: elfHeader.entryPoint, icon: "location")
                    }
                    GlassInfoRow(label: "节区数量", value: "\(sections.count)", icon: "square.grid.3x3")
                    GlassInfoRow(label: "依赖库数量", value: "\(neededLibs.count)", icon: "link")
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - 节区信息
    private var sectionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "节区信息 (\(sections.count))", icon: "square.grid.3x3.fill")

            GlassCard {
                VStack(spacing: 0) {
                    // 表头
                    sectionHeaderRow
                        .padding(.bottom, 4)

                    ForEach(sections) { section in
                        sectionRow(section)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var sectionHeaderRow: some View {
        HStack(spacing: 4) {
            Text("名称")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("地址")
                .frame(width: 70, alignment: .trailing)
            Text("偏移")
                .frame(width: 60, alignment: .trailing)
            Text("大小")
                .frame(width: 55, alignment: .trailing)
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(.tertiary)
        .padding(.horizontal, 12)
    }

    private func sectionRow(_ section: ELFSectionInfo) -> some View {
        HStack(spacing: 4) {
            Text(section.name)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(section.address)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .trailing)
            Text(section.offset)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .trailing)
            Text(section.size)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 55, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    // MARK: - 符号表
    private var symbolsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "符号表 (\(symbols.count))", icon: "function")

            GlassCard {
                VStack(spacing: 0) {
                    symbolHeaderRow
                        .padding(.bottom, 4)

                    ForEach(symbols.prefix(200)) { symbol in
                        symbolRow(symbol)
                    }
                    if symbols.count > 200 {
                        Text("... 还有 \(symbols.count - 200) 个符号")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(8)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var symbolHeaderRow: some View {
        HStack(spacing: 4) {
            Text("名称")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("类型")
                .frame(width: 50, alignment: .trailing)
            Text("绑定")
                .frame(width: 50, alignment: .trailing)
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(.tertiary)
        .padding(.horizontal, 12)
    }

    private func symbolRow(_ symbol: ELFSymbolInfo) -> some View {
        HStack(spacing: 4) {
            Text(symbol.name)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            GlassBadge(text: symbol.type, color: .blue)
            GlassBadge(text: symbol.bind, color: .green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    // MARK: - 依赖库列表
    private var neededLibsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "依赖库", icon: "link")

            GlassCard {
                VStack(spacing: 2) {
                    ForEach(Array(neededLibs.enumerated()), id: \.offset) { _, lib in
                        HStack(spacing: 8) {
                            Image(systemName: "shippingbox")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                            Text(lib)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - 字符串表
    private var stringTableSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "字符串表 (\(stringTable.count))", icon: "text.quote")

            GlassCard {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(stringTable.enumerated()), id: \.offset) { index, str in
                        HStack(spacing: 8) {
                            Text("\(index)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .frame(width: 40, alignment: .trailing)
                            Text(str)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - 空状态
    private var emptyFileList: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("无 SO 库文件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("请导入包含 SO 库的 APK 文件")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptySelectionView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("选择 SO 库文件")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("从左侧列表中选择一个 SO 库文件进行分析")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - ELF 解析
    private func fileNameOnly(from path: String) -> String {
        URL(fileURLWithPath: path).lastPathComponent
    }

    private func parseELFFile(_ filePath: String) {
        isLoading = true

        guard let url = URL(string: "file://\(filePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filePath)"),
              let handle = try? FileHandle(forReadingFrom: url) else {
            isLoading = false
            return
        }
        defer { try? handle.close() }

        // 读取 ELF 头部（前 64 字节足够获取基础信息）
        guard let headerData = try? handle.read(upToCount: 64) else {
            isLoading = false
            return
        }

        let bytes = [UInt8](headerData)
        guard bytes.count >= 16 else {
            isLoading = false
            return
        }

        // Magic: 7f 45 4c 46 = ELF
        let magicBytes = bytes[0..<4]
        elfHeader.magic = magicBytes.map { String(format: "%02X", $0) }.joined(separator: " ")

        // EI_CLASS: 32-bit (1) or 64-bit (2)
        let eiClass = bytes[4]
        elfHeader.elfClass = eiClass == 1 ? "ELF32" : eiClass == 2 ? "ELF64" : "未知"

        // EI_DATA: 1=little endian, 2=big endian
        let eiData = bytes[5]
        elfHeader.dataEncoding = eiData == 1 ? "Little Endian" : eiData == 2 ? "Big Endian" : "未知"

        // EI_VERSION
        elfHeader.version = "\(bytes[6])"

        // EI_OSABI
        let osAbi = bytes[7]
        elfHeader.osAbi = osAbiLookup(osAbi)

        let _ = eiClass == 2

        // 解析 e_type (offset depends on 32/64 bit)
        // 32-bit: e_type at offset 16 (2 bytes), 64-bit: e_type at offset 16 (2 bytes)
        let typeVal = readUInt16(bytes: bytes, offset: 16, isLittleEndian: eiData == 1)
        elfHeader.type = elfTypeLookup(typeVal)

        // e_machine at offset 18 (2 bytes)
        let machineVal = readUInt16(bytes: bytes, offset: 18, isLittleEndian: eiData == 1)
        elfHeader.machine = elfMachineLookup(machineVal)

        // 尝试读取更多的节区信息（需要解析 section header）
        // 简化处理：从文件中提取符号和字符串
        sections = []
        symbols = []
        neededLibs = []
        stringTable = []

        // 读取文件后半部分尝试提取字符串
        if let fullData = try? Data(contentsOf: url) {
            parseDynstr(from: fullData, isLittleEndian: eiData == 1)
        }

        isLoading = false
    }

    private func parseDynstr(from data: Data, isLittleEndian: Bool) {
        // 扫描 .dynstr 段中的字符串（以 NULL 结尾的字符串序列）
        var strings: [String] = []
        var currentString = ""
        let bytes = [UInt8](data)

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

        stringTable = Array(Set(strings)).sorted()

        // 提取可能的依赖库名（.so 结尾）
        neededLibs = stringTable.filter { $0.hasSuffix(".so") }
    }

    private func readUInt16(bytes: [UInt8], offset: Int, isLittleEndian: Bool) -> UInt16 {
        guard offset + 1 < bytes.count else { return 0 }
        if isLittleEndian {
            return UInt16(bytes[offset]) | (UInt16(bytes[offset + 1]) << 8)
        } else {
            return (UInt16(bytes[offset]) << 8) | UInt16(bytes[offset + 1])
        }
    }

    private func osAbiLookup(_ value: UInt8) -> String {
        switch value {
        case 0: return "System V"
        case 2: return "NetBSD"
        case 3: return "Linux"
        case 6: return "Solaris"
        case 9: return "FreeBSD"
        default: return "ABI(\(value))"
        }
    }

    private func elfTypeLookup(_ value: UInt16) -> String {
        switch value {
        case 0: return "NONE"
        case 1: return "REL"
        case 2: return "EXEC"
        case 3: return "DYN (共享库)"
        case 4: return "CORE"
        default: return "Type(\(value))"
        }
    }

    private func elfMachineLookup(_ value: UInt16) -> String {
        switch value {
        case 3: return "i386"
        case 8: return "MIPS"
        case 40: return "ARM"
        case 62: return "x86-64"
        case 183: return "AArch64"
        case 243: return "RISC-V"
        default: return "Machine(\(value))"
        }
    }
}

// MARK: - Preview
struct SoAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        SoAnalysisView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}