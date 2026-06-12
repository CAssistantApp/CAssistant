import SwiftUI

// MARK: - DEX Header Info Model
struct DexHeaderInfo {
    var magic: String = ""
    var version: String = ""
    var stringCount: Int = 0
    var typeCount: Int = 0
    var protoCount: Int = 0
    var fieldCount: Int = 0
    var methodCount: Int = 0
    var classCount: Int = 0
}

// MARK: - DEX 文件查看器
struct DexViewerView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDexFile: String?
    @State private var searchText: String = ""
    @State private var headerInfo = DexHeaderInfo()
    @State private var stringTable: [String] = []
    @State private var typeList: [String] = []
    @State private var isDetailLoading = false

    var filteredDexFiles: [String] {
        if searchText.isEmpty {
            return appState.dexFiles
        }
        return appState.dexFiles.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        GlassSplitView(
            left: dexFileList,
            right: detailPanel
        )
        .navigationTitle("DEX 查看器")
    }

    // MARK: - 左侧：DEX 文件列表
    private var dexFileList: some View {
        VStack(spacing: 0) {
            GlassSectionHeader(title: "DEX 文件", icon: "cube.fill")

            GlassSearchBar(text: $searchText, placeholder: "搜索 DEX 文件...")
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

            if filteredDexFiles.isEmpty {
                emptyFileList
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredDexFiles, id: \.self) { file in
                            GlassFileTreeRow(
                                name: fileNameOnly(from: file),
                                icon: "doc.text",
                                isSelected: selectedDexFile == file,
                                level: 0,
                                action: {
                                    selectedDexFile = file
                                    loadDexDetails(file)
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
                Text("共 \(appState.dexFiles.count) 个 DEX 文件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 右侧：详情面板
    private var detailPanel: some View {
        VStack(spacing: 0) {
            if let selectedFile = selectedDexFile {
                ScrollView {
                    VStack(spacing: 16) {
                        // 文件标题
                        fileTitleView(selectedFile)

                        // DEX 头部信息
                        dexHeaderSection

                        // 字符串表
                        if !stringTable.isEmpty {
                            stringTableSection
                        }

                        // 类型列表
                        if !typeList.isEmpty {
                            typeListSection
                        }

                        // 类列表
                        if !appState.classes.isEmpty {
                            classListSection
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
            Image(systemName: "cube.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(fileNameOnly(from: file))
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("DEX 字节码文件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

    // MARK: - DEX 头部信息
    private var dexHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "DEX 文件头", icon: "info.circle.fill")

            GlassCard {
                VStack(spacing: 4) {
                    if !headerInfo.magic.isEmpty {
                        GlassInfoRow(label: "Magic", value: headerInfo.magic, icon: "sparkles")
                    }
                    if !headerInfo.version.isEmpty {
                        GlassInfoRow(label: "版本", value: headerInfo.version, icon: "number")
                    }
                    GlassInfoRow(label: "字符串数量", value: "\(headerInfo.stringCount)", icon: "text.quote")
                    GlassInfoRow(label: "类型数量", value: "\(headerInfo.typeCount)", icon: "tag")
                    GlassInfoRow(label: "原型数量", value: "\(headerInfo.protoCount)", icon: "function")
                    GlassInfoRow(label: "字段数量", value: "\(headerInfo.fieldCount)", icon: "square.grid.3x3")
                    GlassInfoRow(label: "方法数量", value: "\(headerInfo.methodCount)", icon: "curlybraces")
                    GlassInfoRow(label: "类数量", value: "\(headerInfo.classCount)", icon: "cube.transparent")
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - 字符串表
    private var stringTableSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "字符串表", icon: "text.quote")

            GlassCard {
                ScrollView {
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
                .frame(maxHeight: 200)
            }
        }
    }

    // MARK: - 类型列表
    private var typeListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "类型列表", icon: "tag.fill")

            GlassCard {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(typeList.enumerated()), id: \.offset) { index, type in
                        HStack(spacing: 8) {
                            Text("\(index)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .frame(width: 40, alignment: .trailing)
                            Text(type)
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

    // MARK: - 类列表
    private var classListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "类列表", icon: "cube.transparent.fill")

            GlassCard {
                VStack(spacing: 2) {
                    ForEach(appState.classes) { classInfo in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.accentColor)
                                Text(classInfo.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                if !classInfo.superClass.isEmpty {
                                    GlassBadge(text: classInfo.superClass.components(separatedBy: ".").last ?? classInfo.superClass, color: .blue)
                                }
                            }
                            HStack(spacing: 12) {
                                Label("\(classInfo.methods.count) 方法", systemImage: "function")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Label("\(classInfo.fields.count) 字段", systemImage: "square.grid.3x3")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.leading, 16)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        Divider()
                            .overlay(.white.opacity(0.06))
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - 空状态视图
    private var emptyFileList: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "cube")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("无 DEX 文件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("请导入包含 DEX 的 APK 文件")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptySelectionView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "cube.transparent")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("选择 DEX 文件")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("从左侧列表中选择一个 DEX 文件查看详情")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers
    private func fileNameOnly(from path: String) -> String {
        URL(fileURLWithPath: path).lastPathComponent
    }

    private func loadDexDetails(_ filePath: String) {
        isDetailLoading = true
        // 从 DEX 文件魔法字中提取信息
        if let url = URL(string: "file://\(filePath)"),
           let handle = try? FileHandle(forReadingFrom: url) {
            defer { try? handle.close() }

            if let magicData = try? handle.read(upToCount: 8) {
                let magicBytes = [UInt8](magicData)
                if magicBytes.count >= 8 {
                    let magicHex = magicBytes.prefix(4).map { String(format: "%02X", $0) }.joined(separator: " ")
                    let _ = magicBytes[4..<8].map { String(format: "%02X", $0) }.joined()

                    headerInfo.magic = "dex\n035" == String(bytes: magicBytes.prefix(4), encoding: .ascii) ?? "" ? "DEX\n035" : magicHex
                    headerInfo.version = "035"  // Standard DEX version
                }
            }
        }

        // 使用 AXML 解析获取 DEX 信息
        headerInfo.classCount = appState.classes.count

        // 收集字符串常量
        var strings: [String] = []
        for cls in appState.classes {
            strings.append(cls.name)
            strings.append(cls.superClass)
            strings.append(contentsOf: cls.interfaces)
            strings.append(contentsOf: cls.methods)
            strings.append(contentsOf: cls.fields)
        }
        stringTable = Array(Set(strings)).sorted()

        // 收集类型
        var types: [String] = []
        for cls in appState.classes {
            types.append(cls.name)
            if !cls.superClass.isEmpty {
                types.append(cls.superClass)
            }
            types.append(contentsOf: cls.interfaces)
        }
        typeList = Array(Set(types)).sorted()

        // 估算计数
        headerInfo.stringCount = stringTable.count
        headerInfo.typeCount = typeList.count
        var totalMethods = 0
        var totalFields = 0
        var totalProtos = 0
        for cls in appState.classes {
            totalMethods += cls.methods.count
            totalFields += cls.fields.count
            // 每个方法有一个原型
            totalProtos += cls.methods.count
        }
        headerInfo.methodCount = totalMethods
        headerInfo.fieldCount = totalFields
        headerInfo.protoCount = totalProtos

        isDetailLoading = false
    }
}

// MARK: - Preview
struct DexViewerView_Previews: PreviewProvider {
    static var previews: some View {
        DexViewerView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}