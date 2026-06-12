import SwiftUI

// MARK: - NewProjectView
struct NewProjectView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // 基本信息
    @State private var projectName: String = ""
    @State private var selectedType: ProjectType = .apkReverse
    @State private var savePath: String = NSHomeDirectory() + "/Documents/Projects"
    @State private var showPathPicker = false

    // APK配置
    @State private var sourceApkPath: String = ""
    @State private var showApkPicker = false
    @State private var decompileResources = true
    @State private var decompileSources = true
    @State private var decompileManifest = true
    @State private var noDebugInfo = false
    @State private var forceApi = false

    // 项目设置
    @State private var packageName: String = ""
    @State private var appVersion: String = "1.0.0"
    @State private var minSDK: String = "21"
    @State private var targetSDK: String = "34"
    @State private var compileSDK: String = "34"

    // 状态
    @State private var isCreating = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let projectTypes: [ProjectType] = ProjectType.allCases

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("新建项目")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Spacer()

                GlassButton(title: "取消", icon: "xmark") {
                    dismiss()
                }
            }
            .padding()
            .glassCard()

            ScrollView {
                VStack(spacing: 20) {
                    // 基本信息
                    basicInfoSection

                    // APK配置
                    apkConfigSection

                    // 项目设置
                    projectSettingsSection

                    // 创建按钮
                    createButtonSection
                }
                .padding()
            }
        }
        .glassBackground()
        .frame(width: 600, height: 700)
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - 基本信息
    private var basicInfoSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                GlassSectionHeader(title: "基本信息")

                // 项目名称
                VStack(alignment: .leading, spacing: 6) {
                    Text("项目名称")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    TextField("输入项目名称", text: $projectName)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(.white.opacity(0.08))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }

                // 项目类型
                VStack(alignment: .leading, spacing: 6) {
                    Text("项目类型")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(projectTypes, id: \.self) { type in
                            Button {
                                selectedType = type
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(selectedType == type ? Color.blue.opacity(0.3) : .white.opacity(0.06))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedType == type ? Color.blue : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.white)
                        }
                    }
                }

                // 保存路径
                VStack(alignment: .leading, spacing: 6) {
                    Text("保存路径")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    HStack {
                        Text(savePath)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        GlassButton(title: "选择", icon: "folder.badge.plus") {
                            showPathPicker = true
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

    // MARK: - APK配置
    private var apkConfigSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                GlassSectionHeader(title: "APK配置")

                // 源APK选择
                VStack(alignment: .leading, spacing: 6) {
                    Text("源APK文件")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    HStack {
                        Text(sourceApkPath.isEmpty ? "未选择APK文件" : sourceApkPath)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(sourceApkPath.isEmpty ? .white.opacity(0.4) : .white.opacity(0.8))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        GlassButton(title: "浏览", icon: "doc.badge.plus") {
                            showApkPicker = true
                        }
                    }
                    .padding(10)
                    .background(.white.opacity(0.06))
                    .cornerRadius(8)
                }

                // 反编译选项
                VStack(alignment: .leading, spacing: 8) {
                    Text("反编译选项")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Toggle(isOn: $decompileResources) {
                        Text("反编译资源文件")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .toggleStyle(.switch)
                    .tint(.blue)

                    Toggle(isOn: $decompileSources) {
                        Text("反编译源代码")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .toggleStyle(.switch)
                    .tint(.blue)

                    Toggle(isOn: $decompileManifest) {
                        Text("反编译Manifest")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .toggleStyle(.switch)
                    .tint(.blue)

                    Toggle(isOn: $noDebugInfo) {
                        Text("不输出调试信息")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .toggleStyle(.switch)
                    .tint(.blue)

                    Toggle(isOn: $forceApi) {
                        Text("强制使用API兼容模式")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .toggleStyle(.switch)
                    .tint(.blue)
                }
            }
            .padding()
        }
    }

    // MARK: - 项目设置
    private var projectSettingsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                GlassSectionHeader(title: "项目设置")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    // 包名
                    VStack(alignment: .leading, spacing: 4) {
                        Text("包名")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        TextField("com.example.app", text: $packageName)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(.white.opacity(0.08))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                            .font(.system(size: 12, design: .monospaced))
                    }

                    // 版本号
                    VStack(alignment: .leading, spacing: 4) {
                        Text("版本号")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        TextField("1.0.0", text: $appVersion)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(.white.opacity(0.08))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                            .font(.system(size: 12, design: .monospaced))
                    }

                    // 最低SDK
                    VStack(alignment: .leading, spacing: 4) {
                        Text("最低SDK版本")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        TextField("21", text: $minSDK)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(.white.opacity(0.08))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                            .font(.system(size: 12, design: .monospaced))
                    }

                    // 目标SDK
                    VStack(alignment: .leading, spacing: 4) {
                        Text("目标SDK版本")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        TextField("34", text: $targetSDK)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(.white.opacity(0.08))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                            .font(.system(size: 12, design: .monospaced))
                    }

                    // 编译SDK
                    VStack(alignment: .leading, spacing: 4) {
                        Text("编译SDK版本")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        TextField("34", text: $compileSDK)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(.white.opacity(0.08))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                            .font(.system(size: 12, design: .monospaced))
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - 创建按钮
    private var createButtonSection: some View {
        VStack(spacing: 12) {
            GlassButton(title: isCreating ? "创建中..." : "创建项目", icon: "checkmark.circle") {
                createProject()
            }
            .disabled(isCreating || projectName.isEmpty)

            if isCreating {
                ProgressView()
                    .progressViewStyle(.linear)
                    .tint(.blue)
            }
        }
        .padding(.vertical)
    }

    // MARK: - 创建逻辑
    private func createProject() {
        guard !projectName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "请输入项目名称"
            showAlert = true
            return
        }

        isCreating = true

        // 模拟创建过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isCreating = false
            alertMessage = "项目 \"\(projectName)\" 创建成功！"
            showAlert = true
            // 延迟关闭
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
}