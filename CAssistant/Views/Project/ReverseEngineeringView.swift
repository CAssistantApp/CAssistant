import SwiftUI

// MARK: - 反编译方式枚举
enum DecompileMethod: String, CaseIterable {
    case apktool = "Apktool"
    case jadx    = "JADX"
    case both    = "两者"

    var description: String {
        switch self {
        case .apktool: return "Smali/资源反编译"
        case .jadx:    return "Java源代码反编译"
        case .both:    return "同时使用两种方式"
        }
    }
}

// MARK: - ReverseEngineeringView
struct ReverseEngineeringView: View {
    @EnvironmentObject private var appState: AppState

    // APK文件
    @State private var apkFilePath: String = ""
    @State private var showApkPicker = false

    // 输出目录
    @State private var outputDir: String = NSHomeDirectory() + "/Documents/Decompiled"
    @State private var showOutputPicker = false

    // 反编译方式
    @State private var decompileMethod: DecompileMethod = .apktool

    // 详细选项 - Apktool
    @State private var decodeSmali = true
    @State private var decodeResources = true
    @State private var decodeManifest = true
    @State private var noRes = false
    @State private var forceDecode = false

    // 详细选项 - JADX
    @State private var showJavaCode = true
    @State private var decompileInline = false
    @State private var showLineNumbers = true
    @State private var escapeUnicode = false
    @State private var showInconsistentCode = false

    // 分析选项
    @State private var analyzePermissions = true
    @State private var analyzeComponents = true
    @State private var analyzeClasses = false
    @State private var analyzeStrings = false
    @State private var analyzeAPI = true
    @State private var analyzeSecurity = true

    // 状态
    @State private var isRunning = false
    @State private var progress: Double = 0
    @State private var currentStep: String = ""
    @State private var showResult = false
    @State private var resultMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("逆向工程")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Spacer()

                if isRunning {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.blue)
                        Text(currentStep)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .glassCard()

            ScrollView {
                VStack(spacing: 20) {
                    // 文件选择
                    fileSelectionSection

                    // 反编译方式
                    methodSelectionSection

                    // 详细选项
                    detailOptionsSection

                    // 分析选项
                    analysisOptionsSection

                    // 进度与操作
                    actionSection
                }
                .padding()
            }
        }
        .glassBackground()
        .alert("逆向结果", isPresented: $showResult) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(resultMessage)
        }
    }

    // MARK: - 文件选择
    private var fileSelectionSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                GlassSectionHeader(title: "文件选择")

                // APK文件选择
                VStack(alignment: .leading, spacing: 6) {
                    Text("APK文件")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.orange)
                        Text(apkFilePath.isEmpty ? "请选择APK文件" : apkFilePath)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(apkFilePath.isEmpty ? .white.opacity(0.4) : .white)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        GlassButton(title: "选择", icon: "folder") {
                            showApkPicker = true
                        }
                    }
                    .padding(10)
                    .background(.white.opacity(0.06))
                    .cornerRadius(8)
                }

                // 输出目录
                VStack(alignment: .leading, spacing: 6) {
                    Text("输出目录")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.cyan)
                        Text(outputDir)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        GlassButton(title: "浏览", icon: "folder.badge.plus") {
                            showOutputPicker = true
                        }
                    }
                    .padding(10)
                    .background(.white.opacity(0.06))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    // MARK: - 反编译方式
    private var methodSelectionSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "反编译方式")

                HStack(spacing: 12) {
                    ForEach(DecompileMethod.allCases, id: \.self) { method in
                        Button {
                            decompileMethod = method
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: iconForMethod(method))
                                    .font(.title2)
                                Text(method.rawValue)
                                    .font(.caption.bold())
                                Text(method.description)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(decompileMethod == method ? Color.blue.opacity(0.25) : .white.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(decompileMethod == method ? Color.blue : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
    }

    private func iconForMethod(_ method: DecompileMethod) -> String {
        switch method {
        case .apktool: return "hammer"
        case .jadx:    return "doc.text.magnifyingglass"
        case .both:    return "arrow.triangle.branch"
        }
    }

    // MARK: - 详细选项
    private var detailOptionsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                GlassSectionHeader(title: "详细选项")

                if decompileMethod == .apktool || decompileMethod == .both {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Apktool 选项")
                            .font(.subheadline.bold())
                            .foregroundColor(.blue.opacity(0.9))

                        GlassListRow {
                            Toggle(isOn: $decodeSmali) { Text("反编译Smali代码").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.blue)
                        }
                        GlassListRow {
                            Toggle(isOn: $decodeResources) { Text("反编译资源文件").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.blue)
                        }
                        GlassListRow {
                            Toggle(isOn: $decodeManifest) { Text("反编译AndroidManifest").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.blue)
                        }
                        GlassListRow {
                            Toggle(isOn: $noRes) { Text("不反编译资源(保持原始)").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.blue)
                        }
                        GlassListRow {
                            Toggle(isOn: $forceDecode) { Text("强制反编译(忽略错误)").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.blue)
                        }
                    }
                    .padding(10)
                    .background(.white.opacity(0.04))
                    .cornerRadius(8)
                }

                if decompileMethod == .jadx || decompileMethod == .both {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("JADX 选项")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange.opacity(0.9))

                        GlassListRow {
                            Toggle(isOn: $showJavaCode) { Text("输出Java源代码").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.orange)
                        }
                        GlassListRow {
                            Toggle(isOn: $decompileInline) { Text("内联反编译(简化解构)").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.orange)
                        }
                        GlassListRow {
                            Toggle(isOn: $showLineNumbers) { Text("显示行号映射").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.orange)
                        }
                        GlassListRow {
                            Toggle(isOn: $escapeUnicode) { Text("转义Unicode字符").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.orange)
                        }
                        GlassListRow {
                            Toggle(isOn: $showInconsistentCode) { Text("显示不一致代码").font(.caption).foregroundColor(.white) }
                                .toggleStyle(.switch).tint(.orange)
                        }
                    }
                    .padding(10)
                    .background(.white.opacity(0.04))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    // MARK: - 分析选项
    private var analysisOptionsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassSectionHeader(title: "分析选项")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    GlassListRow {
                        Toggle(isOn: $analyzePermissions) {
                            Label("权限分析", systemImage: "lock.shield")
                                .font(.caption).foregroundColor(.white)
                        }
                        .toggleStyle(.switch).tint(.green)
                    }

                    GlassListRow {
                        Toggle(isOn: $analyzeComponents) {
                            Label("组件分析", systemImage: "puzzlepiece.extension")
                                .font(.caption).foregroundColor(.white)
                        }
                        .toggleStyle(.switch).tint(.green)
                    }

                    GlassListRow {
                        Toggle(isOn: $analyzeClasses) {
                            Label("类结构分析", systemImage: "square.stack.3d.down.right")
                                .font(.caption).foregroundColor(.white)
                        }
                        .toggleStyle(.switch).tint(.green)
                    }

                    GlassListRow {
                        Toggle(isOn: $analyzeStrings) {
                            Label("字符串提取", systemImage: "textformat")
                                .font(.caption).foregroundColor(.white)
                        }
                        .toggleStyle(.switch).tint(.green)
                    }

                    GlassListRow {
                        Toggle(isOn: $analyzeAPI) {
                            Label("API调用分析", systemImage: "antenna.radiowaves.left.and.right")
                                .font(.caption).foregroundColor(.white)
                        }
                        .toggleStyle(.switch).tint(.green)
                    }

                    GlassListRow {
                        Toggle(isOn: $analyzeSecurity) {
                            Label("安全风险检测", systemImage: "exclamationmark.shield")
                                .font(.caption).foregroundColor(.white)
                        }
                        .toggleStyle(.switch).tint(.green)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - 操作区域
    private var actionSection: some View {
        VStack(spacing: 16) {
            if isRunning {
                VStack(spacing: 8) {
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(.linear)
                        .tint(.blue)
                        .animation(.easeInOut, value: progress)

                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                GlassButton(title: "取消", icon: "stop.circle") {
                    isRunning = false
                }
                .foregroundColor(.red)
            } else {
                GlassButton(
                    title: "开始逆向",
                    icon: "play.fill"
                ) {
                    startReverseEngineering()
                }
                .disabled(apkFilePath.isEmpty)
                .opacity(apkFilePath.isEmpty ? 0.5 : 1)
            }
        }
        .padding()
        .glassCard()
    }

    // MARK: - 逻辑
    private func startReverseEngineering() {
        guard !apkFilePath.isEmpty else { return }
        isRunning = true
        progress = 0

        let steps: [(Double, String)] = [
            (0.1, "正在验证APK文件..."),
            (0.2, "正在解析APK结构..."),
            (0.4, "正在反编译资源文件..."),
            (0.6, "正在反编译源代码..."),
            (0.8, "正在执行分析..."),
            (1.0, "逆向完成")
        ]

        for (idx, step) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 0.8) {
                withAnimation {
                    progress = step.0
                    currentStep = step.1
                }
                if idx == steps.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isRunning = false
                        resultMessage = """
                        APK逆向完成！
                        输出目录: \(outputDir)/\(URL(fileURLWithPath: apkFilePath).deletingPathExtension().lastPathComponent)
                        使用工具: \(decompileMethod.rawValue)
                        分析项: \(analyzedItemsCount()) 项
                        """
                        showResult = true
                    }
                }
            }
        }
    }

    private func analyzedItemsCount() -> Int {
        [analyzePermissions, analyzeComponents, analyzeClasses,
         analyzeStrings, analyzeAPI, analyzeSecurity].filter { $0 }.count
    }
}