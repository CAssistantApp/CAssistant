import SwiftUI

struct ApkAnalyzerView: View {
    @EnvironmentObject var appState: AppState
    @State private var showFilePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // APK 基本信息卡片
                if !appState.apkInfo.packageName.isEmpty {
                    apkInfoCard
                }

                // 分析进度
                if appState.isAnalyzing {
                    progressSection
                }

                // 分析日志
                if !appState.analysisLog.isEmpty {
                    logSection
                }

                // 空状态提示
                if appState.apkInfo.packageName.isEmpty && !appState.isAnalyzing {
                    emptyStateView
                }

                // 快速导航
                if !appState.apkInfo.packageName.isEmpty && !appState.isAnalyzing {
                    quickNavigationSection
                }
            }
            .padding()
        }
        .navigationTitle("分析")
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.data, .zip]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                Task { await appState.parseAPK(url) }
            case .failure(let error):
                appState.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - APK Info Card
    private var apkInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "APK 基本信息", icon: "app.badge")

            VStack(spacing: 8) {
                GlassInfoRow(label: "包名", value: appState.apkInfo.packageName, icon: "shippingbox")
                GlassInfoRow(label: "版本", value: "\(appState.apkInfo.versionName) (\(appState.apkInfo.versionCode))", icon: "number")
                GlassInfoRow(label: "文件大小", value: formatFileSize(appState.apkInfo.fileSize), icon: "doc")
                GlassInfoRow(label: "DEX 数量", value: "\(appState.apkInfo.dexCount)", icon: "cube")
                GlassInfoRow(label: "最低 SDK", value: "API \(appState.apkInfo.minSdkVersion)", icon: "arrow.down")
                GlassInfoRow(label: "目标 SDK", value: "API \(appState.apkInfo.targetSdkVersion)", icon: "arrow.up")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "分析进度", icon: "arrow.triangle.2.circlepath")

            VStack(spacing: 12) {
                HStack {
                    ProgressView()
                        .scaleEffect(1.0)
                    Text("正在解析...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(appState.analysisProgress * 100))%")
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.accentColor)
                }

                GlassProgressBar(progress: appState.analysisProgress, color: .accentColor)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Log Section
    private var logSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "分析日志", icon: "text.alignleft")

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(appState.analysisLog.enumerated()), id: \.offset) { index, log in
                            HStack(spacing: 8) {
                                Text("\(index + 1)")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(.tertiary)
                                    .frame(width: 28, alignment: .trailing)
                                Text(log)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .id(index)
                        }
                    }
                    .padding(8)
                }
                .frame(maxHeight: 250)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.08), lineWidth: 0.5)
                )
                .onChange(of: appState.analysisLog.count) { _ in
                    if let last = appState.analysisLog.indices.last {
                        withAnimation {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "ant.circle")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("请导入 APK 文件")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text("点击右上角导入按钮，选择 APK 文件开始分析")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            GlassButton(title: "选择文件", icon: "doc.badge.plus", color: .accentColor) {
                showFilePicker = true
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Quick Navigation
    private var quickNavigationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "快速导航", icon: "arrow.triangle.turn.up.right.diamond")

            VStack(spacing: 8) {
                GlassNavRow(title: "权限分析", icon: "shield.checkered", subtitle: "\(appState.permissions.count) 个权限") {
                    // Navigation handled by parent
                }
                GlassNavRow(title: "证书信息", icon: "signature", subtitle: "\(appState.certificates.count) 个证书") {
                    // Navigation handled by parent
                }
                GlassNavRow(title: "组件分析", icon: "square.grid.3x3", subtitle: "\(appState.components.count) 个组件") {
                    // Navigation handled by parent
                }
                GlassNavRow(title: "类结构", icon: "cube.transparent", subtitle: "\(appState.classes.count) 个类") {
                    // Navigation handled by parent
                }
                GlassNavRow(title: "文件浏览", icon: "folder", subtitle: "\(appState.files.count) 个文件") {
                    // Navigation handled by parent
                }
                GlassNavRow(title: "AndroidManifest", icon: "doc.text", subtitle: "查看清单文件") {
                    // Navigation handled by parent
                }
            }
        }
    }

    // MARK: - Helpers
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// MARK: - Preview
struct ApkAnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        ApkAnalyzerView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}