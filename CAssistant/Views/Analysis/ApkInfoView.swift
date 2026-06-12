import SwiftUI
import UniformTypeIdentifiers

// MARK: - 基本信息视图
struct ApkInfoView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 页面标题
                GlassSectionHeader(title: "APK基本信息", systemImage: "info.circle")
                    .padding(.horizontal)
                
                if let info = appState.currentAPKInfo {
                    // 应用信息卡片
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "app.badge")
                                    .font(.title2)
                                    .foregroundStyle(.tint)
                                Text("应用信息")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            GlassInfoRow(label: "包名", value: info.package, icon: "shippingbox")
                            GlassInfoRow(label: "应用名称", value: info.appName, icon: "app")
                            GlassInfoRow(label: "版本名", value: info.versionName, icon: "tag")
                            GlassInfoRow(label: "版本号", value: "\(info.versionCode)", icon: "number.circle")
                        }
                    }
                    .padding(.horizontal)
                    
                    // SDK信息卡片
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "gearshape.2")
                                    .font(.title2)
                                    .foregroundStyle(.tint)
                                Text("SDK信息")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            GlassInfoRow(label: "最低SDK版本", value: "API \(info.minSDK)", icon: "arrow.down.to.line.compact")
                            GlassInfoRow(label: "目标SDK版本", value: "API \(info.targetSDK)", icon: "target")
                        }
                    }
                    .padding(.horizontal)
                    
                    // 入口与文件信息卡片
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .font(.title2)
                                    .foregroundStyle(.tint)
                                Text("入口与文件信息")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            GlassInfoRow(label: "主Activity", value: info.mainActivity.isEmpty ? "未检测" : info.mainActivity, icon: "door.right.hand.open")
                            GlassInfoRow(label: "文件大小", value: info.fileSizeFormatted, icon: "externaldrive")
                            GlassInfoRow(label: "DEX文件数", value: "\(info.dexFiles.count)", icon: "doc.text.magnifyingglass")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Dex文件列表
                    if !info.dexFiles.isEmpty {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .font(.title3)
                                        .foregroundStyle(.tint)
                                    Text("DEX文件列表")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("共 \(info.dexFiles.count) 个")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                ForEach(info.dexFiles, id: \.self) { dex in
                                    HStack {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .foregroundStyle(.tint)
                                        Text(dex)
                                            .font(.body)
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.ultraThinMaterial)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // 无数据提示
                    emptyInfoView
                }
            }
            .padding(.vertical)
        }
        .glassBackground()
        .navigationTitle("基本信息")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 空数据提示
    private var emptyInfoView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 40)
            
            Image(systemName: "info.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("暂无APK信息")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("请先在APK分析页面导入并分析APK文件")
                .font(.body)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - 预览
#Preview {
    ApkInfoView()
        .environmentObject(AppState())
}