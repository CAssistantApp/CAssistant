import SwiftUI
import UniformTypeIdentifiers
import Foundation

// MARK: - AppState
@MainActor
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
    @Published var announcements: [CloudAnnouncement] = CloudAnnouncement.loadDefaults()
    @Published var envConfig = EnvironmentConfig()
    @Published var projectConfig = ProjectConfig()

    func loadAnnouncements() {
        announcements = CloudAnnouncement.loadDefaults()
    }

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
final class FileEntry: Identifiable, ObservableObject {
    let id = UUID()
    var name: String = ""
    var path: String = ""
    var size: Int64 = 0
    var isDirectory: Bool = false
    var children: [FileEntry] = []
    var compressionMethod: String = ""
    var crc32: String = ""

    init(name: String = "", path: String = "", size: Int64 = 0,
         isDirectory: Bool = false, children: [FileEntry] = [],
         compressionMethod: String = "", crc32: String = "") {
        self.name = name
        self.path = path
        self.size = size
        self.isDirectory = isDirectory
        self.children = children
        self.compressionMethod = compressionMethod
        self.crc32 = crc32
    }
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

// MARK: - Cloud Announcement
struct CloudAnnouncement: Identifiable, Codable {
    let id: String
    var title: String
    var content: String
    var level: AnnouncementLevel
    var publishDate: Date
    var isRead: Bool
    var url: String?

    enum AnnouncementLevel: String, Codable, CaseIterable {
        case info = "信息"
        case warning = "警告"
        case update = "更新"
        case alert = "重要"

        var color: Color {
            switch self {
            case .info: return .blue
            case .warning: return .orange
            case .update: return .green
            case .alert: return .red
            }
        }

        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .update: return "arrow.down.circle.fill"
            case .alert: return "bell.circle.fill"
            }
        }
    }

    static func loadDefaults() -> [CloudAnnouncement] {
        [
            CloudAnnouncement(
                id: "v3.0-release",
                title: "CAssistant 3.0 正式发布",
                content: "全新 SwiftUI 架构，支持灵动玻璃效果、AI 智能分析、DEX/Smali 代码查看、SO 库分析等全功能。适配 iPhone + iPad 双平台。",
                level: .update,
                publishDate: Date(),
                isRead: false
            ),
            CloudAnnouncement(
                id: "sample-dex",
                title: "内置示例 DEX 文件",
                content: "应用已内置合法示例 DEX 和 Smali 文件，无需导入 APK 即可体验代码分析和反编译功能。",
                level: .info,
                publishDate: Date().addingTimeInterval(-86400),
                isRead: false
            ),
            CloudAnnouncement(
                id: "security-tip",
                title: "安全提示",
                content: "分析未知 APK 时请注意安全，建议在沙箱环境中运行。本工具仅用于合法的安全研究和学习目的。",
                level: .warning,
                publishDate: Date().addingTimeInterval(-172800),
                isRead: false
            ),
            CloudAnnouncement(
                id: "ai-feature",
                title: "AI 分析功能已上线",
                content: "接入多种 AI 模型（OpenAI/Claude/Gemini），支持 APK 智能分析和 Smali 代码解读。请先在设置中配置 API Key。",
                level: .info,
                publishDate: Date().addingTimeInterval(-259200),
                isRead: false
            )
        ]
    }
}

// MARK: - Environment Config
struct EnvironmentConfig {
    var sdkPath: String = "/Library/Android/sdk"
    var jdkPath: String = "/Library/Java/JavaVirtualMachines/jdk-17.jdk"
    var ndkPath: String = "/Library/Android/sdk/ndk/26.1.10909125"
    var buildToolsVersion: String = "34.0.0"
    var platformVersion: String = "34"
    var gradleVersion: String = "8.4"
    var kotlinVersion: String = "1.9.22"
    var apkToolVersion: String = "2.9.3"
    var dex2jarVersion: String = "2.1"
    var jadxVersion: String = "1.5.0"
    var enableAutoUpdate: Bool = true
    var enableAnalytics: Bool = false
}

// MARK: - Project Config
struct ProjectConfig {
    var projectName: String = ""
    var packageName: String = ""
    var targetSdkVersion: String = "34"
    var minSdkVersion: String = "21"
    var language: ProjectLanguage = .java
    var architecture: ProjectArchitecture = .arm64
    var enableObfuscation: Bool = false
    var enableShrink: Bool = true
    var signingConfig: String = "debug"
    var outputDir: String = ""

    enum ProjectLanguage: String, CaseIterable, Identifiable {
        case java = "Java"
        case kotlin = "Kotlin"
        var id: String { rawValue }
    }

    enum ProjectArchitecture: String, CaseIterable, Identifiable {
        case arm64 = "arm64-v8a"
        case armeabi = "armeabi-v7a"
        case x86 = "x86"
        case x8664 = "x86_64"
        case universal = "通用"
        var id: String { rawValue }
    }
}