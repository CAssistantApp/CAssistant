import SwiftUI

struct ProjectManagerView: View {
    @EnvironmentObject var appState: AppState
    @State private var showExportAlert = false
    @State private var exportMessage = ""
    @State private var showCleanConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 项目信息
                projectInfoSection

                // 功能列表
                featureListSection
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .navigationTitle("项目管理")
        .alert("导出报告", isPresented: $showExportAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(exportMessage)
        }
        .alert("确认清理", isPresented: $showCleanConfirm) {
            Button("取消", role: .cancel) {}
            Button("清理", role: .destructive) {
                appState.reset()
            }
        } message: {
            Text("这将清除所有分析数据，包括提取的文件和日志。此操作不可撤销。")
        }
    }

    // MARK: - 项目信息
    private var projectInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "项目信息", icon: "folder.circle.fill")

            GlassCard {
                VStack(spacing: 0) {
                    GlassInfoRow(label: "项目名称", value: projectName, icon: "tag.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "文件路径", value: appState.selectedFileURL?.path ?? "未加载", icon: "doc.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "文件数量", value: "\(appState.files.count)", icon: "list.bullet")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "DEX 文件", value: "\(appState.dexFiles.count)", icon: "cube")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "Smali 文件", value: "\(appState.smaliFiles.count)", icon: "chevron.left.forwardslash.chevron.right")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "SO 库", value: "\(appState.soFiles.count)", icon: "square.stack.3d.up")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "提取路径", value: extractedPathDisplay, icon: "externaldrive.fill")
                    Divider().background(.white.opacity(0.08))
                    GlassInfoRow(label: "日志条目", value: "\(appState.analysisLog.count)", icon: "text.alignleft")
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var projectName: String {
        appState.selectedFileName.isEmpty ? "未加载" : appState.selectedFileName
    }

    private var extractedPathDisplay: String {
        appState.extractedPath.isEmpty ? "未提取" : {
            let components = appState.extractedPath.components(separatedBy: "/")
            return components.suffix(2).joined(separator: "/")
        }()
    }

    // MARK: - 功能列表
    private var featureListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "操作", icon: "hammer.fill")

            GlassCard {
                VStack(spacing: 4) {
                    GlassNavRow(
                        title: "项目文件浏览",
                        icon: "folder.fill",
                        subtitle: "浏览和分析项目中的文件"
                    ) {
                        // Navigate to file list
                    }

                    GlassNavRow(
                        title: "提取 APK 内容",
                        icon: "tray.and.arrow.down.fill",
                        subtitle: appState.extractedPath.isEmpty ? "尚未提取" : "已提取到本地"
                    ) {
                        // Trigger extraction
                    }

                    GlassNavRow(
                        title: "导出分析报告",
                        icon: "square.and.arrow.up.fill",
                        subtitle: "生成包含分析结果的文本报告"
                    ) {
                        exportReport()
                    }

                    GlassNavRow(
                        title: "清理临时文件",
                        icon: "trash.fill",
                        subtitle: "重置所有分析数据"
                    ) {
                        showCleanConfirm = true
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - 导出报告
    private func exportReport() {
        guard !appState.selectedFileName.isEmpty else {
            exportMessage = "请先加载 APK 文件后再导出报告。"
            showExportAlert = true
            return
        }

        var report = ""
        report += "========================================\n"
        report += "  CAssistant - APK 分析报告\n"
        report += "========================================\n\n"

        // 基本信息
        report += "【基本信息】\n"
        report += "  文件名: \(appState.selectedFileName)\n"
        report += "  包名: \(appState.apkInfo.packageName)\n"
        report += "  版本: \(appState.apkInfo.versionName) (\(appState.apkInfo.versionCode))\n"
        report += "  应用名: \(appState.apkInfo.appName)\n"
        report += "  Min SDK: \(appState.apkInfo.minSdkVersion)\n"
        report += "  Target SDK: \(appState.apkInfo.targetSdkVersion)\n"
        report += "  MD5: \(appState.apkInfo.md5)\n"
        report += "  SHA1: \(appState.apkInfo.sha1)\n\n"

        // Manifest 信息
        report += "【Manifest 信息】\n"
        report += "  声明权限: \(appState.manifest.declaredPermissions.count) 个\n"
        report += "  使用权限: \(appState.manifest.usesPermissions.count) 个\n"
        report += "  特性: \(appState.manifest.features.count) 个\n"
        report += "  库: \(appState.manifest.libraries.count) 个\n\n"

        // 权限详情
        report += "【权限详情】\n"
        for perm in appState.permissions {
            report += "  - \(perm.name) [\(perm.level)] (\(perm.riskLevel.rawValue))\n"
        }
        report += "\n"

        // 证书信息
        report += "【签名证书】\n"
        for cert in appState.certificates {
            report += "  主体: \(cert.subject)\n"
            report += "  签发者: \(cert.issuer)\n"
            report += "  序列号: \(cert.serialNumber)\n"
            report += "  SHA1: \(cert.fingerprintSHA1)\n"
            report += "  签名算法: \(cert.signatureAlgorithm)\n"
            report += "  状态: \(cert.isValid ? "有效" : "无效")\n\n"
        }

        // 组件信息
        report += "【组件列表】\n"
        for comp in appState.components {
            report += "  - [\(comp.componentType.rawValue)] \(comp.name)"
            report += comp.exported ? " (已导出)" : ""
            if !comp.permission.isEmpty {
                report += " 权限: \(comp.permission)"
            }
            report += "\n"
        }
        report += "\n"

        // 统计
        report += "【文件统计】\n"
        report += "  总文件数: \(appState.files.count)\n"
        report += "  DEX 文件: \(appState.dexFiles.count)\n"
        report += "  Smali 文件: \(appState.smaliFiles.count)\n"
        report += "  SO 库: \(appState.soFiles.count)\n"
        report += "  ARSC 文件: \(appState.arscFiles.count)\n\n"

        report += "========================================\n"
        report += "  报告生成时间: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium))\n"
        report += "========================================\n"

        // 复制到剪贴板
        #if os(iOS)
        UIPasteboard.general.string = report
        #endif

        exportMessage = "报告已复制到剪贴板。\n\n\(report.prefix(300))..."
        showExportAlert = true
    }
}

// MARK: - Preview
struct ProjectManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectManagerView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}