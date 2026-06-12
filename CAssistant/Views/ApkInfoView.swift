import SwiftUI

struct ApkInfoView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if appState.apkInfo.packageName.isEmpty {
                    emptyStateView
                } else {
                    // 应用图标
                    if let iconData = appState.apkInfo.appIcon, let uiImage = UIImage(data: iconData) {
                        appIconView(image: uiImage)
                    }

                    // 基本信息
                    basicInfoCard

                    // 版本信息
                    versionInfoCard

                    // 哈希信息
                    hashInfoCard

                    // 统计信息
                    statsCard
                }
            }
            .padding()
        }
        .navigationTitle("APK 详情")
    }

    // MARK: - App Icon
    private func appIconView(image: UIImage) -> some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )

            Text(appState.apkInfo.appName)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Basic Info Card
    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "基本信息", icon: "info.circle")

            VStack(spacing: 8) {
                GlassInfoRow(label: "应用名称", value: appState.apkInfo.appName, icon: "app")
                GlassInfoRow(label: "包名", value: appState.apkInfo.packageName, icon: "shippingbox")
                GlassInfoRow(label: "文件大小", value: formatFileSize(appState.apkInfo.fileSize), icon: "doc")
                GlassInfoRow(label: "DEX 数量", value: "\(appState.apkInfo.dexCount)", icon: "cube")
                GlassInfoRow(label: "方法数", value: "\(appState.apkInfo.methodCount)", icon: "function")
                GlassInfoRow(label: "字符串数", value: "\(appState.apkInfo.stringCount)", icon: "textformat")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Version Info Card
    private var versionInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "版本信息", icon: "number")

            VStack(spacing: 8) {
                GlassInfoRow(label: "版本名", value: appState.apkInfo.versionName, icon: "tag")
                GlassInfoRow(label: "版本号", value: appState.apkInfo.versionCode, icon: "number")
                GlassInfoRow(label: "最低 SDK", value: "API \(appState.apkInfo.minSdkVersion)", icon: "arrow.down")
                GlassInfoRow(label: "目标 SDK", value: "API \(appState.apkInfo.targetSdkVersion)", icon: "arrow.up")
                if !appState.apkInfo.compileSdkVersion.isEmpty {
                    GlassInfoRow(label: "编译 SDK", value: "API \(appState.apkInfo.compileSdkVersion)", icon: "hammer")
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Hash Info Card
    private var hashInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "文件哈希", icon: "key")

            VStack(spacing: 8) {
                hashRow(label: "MD5", value: appState.apkInfo.md5, icon: "number.circle")
                hashRow(label: "SHA1", value: appState.apkInfo.sha1, icon: "1.circle")
                hashRow(label: "SHA256", value: appState.apkInfo.sha256, icon: "2.circle")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            GlassSectionHeader(title: "文件统计", icon: "chart.pie")

            VStack(spacing: 8) {
                GlassInfoRow(label: "总文件数", value: "\(appState.files.count)", icon: "doc.on.doc")
                GlassInfoRow(label: "DEX 文件", value: "\(appState.dexFiles.count)", icon: "cube")
                GlassInfoRow(label: "Smali 文件", value: "\(appState.smaliFiles.count)", icon: "chevron.left.forwardslash.chevron.right")
                GlassInfoRow(label: "SO 库", value: "\(appState.soFiles.count)", icon: "square.stack.3d.up")
                GlassInfoRow(label: "ARSC 文件", value: "\(appState.arscFiles.count)", icon: "tablecells")
                GlassInfoRow(label: "权限", value: "\(appState.permissions.count)", icon: "shield")
                GlassInfoRow(label: "组件", value: "\(appState.components.count)", icon: "square.grid.3x3")
                GlassInfoRow(label: "类", value: "\(appState.classes.count)", icon: "cube.transparent")
                GlassInfoRow(label: "证书", value: "\(appState.certificates.count)", icon: "signature")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Hash Row (copyable)
    private func hashRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundColor(.primary)
            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
        )
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "eye.circle")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("暂无 APK 信息")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text("请先导入并分析 APK 文件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// MARK: - Preview
struct ApkInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ApkInfoView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}