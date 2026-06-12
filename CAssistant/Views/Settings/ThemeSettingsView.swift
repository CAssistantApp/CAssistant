import SwiftUI

// MARK: - 主题设置视图
struct ThemeSettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var isDarkMode: Bool = false
    @State private var fontSize: Double = 16
    @State private var showToolbar: Bool = true
    @State private var showNavPanel: Bool = true
    @State private var showApplyAlert = false
    @State private var showResetAlert = false
    @State private var originalDarkMode: Bool = false
    @State private var originalFontSize: Double = 16
    @State private var originalToolbar: Bool = true
    @State private var originalNavPanel: Bool = true
    
    private let minFontSize: Double = 10
    private let maxFontSize: Double = 32
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 外观设置
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        GlassSectionHeader(title: "外观设置", systemImage: "sun.max.fill")
                        
                        HStack {
                            Label("深色模式", systemImage: isDarkMode ? "moon.fill" : "sun.max")
                            Spacer()
                            Toggle("", isOn: $isDarkMode)
                                .labelsHidden()
                                .tint(.accentColor)
                        }
                        .padding(.horizontal, 4)
                        
                        Text(isDarkMode ? "当前为深色模式" : "当前为浅色模式")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                    }
                }
                
                // 字体设置
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        GlassSectionHeader(title: "字体设置", systemImage: "textformat.size")
                        
                        VStack(spacing: 8) {
                            HStack {
                                Label("字体大小", systemImage: "textformat")
                                Spacer()
                                Text("\(Int(fontSize))pt")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .padding(.horizontal, 4)
                            
                            HStack {
                                Image(systemName: "textformat.size.smaller")
                                    .foregroundStyle(.secondary)
                                Slider(value: $fontSize, in: minFontSize...maxFontSize, step: 1)
                                    .tint(.accentColor)
                                Image(systemName: "textformat.size.larger")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 4)
                            
                            // 预览
                            VStack(spacing: 4) {
                                Text("预览效果")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                Text("CAssistant APK逆向工程工具")
                                    .font(.system(size: fontSize))
                                    .foregroundStyle(.primary)
                                Text("灵活强大的APK分析与编辑平台")
                                    .font(.system(size: fontSize - 2))
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                }
                
                // 显示选项
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        GlassSectionHeader(title: "显示选项", systemImage: "eye")
                        
                        VStack(spacing: 12) {
                            HStack {
                                Label("显示工具栏", systemImage: "wrench.adjustable")
                                Spacer()
                                Toggle("", isOn: $showToolbar)
                                    .labelsHidden()
                                    .tint(.accentColor)
                            }
                            .padding(.horizontal, 4)
                            
                            HStack {
                                Label("显示导航面板", systemImage: "sidebar.left")
                                Spacer()
                                Toggle("", isOn: $showNavPanel)
                                    .labelsHidden()
                                    .tint(.accentColor)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                
                // 操作按钮
                HStack(spacing: 16) {
                    GlassButton(title: "重置为默认", icon: "arrow.counterclockwise") {
                        showResetAlert = true
                    }
                    
                    GlassButton(title: "应用设置", icon: "checkmark.circle") {
                        applySettings()
                        showApplyAlert = true
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("主题设置")
        .background(Color.clear)
        .onAppear {
            loadCurrentSettings()
        }
        .alert("设置已应用", isPresented: $showApplyAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("主题和显示设置已成功应用")
        }
        .alert("重置为默认", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) { }
            Button("确定", role: .destructive) {
                resetToDefault()
            }
        } message: {
            Text("确定要将所有设置恢复为默认值吗？")
        }
    }
    
    // MARK: - 加载当前设置
    private func loadCurrentSettings() {
        isDarkMode = appState.isDarkMode
        originalDarkMode = appState.isDarkMode
        originalFontSize = fontSize
        originalToolbar = showToolbar
        originalNavPanel = showNavPanel
    }
    
    // MARK: - 应用设置
    private func applySettings() {
        appState.isDarkMode = isDarkMode
        
        // 保存当前值作为新基准
        originalDarkMode = isDarkMode
        originalFontSize = fontSize
        originalToolbar = showToolbar
        originalNavPanel = showNavPanel
    }
    
    // MARK: - 重置为默认
    private func resetToDefault() {
        isDarkMode = false
        fontSize = 16
        showToolbar = true
        showNavPanel = true
        
        appState.isDarkMode = false
        
        originalDarkMode = false
        originalFontSize = 16
        originalToolbar = true
        originalNavPanel = true
    }
}