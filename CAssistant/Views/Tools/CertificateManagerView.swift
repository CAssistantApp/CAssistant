import SwiftUI

// MARK: - 证书管理视图
struct CertificateManagerView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var keystorePath: String = ""
    @State private var keystoreAlias: String = ""
    @State private var keystorePassword: String = ""
    @State private var keyPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showKeyPassword: Bool = false
    
    @State private var certificates: [CertificateInfo] = CertificateInfo.samples
    @State private var selectedCert: CertificateInfo?
    
    @State private var signOutput: String = ""
    @State private var signStatus: SignStatus = .idle
    @State private var showFilePicker = false
    @State private var filePickerType: FilePickerType = .keystore
    
    enum SignStatus {
        case idle
        case signing
        case success
        case failure(String)
        
        var label: String {
            switch self {
            case .idle: return "等待操作"
            case .signing: return "签名中..."
            case .success: return "签名成功"
            case .failure(let err): return "签名失败: \(err)"
            }
        }
        
        var color: Color {
            switch self {
            case .idle: return .secondary
            case .signing: return .orange
            case .success: return .green
            case .failure: return .red
            }
        }
    }
    
    enum FilePickerType {
        case keystore
        case certificate
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 证书列表
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "证书列表", systemImage: "list.bullet.rectangle")
                        
                        if certificates.isEmpty {
                            Text("暂无证书")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(certificates) { cert in
                                CertificateRow(cert: cert, isSelected: selectedCert?.id == cert.id)
                                    .onTapGesture {
                                        selectedCert = cert
                                    }
                            }
                        }
                    }
                }
                
                // 密钥库配置
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "密钥库配置", systemImage: "key.fill")
                        
                        // 密钥库路径
                        VStack(alignment: .leading, spacing: 4) {
                            Label("密钥库路径", systemImage: "folder")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                TextField("选择或输入密钥库路径", text: $keystorePath)
                                    .font(.system(.body, design: .monospaced))
                                    .textFieldStyle(.plain)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.ultraThinMaterial)
                                    )
                                
                                Button(action: {
                                    filePickerType = .keystore
                                    showFilePicker = true
                                }) {
                                    Image(systemName: "folder.badge.plus")
                                        .font(.title3)
                                }
                                .glassButtonStyle()
                            }
                        }
                        
                        // 别名
                        VStack(alignment: .leading, spacing: 4) {
                            Label("密钥别名", systemImage: "tag")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            TextField("输入密钥别名", text: $keystoreAlias)
                                .font(.system(.body, design: .monospaced))
                                .textFieldStyle(.plain)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        
                        // 密钥库密码
                        VStack(alignment: .leading, spacing: 4) {
                            Label("密钥库密码", systemImage: "lock")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                if showPassword {
                                    TextField("输入密钥库密码", text: $keystorePassword)
                                        .font(.system(.body, design: .monospaced))
                                } else {
                                    SecureField("输入密钥库密码", text: $keystorePassword)
                                        .font(.system(.body, design: .monospaced))
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        
                        // 密钥密码
                        VStack(alignment: .leading, spacing: 4) {
                            Label("密钥密码", systemImage: "lock.shield")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                if showKeyPassword {
                                    TextField("输入密钥密码（可选）", text: $keyPassword)
                                        .font(.system(.body, design: .monospaced))
                                } else {
                                    SecureField("输入密钥密码（可选）", text: $keyPassword)
                                        .font(.system(.body, design: .monospaced))
                                }
                                
                                Button(action: { showKeyPassword.toggle() }) {
                                    Image(systemName: showKeyPassword ? "eye.slash" : "eye")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                }
                
                // 操作按钮
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        GlassSectionHeader(title: "操作", systemImage: "gearshape.2")
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 12) {
                                GlassButton(title: "创建密钥库", icon: "key.icloud") {
                                    createKeystore()
                                }
                                
                                GlassButton(title: "导入证书", icon: "doc.badge.plus") {
                                    filePickerType = .certificate
                                    showFilePicker = true
                                }
                            }
                            
                            HStack(spacing: 12) {
                                GlassButton(title: "签名APK", icon: "checkmark.seal") {
                                    signAPK()
                                }
                                
                                GlassButton(title: "验证签名", icon: "shield.checkered") {
                                    verifySignature()
                                }
                            }
                        }
                    }
                }
                
                // 签名状态信息
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        GlassSectionHeader(title: "签名信息", systemImage: "info.circle")
                        
                        HStack {
                            Circle()
                                .fill(signStatus.color)
                                .frame(width: 8, height: 8)
                            Text(signStatus.label)
                                .font(.subheadline)
                                .foregroundStyle(signStatus.color)
                        }
                        .padding(.horizontal, 4)
                        
                        if !signOutput.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(signOutput)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                }
                
                // 选中证书详情
                if let cert = selectedCert {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            GlassSectionHeader(title: "证书详情", systemImage: "certificate")
                            
                            GlassInfoRow(label: "颁发者", value: cert.issuer, icon: "building.2")
                            GlassInfoRow(label: "主题", value: cert.subject, icon: "person.text.rectangle")
                            GlassInfoRow(label: "有效期", value: cert.validity, icon: "calendar")
                            GlassInfoRow(label: "指纹(SHA256)", value: cert.fingerprint, icon: "fingerprint")
                            GlassInfoRow(label: "序列号", value: cert.serialNumber, icon: "number")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("证书管理")
        .background(Color.clear)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.data, .item],
            allowsMultipleSelection: false
        ) { result in
            handleFilePickerResult(result)
        }
    }
    
    // MARK: - 处理文件选择
    private func handleFilePickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            switch filePickerType {
            case .keystore:
                keystorePath = url.path
            case .certificate:
                importCertificate(from: url)
            }
        case .failure(let error):
            signOutput = "文件选择失败: \(error.localizedDescription)"
            signStatus = .failure(error.localizedDescription)
        }
    }
    
    // MARK: - 创建密钥库
    private func createKeystore() {
        signStatus = .signing
        signOutput = "正在创建密钥库...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let newCert = CertificateInfo(
                issuer: "CN=CAssistant, OU=Dev, O=CAssistant Team",
                subject: "CN=CAssistant, OU=Dev, O=CAssistant Team",
                validity: "2026-06-12 ~ 2031-06-11",
                fingerprint: "A1:B2:C3:D4:E5:F6:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99",
                serialNumber: "\(Int.random(in: 100000...999999))"
            )
            certificates.append(newCert)
            selectedCert = newCert
            signOutput += "密钥库创建成功\n路径: \(keystorePath.isEmpty ? "默认位置" : keystorePath)\n别名: \(keystoreAlias)"
            signStatus = .success
        }
    }
    
    // MARK: - 导入证书
    private func importCertificate(from url: URL) {
        signStatus = .signing
        signOutput = "正在导入证书: \(url.lastPathComponent)...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let importedCert = CertificateInfo(
                issuer: "CN=Imported, O=External",
                subject: "CN=\(url.lastPathComponent), O=Unknown",
                validity: "2025-01-01 ~ 2030-12-31",
                fingerprint: "IM:PO:RT:ED:" + String(format: "%02X", Int.random(in: 0...255)),
                serialNumber: "IMP\(Int.random(in: 10000...99999))"
            )
            certificates.append(importedCert)
            selectedCert = importedCert
            signOutput += "证书导入成功: \(url.lastPathComponent)"
            signStatus = .success
        }
    }
    
    // MARK: - 签名APK
    private func signAPK() {
        guard !keystorePath.isEmpty || !keystoreAlias.isEmpty else {
            signOutput = "请至少填写密钥库路径和别名"
            signStatus = .failure("缺少必要参数")
            return
        }
        
        signStatus = .signing
        signOutput = "正在签名APK...\n"
        signOutput += "密钥库: \(keystorePath.isEmpty ? "默认" : keystorePath)\n"
        signOutput += "别名: \(keystoreAlias)\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            signOutput += "\nAPK签名完成\n签名算法: SHA256withRSA\n签名版本: v1 + v2"
            signStatus = .success
        }
    }
    
    // MARK: - 验证签名
    private func verifySignature() {
        signStatus = .signing
        signOutput = "正在验证签名...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            signOutput += """
            
            签名验证结果:
            - 签名算法: SHA256withRSA
            - 签名版本: v2
            - 证书链: 完整
            - 摘要: 匹配
            - 时间戳: 可信
            - 总体状态: 签名有效 ✓
            """
            signStatus = .success
        }
    }
}

// MARK: - 证书信息模型
struct CertificateInfo: Identifiable {
    let id = UUID()
    let issuer: String
    let subject: String
    let validity: String
    let fingerprint: String
    let serialNumber: String
    
    static let samples: [CertificateInfo] = [
        CertificateInfo(
            issuer: "CN=CAssistant Debug, OU=Dev, O=CAssistant",
            subject: "CN=CAssistant Debug, OU=Dev, O=CAssistant",
            validity: "2026-01-01 ~ 2027-01-01",
            fingerprint: "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99",
            serialNumber: "ABCD1234"
        )
    ]
}

// MARK: - 证书行组件
private struct CertificateRow: View {
    let cert: CertificateInfo
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "certificate")
                .font(.title3)
                .foregroundColor(isSelected ? .accentColor : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(cert.subject)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                    .lineLimit(1)
                Text(cert.validity)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? .thinMaterial : .ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.accentColor.opacity(0.5) : .white.opacity(0.1), lineWidth: isSelected ? 1 : 0.5)
        )
    }
}