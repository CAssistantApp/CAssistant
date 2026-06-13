import SwiftUI
import UIKit

// MARK: - Certificate Manager View
struct CertificateManagerView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCertID: UUID?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if appState.certificates.isEmpty {
                    emptyStateView
                } else {
                    headerView

                    ForEach(appState.certificates) { cert in
                        certificateCard(cert)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            GlassSectionHeader(
                title: "证书列表 (\(appState.certificates.count))",
                icon: "signature"
            )

            Spacer()

            GlassButton(title: "导出全部", icon: "square.and.arrow.up", color: .accentColor) {
                exportAllCertificates()
            }
        }
    }

    // MARK: - Certificate Card
    private func certificateCard(_ cert: CertificateInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Validity Indicator
            validityHeader(cert)

            Divider()
                .background(.white.opacity(0.1))

            // Certificate Subject Info
            GlassSectionHeader(title: "证书主体", icon: "person.badge.key")

            GlassCard {
                VStack(spacing: 4) {
                    GlassInfoRow(label: "主题", value: limitedText(cert.subject, maxLength: 60), icon: "person.text.rectangle")
                    GlassInfoRow(label: "颁发者", value: limitedText(cert.issuer, maxLength: 60), icon: "building.columns")
                    GlassInfoRow(label: "序列号", value: limitedText(cert.serialNumber, maxLength: 40), icon: "number")
                    GlassInfoRow(label: "签名算法", value: cert.signatureAlgorithm, icon: "pencil.and.outline")
                    GlassInfoRow(label: "公钥算法", value: cert.publicKeyAlgorithm, icon: "key")
                    GlassInfoRow(label: "版本", value: "V\(cert.version)", icon: "info.circle")
                }
                .padding(12)
            }

            // Validity Period
            GlassSectionHeader(title: "有效期", icon: "calendar")

            GlassCard {
                VStack(spacing: 4) {
                    GlassInfoRow(label: "生效日期", value: formatDate(cert.validFrom), icon: "calendar.badge.plus")
                    GlassInfoRow(label: "到期日期", value: formatDate(cert.validTo), icon: "calendar.badge.minus")
                    GlassInfoRow(
                        label: "剩余天数",
                        value: remainingDaysText(cert.validTo),
                        icon: cert.isValid ? "checkmark.shield" : "exclamationmark.shield"
                    )
                }
                .padding(12)
            }

            // Issuer Info Block
            GlassSectionHeader(title: "签发者信息", icon: "building.columns.fill")

            GlassCard {
                VStack(spacing: 4) {
                    GlassInfoRow(label: "签发者", value: limitedText(cert.issuer, maxLength: 60), icon: "person.badge.shield")
                    GlassInfoRow(label: "签名算法", value: cert.signatureAlgorithm, icon: "signature")
                }
                .padding(12)
            }

            // Fingerprints
            GlassSectionHeader(title: "数字指纹", icon: "fingerprint")

            GlassCard {
                VStack(spacing: 4) {
                    copyableFingerprintRow(label: "MD5", value: cert.fingerprintMD5, icon: "number.circle.fill")
                    copyableFingerprintRow(label: "SHA1", value: cert.fingerprintSHA1, icon: "1.circle.fill")
                    copyableFingerprintRow(label: "SHA256", value: cert.fingerprintSHA256, icon: "2.circle.fill")
                }
                .padding(12)
            }

            // Export Button for Single Certificate
            GlassButton(title: "复制证书信息", icon: "doc.on.doc", color: .accentColor) {
                copyCertificateInfo(cert)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    // MARK: - Validity Header
    private func validityHeader(_ cert: CertificateInfo) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(cert.isValid ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: cert.isValid ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(cert.isValid ? .green : .red)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(cert.isValid ? "证书有效" : "证书无效或已过期")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(cert.isValid ? .green : .red)

                if !cert.signatureAlgorithm.isEmpty {
                    Text("签名: \(cert.signatureAlgorithm)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            GlassBadge(
                text: cert.isValid ? "有效" : "无效",
                color: cert.isValid ? .green : .red
            )
        }
    }

    // MARK: - Copyable Fingerprint Row
    private func copyableFingerprintRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundColor(.accentColor)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .leading)

            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundColor(.primary)

            Spacer()

            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 13))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.thinMaterial)
            )
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 80)

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)

                Image(systemName: "signature")
                    .font(.system(size: 44))
                    .foregroundStyle(.tertiary)
            }

            Text("暂无证书数据")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text("请先导入并分析 APK 文件以查看签名证书信息")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(spacing: 8) {
                Label("支持 RSA / DSA / EC 签名算法", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Label("自动验证证书有效期", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Label("可复制 MD5 / SHA1 / SHA256 指纹", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 12)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func remainingDaysText(_ validTo: Date) -> String {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: validTo).day ?? 0
        if remaining < 0 {
            return "已过期 \(abs(remaining)) 天"
        } else if remaining == 0 {
            return "今日到期"
        } else {
            return "\(remaining) 天"
        }
    }

    private func limitedText(_ text: String, maxLength: Int) -> String {
        if text.count <= maxLength { return text }
        let prefix = String(text.prefix(maxLength / 2))
        let suffix = String(text.suffix(maxLength / 2))
        return "\(prefix)...\(suffix)"
    }

    // MARK: - Actions
    private func copyCertificateInfo(_ cert: CertificateInfo) {
        var info = ""
        info += "=== 证书信息 ===\n"
        info += "主题: \(cert.subject)\n"
        info += "颁发者: \(cert.issuer)\n"
        info += "序列号: \(cert.serialNumber)\n"
        info += "签名算法: \(cert.signatureAlgorithm)\n"
        info += "公钥算法: \(cert.publicKeyAlgorithm)\n"
        info += "版本: V\(cert.version)\n"
        info += "状态: \(cert.isValid ? "有效" : "无效")\n"
        info += "生效日期: \(formatDate(cert.validFrom))\n"
        info += "到期日期: \(formatDate(cert.validTo))\n"
        info += "剩余天数: \(remainingDaysText(cert.validTo))\n"
        info += "\n--- 数字指纹 ---\n"
        info += "MD5: \(cert.fingerprintMD5)\n"
        info += "SHA1: \(cert.fingerprintSHA1)\n"
        info += "SHA256: \(cert.fingerprintSHA256)\n"

        UIPasteboard.general.string = info
    }

    private func exportAllCertificates() {
        var allInfo = "=== 全部证书信息 ===\n"
        allInfo += "证书数量: \(appState.certificates.count)\n\n"

        for (index, cert) in appState.certificates.enumerated() {
            allInfo += "--- 证书 #\(index + 1) ---\n"
            allInfo += "主题: \(cert.subject)\n"
            allInfo += "颁发者: \(cert.issuer)\n"
            allInfo += "序列号: \(cert.serialNumber)\n"
            allInfo += "签名算法: \(cert.signatureAlgorithm)\n"
            allInfo += "公钥算法: \(cert.publicKeyAlgorithm)\n"
            allInfo += "版本: V\(cert.version)\n"
            allInfo += "状态: \(cert.isValid ? "有效" : "无效")\n"
            allInfo += "MD5: \(cert.fingerprintMD5)\n"
            allInfo += "SHA1: \(cert.fingerprintSHA1)\n"
            allInfo += "SHA256: \(cert.fingerprintSHA256)\n\n"
        }

        UIPasteboard.general.string = allInfo
    }
}

// MARK: - Preview
struct CertificateManagerView_Previews: PreviewProvider {
    static var previews: some View {
        CertificateManagerView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}