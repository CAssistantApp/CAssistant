import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var localTheme: ThemeSettings
    @State private var showAbout = false

    init() {
        _localTheme = State(initialValue: ThemeSettings())
    }

    var body: some View {
        NavigationStack {
            List {
                themeSection
                editorSection
                aboutSection
                featuresSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
            .navigationTitle("设置")
            .onAppear {
                localTheme = appState.themeSettings
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }

    // MARK: - 主题设置
    private var themeSection: some View {
        Section {
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    GlassSectionHeader(title: "主题设置", icon: "paintpalette.fill")
                    accentColorPicker
                    Divider().background(.white.opacity(0.08)).padding(.horizontal, 16)
                    fontSizeSlider
                    Divider().background(.white.opacity(0.08)).padding(.horizontal, 16)
                    showLineNumbersToggle
                    Divider().background(.white.opacity(0.08)).padding(.horizontal, 16)
                    autoIndentToggle
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text("外观")
        }
    }

    private var accentColorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "circle.hexagongrid.fill").foregroundStyle(.secondary)
                Text("强调色").font(.system(size: 14)).foregroundStyle(.secondary)
                Spacer()
                Circle().fill(localTheme.accentColor).frame(width: 20, height: 20)
            }
            .padding(.horizontal, 16)
            HStack(spacing: 12) {
                ForEach(accentColors, id: \.name) { item in
                    colorButton(color: item.color, name: item.name)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func colorButton(color: Color, name: String) -> some View {
        Button {
            localTheme.accentColor = color
            appState.themeSettings.accentColor = color
        } label: {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(localTheme.accentColor == color ? 0.8 : 0.0), lineWidth: 2)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(localTheme.accentColor == color ? 1 : 0)
                )
        }
        .buttonStyle(.plain)
    }

    private let accentColors: [(name: String, color: Color)] = [
        ("蓝色", .blue), ("紫色", .purple), ("绿色", .green),
        ("橙色", .orange), ("红色", .red), ("粉色", .pink)
    ]

    private var fontSizeSlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "textformat.size").foregroundStyle(.secondary)
                Text("字体大小").font(.system(size: 14)).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(localTheme.fontSize))")
                    .font(.system(size: 14, design: .monospaced)).foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            Slider(value: $localTheme.fontSize, in: 12...20, step: 1)
                .onChange(of: localTheme.fontSize) { _ in
                    appState.themeSettings.fontSize = localTheme.fontSize
                }
                .padding(.horizontal, 16)
        }
    }

    private var showLineNumbersToggle: some View {
        HStack {
            Image(systemName: "list.number").foregroundStyle(.secondary)
            Text("显示行号").font(.system(size: 14)).foregroundStyle(.secondary)
            Spacer()
            Toggle("", isOn: $localTheme.showLineNumbers).labelsHidden()
                .onChange(of: localTheme.showLineNumbers) { _ in
                    appState.themeSettings.showLineNumbers = localTheme.showLineNumbers
                }
        }
        .padding(.horizontal, 16)
    }

    private var autoIndentToggle: some View {
        HStack {
            Image(systemName: "arrow.right.to.line").foregroundStyle(.secondary)
            Text("自动缩进").font(.system(size: 14)).foregroundStyle(.secondary)
            Spacer()
            Toggle("", isOn: $localTheme.autoIndent).labelsHidden()
                .onChange(of: localTheme.autoIndent) { _ in
                    appState.themeSettings.autoIndent = localTheme.autoIndent
                }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - 编辑器设置
    private var editorSection: some View {
        Section {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    GlassSectionHeader(title: "编辑器", icon: "curlybraces")
                    GlassInfoRow(label: "语法高亮", value: "Smali / XML / JSON", icon: "character.textbox")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "Tab 宽度", value: "4 空格", icon: "arrow.left.and.right")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "自动换行", value: "启用", icon: "text.append")
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text("编辑器")
        }
    }

    // MARK: - 关于
    private var aboutSection: some View {
        Section {
            GlassCard {
                VStack(spacing: 4) {
                    GlassNavRow(title: "关于 CAssistant", icon: "info.circle.fill", subtitle: "版本 3.0 - 了解更多") {
                        showAbout = true
                    }
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "应用名称", value: "CAssistant", icon: "ant.circle.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "版本", value: "3.0", icon: "number")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "Bundle ID", value: "com.cassistant.app", icon: "barcode")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "技术栈", value: "SwiftUI + iOS 16+", icon: "swift")
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("关于")
        }
    }

    // MARK: - 功能列表
    private var featuresSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                GlassSectionHeader(title: "功能列表", icon: "checklist")
                VStack(alignment: .leading, spacing: 4) {
                    featureRow("APK 解析与分析")
                    featureRow("Manifest 查看器")
                    featureRow("权限审计")
                    featureRow("签名证书检查")
                    featureRow("组件分析")
                    featureRow("Smali 代码浏览")
                    featureRow("SO 库分析")
                    featureRow("AI 智能助手")
                    featureRow("终端命令行")
                    featureRow("代码编辑器")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        } header: {
            Text("功能")
        }
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption).foregroundColor(.green)
            Text(text)
                .font(.system(size: 13)).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppState()).preferredColorScheme(.dark)
    }
}