import SwiftUI
import UniformTypeIdentifiers

// MARK: - APK分析主视图
struct ApkAnalyzerView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 页面标题
                GlassSectionHeader(title: "APK分析", systemImage: "doc.text.magnifyingglass")
                    .padding(.horizontal)
                
                if appState.currentAPKInfo == nil && !appState.isAnalyzing {
                    // 无APK时的引导提示
                    emptyStateView
                } else {
                    // 基本信息卡片
                    if let info = appState.currentAPKInfo {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "doc.zip")
                                        .font(.title2)
                                        .foregroundStyle(.tint)
                                    Text("当前APK信息")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                GlassInfoRow(label: "包名", value: info.package.isEmpty ? "未解析" : info.package, icon: "shippingbox")
                                GlassInfoRow(label: "应用名称", value: info.appName.isEmpty ? "未解析" : info.appName, icon: "app.badge")
                                GlassInfoRow(label: "版本名", value: info.versionName.isEmpty ? "未解析" : info.versionName, icon: "tag")
                                GlassInfoRow(label: "版本号", value: "\(info.versionCode)", icon: "number")
                                GlassInfoRow(label: "最低SDK", value: "API \(info.minSDK)", icon: "arrow.down.to.line")
                                GlassInfoRow(label: "目标SDK", value: "API \(info.targetSDK)", icon: "target")
                                GlassInfoRow(label: "文件大小", value: info.fileSizeFormatted, icon: "externaldrive")
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 快捷操作按钮
                    GlassCard {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .font(.title2)
                                    .foregroundStyle(.tint)
                                Text("快捷操作")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                GlassButton(title: "开始分析", icon: "magnifyingglass") {
                                    startAnalysis()
                                }
                                
                                HStack(spacing: 12) {
                                    GlassButton(title: "反编译", icon: "hammer") {
                                        decompileAPK()
                                    }
                                    
                                    GlassButton(title: "提取DEX", icon: "doc.zipper") {
                                        extractDEX()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 分析进度
                    if appState.isAnalyzing {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    if #available(iOS 17.0, *) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.title3)
                                            .foregroundStyle(.tint)
                                            .symbolEffect(.rotate, isActive: appState.isAnalyzing)
                                    } else {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.title3)
                                            .foregroundStyle(.tint)
                                    }
                                    Text("正在分析...")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(Int(appState.analysisProgress * 100))%")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                ProgressView(value: appState.analysisProgress)
                                    .tint(.accentColor)
                                    .progressViewStyle(.linear)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .glassBackground()
        .navigationTitle("APK分析")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 40)
            
            Image(systemName: "doc.cloud")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("尚未导入APK文件")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("请先通过左上角的导入按钮或文件管理器导入APK文件")
                .font(.body)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            GlassButton(title: "导入APK文件", icon: "doc.badge.plus") {
                appState.showFileImporter = true
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - 操作函数
    private func startAnalysis() {
        guard let path = appState.currentAPKPath else { return }
        appState.isAnalyzing = true
        appState.analysisProgress = 0
        
        Task {
            // 模拟进度更新
            for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                try? await Task.sleep(nanoseconds: 300_000_000)
                await MainActor.run {
                    appState.analysisProgress = progress
                }
            }
            
            do {
                let info = try await APKParserService.parseAPK(from: path)
                await MainActor.run {
                    appState.currentAPKInfo = info
                    appState.isAnalyzing = false
                    appState.analysisProgress = 1.0
                }
            } catch {
                await MainActor.run {
                    appState.errorMessage = "分析失败: \(error.localizedDescription)"
                    appState.isAnalyzing = false
                }
            }
        }
    }
    
    private func decompileAPK() {
        guard appState.currentAPKPath != nil else { return }
        appState.errorMessage = "反编译功能需要安装JADX工具"
    }
    
    private func extractDEX() {
        guard let info = appState.currentAPKInfo else { return }
        if info.dexFiles.isEmpty {
            appState.errorMessage = "未发现DEX文件"
        } else {
            appState.errorMessage = "发现 \(info.dexFiles.count) 个DEX文件: \(info.dexFiles.joined(separator: ", "))"
        }
    }
}

// MARK: - 预览
#Preview {
    ApkAnalyzerView()
        .environmentObject(AppState())
}