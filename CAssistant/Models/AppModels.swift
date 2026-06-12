import SwiftUI
import UniformTypeIdentifiers
import Foundation

// MARK: - AppState
final class AppState: ObservableObject {
    @Published var selectedFileURL: URL?
    @Published var selectedFileName: String = ""
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0
    @Published var analysisLog: [String] = []
    @Published var apkInfo = ApkInfo()
    @Published var manifest = ManifestInfo()
    @Published var permissions: [PermissionInfo] = []
    @Published var certificates: [CertificateInfo] = []
    @Published var classes: [ClassInfo] = []
    @Published var components: [ComponentInfo] = []
    @Published var files: [FileEntry] = []
    @Published var dexFiles: [String] = []
    @Published var smaliFiles: [String] = []
    @Published var soFiles: [String] = []
    @Published var arscFiles: [String] = []
    @Published var extractedPath: String = ""
    @Published var aiChatMessages: [ChatMessage] = []
    @Published var aiConfig = AIConfig()
    @Published var themeSettings = ThemeSettings()
    @Published var errorMessage: String?

    func reset() {
        apkInfo = ApkInfo()
        manifest = ManifestInfo()
        permissions = []
        certificates = []
        classes = []
        components = []
        files = []
        dexFiles = []
        smaliFiles = []
        soFiles = []
        arscFiles = []
        extractedPath = ""
        analysisLog = []
        analysisProgress = 0
        errorMessage = nil
    }

    func parseAPK(_ url: URL) async {
        await MainActor.run {
            isAnalyzing = true
            analysisProgress = 0
            analysisLog = ["正在加载 APK 文件..."]
            selectedFileURL = url
            selectedFileName = url.lastPathComponent
        }
        do {
            let parser = APKParserService()
            let result = try await parser.parse(url: url, progress: { [weak self] p, msg in
                Task { @MainActor in
                    self?.analysisProgress = p
                    self?.analysisLog.append(msg)
                }
            })
            await MainActor.run {
                self.apkInfo = result.apkInfo
                self.manifest = result.manifest
                self.permissions = result.permissions
                self.certificates = result.certificates
                self.classes = result.classes
                self.components = result.components
                self.files = result.files
                self.dexFiles = result.dexFiles
                self.smaliFiles = result.smaliFiles
                self.soFiles = result.soFiles
                self.arscFiles = result.arscFiles
                self.extractedPath = result.extractedPath
                self.isAnalyzing = false
                self.analysisLog.append("✅ 分析完成")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isAnalyzing = false
                self.analysisLog.append("❌ 错误: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - APK Info
struct ApkInfo {
    var packageName: String = ""
    var versionName: String = ""
    var versionCode: String = ""
    var minSdkVersion: String = ""
    var targetSdkVersion: String = ""
    var compileSdkVersion: String = ""
    var appName: String = ""
    var appIcon: Data?
    var fileSize: Int64 = 0
    var md5: String = ""
    var sha1: String = ""
    var sha256: String = ""
    var dexCount: Int = 0
    var methodCount: Int = 0
    var stringCount: Int = 0
}

// MARK: - Manifest
struct ManifestInfo {
    var rawXML: String = ""
    var formattedXML: String = ""
    var packageName: String = ""
    var versionName: String = ""
    var versionCode: String = ""
    var minSdk: String = ""
    var targetSdk: String = ""
    var applicationName: String = ""
    var applicationLabel: String = ""
    var usesPermissions: [String] = []
    var declaredPermissions: [String] = []
    var features: [String] = []
    var libraries: [String] = []
}

// MARK: - Permission
struct PermissionInfo: Identifiable {
    let id = UUID()
    var name: String = ""
    var level: String = ""
    var description: String = ""
    var riskLevel: RiskLevel = .unknown
}

enum RiskLevel: String, CaseIterable {
    case unknown = "未知"
    case normal = "普通"
    case dangerous = "危险"
    case signature = "签名"
    case critical = "严重"

    var color: Color {
        switch self {
        case .unknown: return .secondary
        case .normal: return .green
        case .dangerous: return .orange
        case .signature: return .blue
        case .critical: return .red
        }
    }
}

// MARK: - Certificate
struct CertificateInfo: Identifiable {
    let id = UUID()
    var subject: String = ""
    var issuer: String = ""
    var serialNumber: String = ""
    var validFrom: Date = Date()
    var validTo: Date = Date()
    var fingerprintMD5: String = ""
    var fingerprintSHA1: String = ""
    var fingerprintSHA256: String = ""
    var signatureAlgorithm: String = ""
    var publicKeyAlgorithm: String = ""
    var version: Int = 0
    var isValid: Bool = false
}

// MARK: - Class
struct ClassInfo: Identifiable {
    let id = UUID()
    var name: String = ""
    var superClass: String = ""
    var interfaces: [String] = []
    var methods: [String] = []
    var fields: [String] = []
    var accessFlags: String = ""
    var sourceFile: String = ""
}

// MARK: - Component
struct ComponentInfo: Identifiable {
    let id = UUID()
    var name: String = ""
    var componentType: ComponentType = .activity
    var exported: Bool = false
    var permission: String = ""
    var intentFilters: [String] = []
}

enum ComponentType: String, CaseIterable, Identifiable {
    case activity = "Activity"
    case service = "Service"
    case receiver = "BroadcastReceiver"
    case provider = "ContentProvider"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .activity: return "rectangle.portrait.and.arrow.right"
        case .service: return "gearshape.2"
        case .receiver: return "antenna.radiowaves.left.and.right"
        case .provider: return "externaldrive"
        }
    }
}

// MARK: - File Entry
struct FileEntry: Identifiable {
    let id = UUID()
    var name: String = ""
    var path: String = ""
    var size: Int64 = 0
    var isDirectory: Bool = false
    var children: [FileEntry] = []
    var compressionMethod: String = ""
    var crc32: String = ""
}

// MARK: - Chat
struct ChatMessage: Identifiable {
    let id = UUID()
    var role: MessageRole = .user
    var content: String = ""
    var timestamp: Date = Date()
}

enum MessageRole: String {
    case user = "用户"
    case assistant = "AI"
    case system = "系统"
}

// MARK: - AI Config
struct AIConfig {
    var provider: AIProvider = .openAI
    var apiKey: String = ""
    var model: String = "gpt-4o"
    var temperature: Double = 0.7
    var maxTokens: Int = 4096
    var systemPrompt: String = "你是一个专业的 Android 逆向工程助手，帮助分析 APK 文件结构、Smali 代码、SO 库等。"
}

enum AIProvider: String, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case claude = "Claude"
    case gemini = "Gemini"
    case custom = "自定义"

    var id: String { rawValue }
    var defaultModel: String {
        switch self {
        case .openAI: return "gpt-4o"
        case .claude: return "claude-3-opus"
        case .gemini: return "gemini-pro"
        case .custom: return ""
        }
    }
}

// MARK: - Theme
struct ThemeSettings {
    var accentColor: Color = .blue
    var glassOpacity: Double = 0.15
    var fontSize: CGFloat = 14
    var showLineNumbers: Bool = true
    var autoIndent: Bool = true
}

// MARK: - Parse Result
struct ParseResult {
    var apkInfo = ApkInfo()
    var manifest = ManifestInfo()
    var permissions: [PermissionInfo] = []
    var certificates: [CertificateInfo] = []
    var classes: [ClassInfo] = []
    var components: [ComponentInfo] = []
    var files: [FileEntry] = []
    var dexFiles: [String] = []
    var smaliFiles: [String] = []
    var soFiles: [String] = []
    var arscFiles: [String] = []
    var extractedPath: String = ""
}

// MARK: - File Import Manager
struct FileImportManager {
    static let supportedTypes: [UTType] = [
        UTType(filenameExtension: "apk") ?? .data,
        UTType(filenameExtension: "ipa") ?? .data,
        UTType(filenameExtension: "dex") ?? .data,
        UTType(filenameExtension: "so") ?? .data,
        UTType(filenameExtension: "jar") ?? .data,
        UTType(filenameExtension: "aar") ?? .data,
        UTType(filenameExtension: "class") ?? .data,
        .zip, .xml, .plainText, .json, .data
    ]
}