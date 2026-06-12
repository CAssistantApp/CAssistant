import SwiftUI

// MARK: - 关于页面
struct AboutView: View {
    @EnvironmentObject private var appState: AppState
    
    private let appVersion = "1.0.0"
    private let buildNumber = "20260612"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 应用图标与名称
                GlassCard {
                    VStack(spacing: 16) {
                        if #available(iOS 17.0, *) {
                            Image(systemName: "ant.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.tint)
                                .symbolEffect(.pulse, options: .repeating)
                        } else {
                            Image(systemName: "ant.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.tint)
                        }
                        
                        Text("CAssistant")
                            .font(.largeTitle.bold())
                        
                        Text("APK逆向工程辅助工具")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                // 版本信息
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "版本信息", systemImage: "info.circle")
                        
                        GlassInfoRow(label: "应用版本", value: appVersion, icon: "number")
                        GlassInfoRow(label: "构建号", value: buildNumber, icon: "hammer")
                        GlassInfoRow(label: "平台", value: "iOS / iPadOS", icon: "iphone")
                        GlassInfoRow(label: "最低支持", value: "iOS 16.0", icon: "arrow.up")
                    }
                }
                
                // 功能介绍
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "功能介绍", systemImage: "sparkles")
                        
                        FeatureRow(icon: "doc.text.magnifyingglass", title: "APK深度解析", description: "全面解析APK结构、Manifest、DEX、资源文件等")
                        FeatureRow(icon: "hand.raised", title: "权限安全分析", description: "检测敏感权限与安全风险")
                        FeatureRow(icon: "square.stack.3d.up", title: "类结构分析", description: "查看类、方法、字段的完整结构")
                        FeatureRow(icon: "chevron.left.forwardslash.chevron.right", title: "Smali/Dex查看", description: "浏览Dalvik字节码与类定义")
                        FeatureRow(icon: "cpu", title: "SO库分析", description: "分析Native库的ELF结构与导出函数")
                        FeatureRow(icon: "lock.shield", title: "签名证书管理", description: "APK签名验证与证书管理")
                        FeatureRow(icon: "pencil.and.outline", title: "IDE代码编辑器", description: "内置代码编辑器与智能辅助")
                        FeatureRow(icon: "brain", title: "AI智能分析", description: "AI驱动的代码解释、优化与检测")
                    }
                }
                
                // 技术栈
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "技术栈", systemImage: "gear")
                        
                        GlassInfoRow(label: "界面框架", value: "SwiftUI", icon: "swift")
                        GlassInfoRow(label: "解析引擎", value: "内置APK解析器", icon: "doc.text")
                        GlassInfoRow(label: "AI集成", value: "OpenAI / Claude API", icon: "network")
                        GlassInfoRow(label: "签名工具", value: "APKSigner 引擎", icon: "lock")
                        GlassInfoRow(label: "数据模型", value: "Swift Codable", icon: "cylinder.split.1x2")
                    }
                }
                
                // 许可信息
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "许可信息", systemImage: "doc.text")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MIT License")
                                .font(.headline)
                            
                            Text("""
                                Copyright (c) 2026 CAssistant Team
                                
                                特此授权，任何获得本软件副本及相关文档文件（以下简称"软件"）的人均可无限制地免费使用本软件，包括但不限于使用、复制、修改、合并、发布、分发、再许可和/或出售软件副本的权利，并允许接受软件的人这样做，但须符合以下条件：
                                
                                上述版权声明和本许可声明应包含在软件的所有副本或重要部分中。
                                
                                本软件按"原样"提供，不附带任何明示或暗示的担保，包括但不限于适销性、特定用途适用性和非侵权性的担保。在任何情况下，作者或版权持有人均不对因软件或软件的使用或其他处理而引起的或与之相关的任何索赔、损害或其他责任负责。
                                """)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // 底部版权
                Text("© 2026 CAssistant Team. All rights reserved.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationTitle("关于")
        .background(Color.clear)
    }
}

// MARK: - 功能行组件
private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white.opacity(0.1), lineWidth: 0.5)
        )
    }
}