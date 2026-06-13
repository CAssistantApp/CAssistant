import SwiftUI

struct EnvironmentConfigView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var localConfig = EnvironmentConfig()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Android SDK 配置
                    androidSDKSection

                    // 构建工具配置
                    buildToolsSection

                    // 反编译工具配置
                    decompileToolsSection

                    // 设置选项
                    settingsSection

                    // 操作按钮
                    actionButtons
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            .navigationTitle("开发环境配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                localConfig = appState.envConfig
            }
        }
    }

    // MARK: - Android SDK
    private var androidSDKSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "Android SDK", icon: "apple.terminal.fill")

            GlassCard {
                VStack(spacing: 0) {
                    GlassInfoRow(label: "SDK 路径", value: localConfig.sdkPath, icon: "folder.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "JDK 路径", value: localConfig.jdkPath, icon: "cup.and.saucer.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "NDK 路径", value: localConfig.ndkPath, icon: "hammer.fill")
                }
            }
        }
    }

    // MARK: - 构建工具
    private var buildToolsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "构建工具", icon: "gearshape.2.fill")

            GlassCard {
                VStack(spacing: 0) {
                    GlassInfoRow(label: "Build Tools 版本", value: localConfig.buildToolsVersion, icon: "wrench.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "Platform 版本", value: localConfig.platformVersion, icon: "square.grid.3x3.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "Gradle 版本", value: localConfig.gradleVersion, icon: "ellipsis.curlybraces")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "Kotlin 版本", value: localConfig.kotlinVersion, icon: "k.circle.fill")
                }
            }
        }
    }

    // MARK: - 反编译工具
    private var decompileToolsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "反编译工具", icon: "arrow.triangle.branch")

            GlassCard {
                VStack(spacing: 0) {
                    GlassInfoRow(label: "ApkTool 版本", value: localConfig.apkToolVersion, icon: "shippingbox.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "Dex2Jar 版本", value: localConfig.dex2jarVersion, icon: "arrow.left.arrow.right")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "JADX 版本", value: localConfig.jadxVersion, icon: "doc.plaintext.fill")
                }
            }
        }
    }

    // MARK: - 设置选项
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "设置", icon: "slider.horizontal.3")

            GlassCard {
                VStack(spacing: 0) {
                    toggleRow(title: "自动检查更新", isOn: $localConfig.enableAutoUpdate, icon: "arrow.down.app.fill")
                    Divider().background(.white.opacity(0.08))
                    toggleRow(title: "发送使用统计", isOn: $localConfig.enableAnalytics, icon: "chart.bar.fill")
                }
            }
        }
    }

    // MARK: - Toggle 行
    private func toggleRow(title: String, isOn: Binding<Bool>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - 操作按钮
    private var actionButtons: some View {
        VStack(spacing: 12) {
            GlassButton(title: "保存配置", icon: "square.and.arrow.down.fill") {
                appState.envConfig = localConfig
                dismiss()
            }

            GlassButton(title: "恢复默认", icon: "arrow.counterclockwise") {
                localConfig = EnvironmentConfig()
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Preview
struct EnvironmentConfigView_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentConfigView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}