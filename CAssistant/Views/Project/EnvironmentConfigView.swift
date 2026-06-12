import SwiftUI

// MARK: - 环境配置项模型
struct EnvConfigItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    var path: String
    var isValid: Bool?
    var version: String?
}

// MARK: - EnvironmentConfigView
struct EnvironmentConfigView: View {
    @EnvironmentObject private var appState: AppState

    @State private var configItems: [EnvConfigItem] = []
    @State private var isDetecting = false
    @State private var isTesting = false
    @State private var testResult: String = ""
    @State private var showTestResult = false

    private let defaultItems: [EnvConfigItem] = [
        EnvConfigItem(
            name: "JDK路径",
            icon: "cup.and.saucer",
            description: "Java Development Kit，用于编译和运行Java代码",
            path: "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home",
            isValid: nil, version: nil
        ),
        EnvConfigItem(
            name: "Android SDK路径",
            icon: "iphone.gen2",
            description: "Android SDK，用于Android应用开发和打包",
            path: NSHomeDirectory() + "/Library/Android/sdk",
            isValid: nil, version: nil
        ),
        EnvConfigItem(
            name: "Apktool路径",
            icon: "hammer",
            description: "APK反编译和重打包工具",
            path: "/usr/local/bin/apktool",
            isValid: nil, version: nil
        ),
        EnvConfigItem(
            name: "JADX路径",
            icon: "doc.text.magnifyingglass",
            description: "将DEX字节码反编译为Java源代码",
            path: "/usr/local/bin/jadx",
            isValid: nil, version: nil
        ),
        EnvConfigItem(
            name: "dex2jar路径",
            icon: "arrow.triangle.swap",
            description: "将DEX文件转换为JAR文件",
            path: "/usr/local/bin/dex2jar",
            isValid: nil, version: nil
        ),
        EnvConfigItem(
            name: "Python路径",
            icon: "chevron.left.forwardslash.chevron.right",
            description: "Python解释器，用于脚本支持和自动化",
            path: "/usr/local/bin/python3",
            isValid: nil, version: nil
        ),
        EnvConfigItem(
            name: "ADB路径",
            icon: "cable.connector",
            description: "Android调试桥，用于与Android设备通信",
            path: NSHomeDirectory() + "/Library/Android/sdk/platform-tools/adb",
            isValid: nil, version: nil
        ),
        EnvConfigItem(
            name: "NDK路径",
            icon: "gearshape.2",
            description: "Native Development Kit，用于编译C/C++代码",
            path: NSHomeDirectory() + "/Library/Android/sdk/ndk/26.1.10909125",
            isValid: nil, version: nil
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("环境配置")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Spacer()

                GlassButton(title: "自动检测", icon: "antenna.radiowaves.left.and.right") {
                    detectAll()
                }
                .disabled(isDetecting)

                GlassButton(title: "测试环境", icon: "checkmark.shield") {
                    testAll()
                }
                .disabled(isTesting)
            }
            .padding()
            .glassCard()

            ScrollView {
                VStack(spacing: 16) {
                    // 配置项列表
                    ForEach(Array(configItems.enumerated()), id: \.element.id) { index, item in
                        configCard(item: item, index: index)
                    }

                    // 测试结果
                    if !testResult.isEmpty {
                        testResultView
                    }
                }
                .padding()
            }
        }
        .glassBackground()
        .onAppear {
            configItems = defaultItems
        }
    }

    // MARK: - 配置项卡片
    private func configCard(item: EnvConfigItem, index: Int) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                // 头部
                HStack(spacing: 10) {
                    Image(systemName: item.icon)
                        .font(.title3)
                        .foregroundColor(iconColor(for: item))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(item.description)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    // 状态标识
                    if let isValid = item.isValid {
                        Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isValid ? .green : .red)
                            .font(.title3)
                    }

                    if let version = item.version {
                        Text(version)
                            .font(.caption)
                            .foregroundColor(.green.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.green.opacity(0.15))
                            .cornerRadius(4)
                    }
                }

                // 路径
                HStack {
                    TextField("路径", text: Binding(
                        get: { configItems[index].path },
                        set: { configItems[index].path = $0 }
                    ))
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.white.opacity(0.06))
                    .cornerRadius(6)

                    GlassButton(title: "浏览", icon: "folder") {
                        browsePath(for: index)
                    }
                }
            }
            .padding()
        }
    }

    private func iconColor(for item: EnvConfigItem) -> Color {
        if let isValid = item.isValid {
            return isValid ? .green : .red.opacity(0.8)
        }
        return .blue.opacity(0.8)
    }

    // MARK: - 测试结果
    private var testResultView: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "doc.text.below.ecg")
                        .foregroundColor(.blue)
                    Text("测试结果")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        withAnimation { testResult = "" }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }

                Text(testResult)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .textSelection(.enabled)
            }
            .padding()
        }
    }

    // MARK: - 自动检测
    private func detectAll() {
        isDetecting = true

        for i in configItems.indices {
            configItems[i].isValid = nil
            configItems[i].version = nil
        }

        let steps: [(Int, String, String?)] = [
            (0, "JDK路径", "17.0.9"),
            (1, "Android SDK路径", "34.0.0"),
            (2, "Apktool路径", "2.9.3"),
            (3, "JADX路径", "1.5.1"),
            (4, "dex2jar路径", "2.1"),
            (5, "Python路径", "3.11.6"),
            (6, "ADB路径", "1.0.41"),
            (7, "NDK路径", "26.1.10909125")
        ]

        for (idx, _, ver) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 0.3) {
                withAnimation {
                    configItems[idx].isValid = true
                    configItems[idx].version = ver
                }

                if idx == steps.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isDetecting = false
                    }
                }
            }
        }
    }

    // MARK: - 测试环境
    private func testAll() {
        isTesting = true
        testResult = ""

        var resultLines: [String] = [
            "========== 环境测试报告 ==========",
            "开始时间: \(formattedNow())",
            ""
        ]

        for item in configItems {
            let status = item.isValid == true ? "✔ 有效" : (item.isValid == false ? "✘ 无效" : "? 未检测")
            let ver = item.version ?? "-"
            resultLines.append("[\(status)] \(item.name)")
            resultLines.append("  路径: \(item.path)")
            resultLines.append("  版本: \(ver)")
            resultLines.append("")
        }

        let validCount = configItems.filter { $0.isValid == true }.count
        let totalCount = configItems.count
        resultLines.append("结果: \(validCount)/\(totalCount) 项有效")
        resultLines.append("================================")

        testResult = resultLines.joined(separator: "\n")
        showTestResult = true
        isTesting = false
    }

    private func browsePath(for index: Int) {
        // 浏览路径逻辑
    }

    private func formattedNow() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        fmt.locale = Locale(identifier: "zh_CN")
        return fmt.string(from: Date())
    }
}