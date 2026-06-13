import SwiftUI
import UIKit

struct CertificateView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if appState.certificates.isEmpty {
                    emptyStateView
                } else {
                    ForEach(appState.certificates) { cert in
                        certificateCard(cert)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("证书信息")
    }

    // MARK: - Certificate Card
    private func certificateCard(_ cert: CertificateInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 有效性指示
            validityHeader(cert)

            // 主体信息
            VStack(alignment: .leading, spacing: 8) {
                GlassSectionHeader(title: "证书主体", icon: "person.badge.key")

                VStack(spacing: 6) {
                    GlassInfoRow(label: "主题", value: cert.subject, icon: "person.text.rectangle")
                    GlassInfoRow(label: "颁发者", value: cert.issuer, icon: "building.columns")
                    GlassInfoRow(label: "序列号", value: cert.serialNumber, icon: "number")
                    GlassInfoRow(label: "签名算法", value: cert.signatureAlgorithm, icon: "pencil.and.outline")
                    GlassInfoRow(label: "公钥算法", value: cert.publicKeyAlgorithm, icon: "key")
                    GlassInfoRow(label: "版本", value: "V\(cert.version)", icon: "info.circle")
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

            // 有效期
            VStack(alignment: .leading, spacing: 8) {
                GlassSectionHeader(title: "有效期", icon: "calendar")

                VStack(spacing: 6) {
                    GlassInfoRow(label: "生效日期", value: formatDate(cert.validFrom), icon: "calendar.badge.plus")
                    GlassInfoRow(label: "到期日期", value: formatDate(cert.validTo), icon: "calendar.badge.minus")
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

            // 指纹
            VStack(alignment: .leading, spacing: 8) {
                GlassSectionHeader(title: "指纹", icon: "fingerprint")

                VStack(spacing: 6) {
                    copyableFingerprintRow(label: "MD5", value: cert.fingerprintMD5, icon: "number.circle")
                    copyableFingerprintRow(label: "SHA1", value: cert.fingerprintSHA1, icon: "1.circle")
                    copyableFingerprintRow(label: "SHA256", value: cert.fingerprintSHA256, icon: "2.circle")
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
    }

    // MARK: - Validity Header
    private func validityHeader(_ cert: CertificateInfo) -> some View {
        HStack(spacing: 10) {
            Image(systemName: cert.isValid ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.title2)
                .foregroundColor(cert.isValid ? .green : .red)

            VStack(alignment: .leading, spacing: 2) {
                Text(cert.isValid ? "证书有效" : "证书无效")
                    .font(.headline)
                    .foregroundColor(cert.isValid ? .green : .red)
                Text("签名算法: \(cert.signatureAlgorithm)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            GlassBadge(text: cert.isValid ? "有效" : "无效", color: cert.isValid ? .green : .red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cert.isValid ? Color.green.opacity(0.2) : Color.red.opacity(0.2), lineWidth: 0.5)
        )
    }

    // MARK: - Copyable Fingerprint Row
    private func copyableFingerprintRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 11, design: .monospaced))
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

    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "signature")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("暂无证书数据")
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
}

// MARK: - Preview
struct CertificateView_Previews: PreviewProvider {
    static var previews: some View {
        CertificateView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}