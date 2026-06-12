import SwiftUI
import UniformTypeIdentifiers

// MARK: - 组件分析视图
struct ComponentAnalysisView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 页面标题
                GlassSectionHeader(title: "四大组件分析", systemImage: "square.grid.2x2")
                    .padding(.horizontal)
                
                if let info = appState.currentAPKInfo {
                    // 统计概览
                    statsOverview(info: info)
                        .padding(.horizontal)
                    
                    // Activity列表
                    if !info.activities.isEmpty {
                        componentSection(
                            title: "Activity",
                            icon: "rectangle.portrait.on.rectangle.portrait",
                            color: .blue,
                            count: info.activities.count,
                            items: info.activities
                        )
                        .padding(.horizontal)
                    }
                    
                    // Service列表
                    if !info.services.isEmpty {
                        componentSection(
                            title: "Service",
                            icon: "gearshape.2",
                            color: .green,
                            count: info.services.count,
                            items: info.services
                        )
                        .padding(.horizontal)
                    }
                    
                    // Receiver列表
                    if !info.receivers.isEmpty {
                        componentSection(
                            title: "Receiver",
                            icon: "antenna.radiowaves.left.and.right",
                            color: .orange,
                            count: info.receivers.count,
                            items: info.receivers
                        )
                        .padding(.horizontal)
                    }
                    
                    // Provider列表
                    if !info.providers.isEmpty {
                        componentSection(
                            title: "Provider",
                            icon: "cylinder.split.1x2",
                            color: .purple,
                            count: info.providers.count,
                            items: info.providers
                        )
                        .padding(.horizontal)
                    }
                    
                    // 如果所有组件都为空
                    if info.activities.isEmpty && info.services.isEmpty &&
                       info.receivers.isEmpty && info.providers.isEmpty {
                        emptyComponentsView
                    }
                } else {
                    emptyComponentsView
                }
            }
            .padding(.vertical)
        }
        .glassBackground()
        .navigationTitle("组件分析")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 统计概览
    private func statsOverview(info: APKInfo) -> some View {
        GlassCard {
            HStack(spacing: 0) {
                StatCell(count: info.activities.count, label: "Activity", icon: "rectangle.portrait.on.rectangle.portrait", color: .blue)
                Divider().frame(height: 40)
                StatCell(count: info.services.count, label: "Service", icon: "gearshape.2", color: .green)
                Divider().frame(height: 40)
                StatCell(count: info.receivers.count, label: "Receiver", icon: "antenna.radiowaves.left.and.right", color: .orange)
                Divider().frame(height: 40)
                StatCell(count: info.providers.count, label: "Provider", icon: "cylinder.split.1x2", color: .purple)
            }
        }
    }
    
    // MARK: - 统计单元格
    private struct StatCell: View {
        let count: Int
        let label: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text("\(count)")
                    .font(.title2.bold())
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - 组件分区
    private func componentSection(title: String, icon: String, color: Color, count: Int, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "\(title) (\(count))", systemImage: icon)
                .foregroundStyle(color)
            
            ForEach(items, id: \.self) { item in
                componentRow(item: item, color: color)
            }
        }
    }
    
    // MARK: - 组件行
    private func componentRow(item: String, color: Color) -> some View {
        GlassCard {
            HStack(spacing: 12) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(shortName(from: item))
                        .font(.body.bold())
                        .lineLimit(1)
                    
                    if item.contains(".") {
                        Text(item)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - 空组件视图
    private var emptyComponentsView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 40)
            
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("暂无组件信息")
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
    
    // MARK: - 辅助函数
    private func shortName(from component: String) -> String {
        component.components(separatedBy: ".").last ?? component
    }
}

// MARK: - 预览
#Preview {
    ComponentAnalysisView()
        .environmentObject(AppState())
}