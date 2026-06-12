import SwiftUI

struct ManifestView: View {
    @EnvironmentObject var appState: AppState
    @State private var displayMode: ManifestDisplayMode = .formatted

    enum ManifestDisplayMode: String, CaseIterable {
        case raw = "原始 XML"
        case formatted = "格式化 XML"
    }

    var body: some View {
        VStack(spacing: 0) {
            // 切换按钮
            modePicker

            // 清单概览
            if !appState.manifest.packageName.isEmpty {
                manifestOverviewCard
            }

            // XML 内容
            if displayMode == .formatted {
                xmlContentView(text: appState.manifest.formattedXML)
            } else {
                xmlContentView(text: appState.manifest.rawXML)
            }
        }
        .navigationTitle("AndroidManifest")
    }

    // MARK: - Mode Picker
    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(ManifestDisplayMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(displayMode == mode ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.clear))
                        )
                        .foregroundColor(displayMode == mode ? .accentColor : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
        )
        .padding(.horizontal)
        .padding(.top, 12)
    }

    // MARK: - Manifest Overview
    private var manifestOverviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            GlassSectionHeader(title: "清单概览", icon: "doc.text.magnifyingglass")

            HStack(spacing: 8) {
                GlassBadge(text: "包名: \(appState.manifest.packageName)", color: .blue)
                GlassBadge(text: "权限: \(appState.manifest.usesPermissions.count)", color: .orange)
                GlassBadge(text: "特性: \(appState.manifest.features.count)", color: .green)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - XML Content View
    private func xmlContentView(text: String) -> some View {
        VStack(spacing: 0) {
            if text.isEmpty {
                emptyContentView
            } else {
                ScrollView([.horizontal, .vertical]) {
                    HStack(alignment: .top, spacing: 0) {
                        // 行号
                        VStack(alignment: .trailing, spacing: 0) {
                            let lines = text.components(separatedBy: "\n")
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, _ in
                                Text("\(index + 1)")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(.tertiary)
                                    .frame(minWidth: 36, alignment: .trailing)
                                    .padding(.trailing, 8)
                                    .padding(.vertical, 1)
                            }
                        }
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)

                        // XML 内容（带高亮）
                        VStack(alignment: .leading, spacing: 0) {
                            let lines = text.components(separatedBy: "\n")
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                                highlightedXMLText(line)
                                    .padding(.vertical, 1)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.08), lineWidth: 0.5)
                )
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Highlighted XML Text
    @ViewBuilder
    private func highlightedXMLText(_ line: String) -> some View {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let highlighted = buildHighlightedXML(line: trimmed)
        Text(highlighted)
            .font(.system(size: 13, design: .monospaced))
            .textSelection(.enabled)
    }

    private func buildHighlightedXML(line: String) -> AttributedString {
        var attrString = AttributedString(line)
        attrString.foregroundColor = Color.primary

        let pairs: [(String, Color)] = [
            ("<[^>]*>", Color.purple),
            ("\"[^\"]*\"", Color.orange),
            ("android:name", Color.cyan),
            ("android:exported", Color.cyan),
            ("android:permission", Color.cyan),
            ("package=", Color.cyan),
            ("versionName=", Color.cyan),
            ("versionCode=", Color.cyan),
            ("<uses-permission", Color.yellow),
            ("<activity", Color.green),
            ("<service", Color.green),
            ("<receiver", Color.green),
            ("<provider", Color.green),
            ("<application", Color.mint),
            ("<manifest", Color.mint),
            ("<intent-filter", Color.teal),
        ]

        for (pattern, color) in pairs {
            if let range = line.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                let nsRange = NSRange(range, in: line)
                if let attrRange = Range(nsRange, in: attrString) {
                    attrString[attrRange].foregroundColor = color
                }
            }
        }

        return attrString
    }

    // MARK: - Empty Content
    private var emptyContentView: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 40)

            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text("暂无清单数据")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("请先导入并分析 APK 文件")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
struct ManifestView_Previews: PreviewProvider {
    static var previews: some View {
        ManifestView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}