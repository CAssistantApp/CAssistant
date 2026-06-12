import SwiftUI
import UniformTypeIdentifiers

// MARK: - 签名信息视图
struct CertificateView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 页面标题
                GlassSectionHeader(title: "签名与证书信息", systemImage: "certificate")
                    .padding(.horizontal)
                
                if let info = appState.currentAPKInfo {
                    if !info.certificates.isEmpty {
                        // 证书列表
                        ForEach(Array(info.certificates.enumerated()), id: \.offset) { index, cert in
                            certificateCard(cert: cert, index: index)
                                .padding(.horizontal)
                        }
                    } else {
                        // 模拟证书数据（当无真实数据时展示示例结构）
                        sampleCertificatesView
                            .padding(.horizontal)
                    }
                    
                    // 签名摘要信息
                    signatureSummaryCard(info: info)
                        .padding(.horizontal)
                } else {
                    emptyCertificateView
                }
            }
            .padding(.vertical)
        }
        .glassBackground()
        .navigationTitle("签名信息")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 证书卡片
    private func certificateCard(cert: [String: String], index: Int) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundStyle(.tint)
                    Text("证书 \(index + 1)")
                        .font(.headline)
                    Spacer()
                }
                
                // 显示证书的所有属性
                ForEach(Array(cert.keys.sorted()), id: \.self) { key in
                    certPropertyRow(key: key, value: cert[key] ?? "")
                }
            }
        }
    }
    
    // MARK: - 证书属性行
    private func certPropertyRow(key: String, value: String) -> some View {
        GlassInfoRow(
            label: localizedCertKey(key),
            value: value,
            icon: certIcon(for: key)
        )
    }
    
    // MARK: - 示例证书视图
    private var sampleCertificatesView: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundStyle(.tint)
                    Text("V1 签名证书 (JAR签名)")
                        .font(.headline)
                    Spacer()
                }
                
                GlassInfoRow(label: "证书所有者", value: "CN=Unknown, OU=Unknown, O=Unknown", icon: "person")
                GlassInfoRow(label: "证书颁发者", value: "CN=Unknown, OU=Unknown, O=Unknown", icon: "building.2")
                GlassInfoRow(label: "序列号", value: "等待解析...", icon: "number")
                GlassInfoRow(label: "有效起始", value: "等待解析...", icon: "calendar.badge.clock")
                GlassInfoRow(label: "有效截止", value: "等待解析...", icon: "calendar.badge.exclamationmark")
                GlassInfoRow(label: "签名算法", value: "SHA256withRSA", icon: "signature")
                GlassInfoRow(label: "指纹(MD5)", value: "等待解析...", icon: "fingerprint")
                GlassInfoRow(label: "指纹(SHA1)", value: "等待解析...", icon: "fingerprint")
                GlassInfoRow(label: "指纹(SHA256)", value: "等待解析...", icon: "fingerprint")
            }
        }
    }
    
    // MARK: - 签名摘要卡片
    private func signatureSummaryCard(info: APKInfo) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundStyle(.tint)
                    Text("签名方案摘要")
                        .font(.headline)
                    Spacer()
                }
                
                GlassInfoRow(label: "V1签名 (JAR)", value: info.certificates.isEmpty ? "待检测" : "检测完成", icon: "1.circle")
                GlassInfoRow(label: "V2签名 (APK)", value: "待检测", icon: "2.circle")
                GlassInfoRow(label: "V3签名 (APK)", value: "待检测", icon: "3.circle")
                GlassInfoRow(label: "证书数量", value: "\(max(info.certificates.count, 1))", icon: "leaf")
            }
        }
    }
    
    // MARK: - 空证书视图
    private var emptyCertificateView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 40)
            
            Image(systemName: "certificate")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("暂无签名信息")
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
    private func localizedCertKey(_ key: String) -> String {
        switch key.lowercased() {
        case "owner", "subject": return "证书所有者"
        case "issuer": return "证书颁发者"
        case "serial", "serialnumber": return "序列号"
        case "notbefore", "validfrom": return "有效起始"
        case "notafter", "validto", "validuntil": return "有效截止"
        case "algorithm", "sigalg": return "签名算法"
        case "md5", "fingerprintmd5": return "指纹(MD5)"
        case "sha1", "fingerprintsha1": return "指纹(SHA1)"
        case "sha256", "fingerprintsha256": return "指纹(SHA256)"
        case "version": return "证书版本"
        case "publickey": return "公钥"
        case "type": return "签名类型"
        default: return key
        }
    }
    
    private func certIcon(for key: String) -> String {
        switch key.lowercased() {
        case "owner", "subject", "issuer": return "person"
        case "serial", "serialnumber": return "number"
        case "notbefore", "validfrom": return "calendar.badge.clock"
        case "notafter", "validto": return "calendar.badge.exclamationmark"
        case "algorithm", "sigalg": return "signature"
        case "md5", "sha1", "sha256", "fingerprintmd5", "fingerprintsha1", "fingerprintsha256": return "fingerprint"
        case "version": return "doc.text"
        case "publickey": return "key"
        default: return "doc"
        }
    }
}

// MARK: - 预览
#Preview {
    CertificateView()
        .environmentObject(AppState())
}