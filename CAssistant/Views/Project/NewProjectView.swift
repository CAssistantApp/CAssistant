import SwiftUI

struct NewProjectView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var localConfig = ProjectConfig()
    @State private var showSuccessAlert = false

    private let targetSdkOptions = ["21", "23", "26", "29", "30", "31", "33", "34"]
    private let minSdkOptions = ["19", "21", "23", "26"]
    private let signingOptions = ["debug", "release"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 基本信息
                    basicInfoSection

                    // SDK 版本
                    sdkVersionSection

                    // 语言
                    languageSection

                    // 架构
                    architectureSection

                    // 构建选项
                    buildOptionsSection

                    // 签名
                    signingSection

                    // 操作按钮
                    actionButtons
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            .navigationTitle("新建项目")
            .navigationBarTitleDisplayMode(.inline)
            .alert("创建成功", isPresented: $showSuccessAlert) {
                Button("确定", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("项目「\(localConfig.projectName)」已创建成功。")
            }
        }
    }

    // MARK: - 基本信息
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "基本信息", icon: "doc.badge.plus")

            GlassCard {
                VStack(spacing: 0) {
                    textFieldRow(title: "项目名称", text: $localConfig.projectName, icon: "tag.fill", placeholder: "MyApp")
                    Divider().background(.white.opacity(0.08))
                    textFieldRow(title: "包名", text: $localConfig.packageName, icon: "shippingbox.fill", placeholder: "com.example.myapp")
                }
            }
        }
    }

    // MARK: - SDK 版本
    private var sdkVersionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "SDK 版本", icon: "gearshape.fill")

            GlassCard {
                VStack(spacing: 0) {
                    pickerRow(title: "目标 SDK 版本", selection: $localConfig.targetSdkVersion, options: targetSdkOptions, icon: "target")
                    Divider().background(.white.opacity(0.08))
                    pickerRow(title: "最低 SDK 版本", selection: $localConfig.minSdkVersion, options: minSdkOptions, icon: "arrow.down.to.line")
                }
            }
        }
    }

    // MARK: - 语言
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "语言", icon: "text.word.spacing")

            GlassCard {
                pickerRow(
                    title: "开发语言",
                    selection: $localConfig.language,
                    options: ProjectConfig.ProjectLanguage.allCases,
                    display: { $0.rawValue },
                    icon: "chevron.left.forwardslash.chevron.right"
                )
            }
        }
    }

    // MARK: - 架构
    private var architectureSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "架构", icon: "cpu.fill")

            GlassCard {
                pickerRow(
                    title: "目标架构",
                    selection: $localConfig.architecture,
                    options: ProjectConfig.ProjectArchitecture.allCases,
                    display: { $0.rawValue },
                    icon: "memorychip.fill"
                )
            }
        }
    }

    // MARK: - 构建选项
    private var buildOptionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "构建选项", icon: "slider.horizontal.3")

            GlassCard {
                VStack(spacing: 0) {
                    toggleInputRow(title: "启用混淆", isOn: $localConfig.enableObfuscation, icon: "lock.shield.fill")
                    Divider().background(.white.opacity(0.08))
                    toggleInputRow(title: "启用资源压缩", isOn: $localConfig.enableShrink, icon: "rectangle.compress.vertical")
                }
            }
        }
    }

    // MARK: - 签名
    private var signingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassSectionHeader(title: "签名", icon: "signature")

            GlassCard {
                pickerRow(title: "签名配置", selection: $localConfig.signingConfig, options: signingOptions, icon: "pencil.and.outline")
            }
        }
    }

    // MARK: - 操作按钮
    private var actionButtons: some View {
        VStack(spacing: 12) {
            GlassButton(title: "创建项目", icon: "plus.circle.fill") {
                appState.projectConfig = localConfig
                showSuccessAlert = true
            }

            GlassButton(title: "取消", icon: "xmark.circle.fill") {
                dismiss()
            }
        }
        .padding(.top, 8)
    }

    // MARK: - 通用行组件
    private func textFieldRow(title: String, text: Binding<String>, icon: String, placeholder: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Spacer()
            TextField(placeholder, text: text)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 14))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func pickerRow<T: Hashable>(
        title: String,
        selection: Binding<T>,
        options: [T],
        icon: String
    ) -> some View where T: CustomStringConvertible {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Spacer()
            Picker("", selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.description).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func pickerRow<T: Hashable>(
        title: String,
        selection: Binding<T>,
        options: [T],
        display: @escaping (T) -> String,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Spacer()
            Picker("", selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(display(option)).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func toggleInputRow(title: String, isOn: Binding<Bool>, icon: String) -> some View {
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
}

// MARK: - Preview
struct NewProjectView_Previews: PreviewProvider {
    static var previews: some View {
        NewProjectView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}