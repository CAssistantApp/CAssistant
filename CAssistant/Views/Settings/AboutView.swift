import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 应用图标和名称
                    appHeader

                    // 基本信息
                    basicInfoSection

                    // 功能亮点
                    featureHighlightsSection

                    // 技术栈
                    techStackSection

                    // 致谢
                    acknowledgementsSection
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    GlassButton(title: "关闭", icon: "xmark", color: .secondary) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - 应用图标和名称
    private var appHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "ant.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.accentColor)
                .padding(.top, 20)

            Text("CAssistant")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("版本 3.0")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 基本信息
    private var basicInfoSection: some View {
        GlassCard {
            VStack(spacing: 0) {
                GlassSectionHeader(title: "基本信息", icon: "info.circle.fill")

                GlassInfoRow(label: "版本", value: "3.0", icon: "number")
                Divider().background(.white.opacity(0.08))
                GlassInfoRow(label: "构建号", value: "2026.06", icon: "hammer.fill")
                Divider().background(.white.opacity(0.08))
                GlassInfoRow(label: "平台", value: "iOS 16+", icon: "iphone")
                Divider().background(.white.opacity(0.08))
                GlassInfoRow(label: "开发者", value: "CAssistant Team", icon: "person.2.fill")
                Divider().background(.white.opacity(0.08))
                GlassInfoRow(label: "Bundle ID", value: "com.cassistant.app", icon: "barcode")
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - 功能亮点
    private var featureHighlightsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "功能亮点", icon: "star.circle.fill")

                VStack(alignment: .leading, spacing: 6) {
                    featureRow(icon: "ant.circle.fill", title: "APK 深度分析", description: "全面的 APK 文件解析，包括 Manifest、权限、证书、组件等")
                    featureRow(icon: "magnifyingglass.circle.fill", title: "权限审计", description: "自动识别危险权限，按风险等级分类")
                    featureRow(icon: "signature", title: "签名验证", description: "检查 APK 签名证书的有效性和完整性")
                    featureRow(icon: "curlybraces", title: "Smali 编辑", description: "支持 Smali 代码浏览、编辑和语法高亮")
                    featureRow(icon: "square.stack.3d.up", title: "SO 库分析", description: "分析 Native 库的架构、符号和依赖关系")
                    featureRow(icon: "bolt.circle.fill", title: "AI 智能助手", description: "集成多平台 AI 模型，辅助代码分析和安全审计")
                    featureRow(icon: "terminal.fill", title: "内置终端", description: "命令行工具，支持文件浏览和信息查询")
                    featureRow(icon: "arrow.triangle.2.circlepath", title: "逆向工具集", description: "字符串搜索、交叉引用、资源提取等实用功能")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 8)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - 技术栈
    private var techStackSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "技术栈", icon: "gearshape.2.fill")

                VStack(spacing: 0) {
                    GlassInfoRow(label: "UI 框架", value: "SwiftUI", icon: "swift")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "最低系统", value: "iOS 16.0", icon: "iphone")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "语言", value: "Swift 5.9+", icon: "textformat")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "架构", value: "MVVM + EnvironmentObject", icon: "square.3.layers.3d.down.left")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "设计", value: "Glassmorphism 风格", icon: "circle.lefthalf.filled")
                }
                .padding(.vertical, 4)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - 致谢
    private var acknowledgementsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "致谢", icon: "heart.circle.fill")

                VStack(alignment: .leading, spacing: 4) {
                    Text("感谢以下开源项目和工具：")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)

                    acknowledgementItem("Apktool - APK 逆向工程工具")
                    acknowledgementItem("dex2jar - DEX 到 JAR 转换工具")
                    acknowledgementItem("smali/baksmali - DEX 汇编/反汇编")
                    acknowledgementItem("aapt/aapt2 - Android 资源打包工具")
                    acknowledgementItem("IDA Pro / Ghidra - 原生代码分析")
                    acknowledgementItem("SwiftUI - Apple 声明式 UI 框架")
                }
                .padding(.bottom, 8)
            }
            .padding(.vertical, 8)
        }
    }

    private func acknowledgementItem(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
                .foregroundStyle(.tertiary)
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
    }
}

// MARK: - Preview
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}