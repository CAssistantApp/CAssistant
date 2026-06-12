import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - 应用状态
class AppState: ObservableObject {
    @Published var importedFiles: [ImportedFile] = []
    @Published var selectedFile: ImportedFile?
    @Published var currentAPKPath: URL?
    @Published var currentAPKInfo: APKInfo?
    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0
    @Published var errorMessage: String?
    @Published var showFileImporter = false
    @Published var isDarkMode = false
    @Published var currentProject: ProjectInfo?
    
    // AI配置
    @Published var aiProvider: AIProvider = .openAI
    @Published var aiModel: String = "gpt-4"
    @Published var aiAPIKey: String = ""
    @Published var aiBaseURL: String = "https://api.openai.com/v1"
    
    // 项目列表
    @Published var projects: [ProjectInfo] = []
    
    // MARK: - APK 解析
    @MainActor
    func parseAPK(_ url: URL) async {
        isAnalyzing = true
        analysisProgress = 0
        do {
            let info = try await APKParserService.parseAPK(from: url)
            self.currentAPKInfo = info
            analysisProgress = 1.0
        } catch {
            self.errorMessage = "APK解析失败: \(error.localizedDescription)"
        }
        isAnalyzing = false
    }
}

// MARK: - 导入的文件
struct ImportedFile: Identifiable {
    let id = UUID()
    let name: String
    let `extension`: String
    let data: Data
    let url: URL
    
    var fileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(data.count))
    }
    
    var fileType: FileType {
        switch `extension`.lowercased() {
        case "apk": return .apk
        case "ipa": return .ipa
        case "dex": return .dex
        case "so": return .so
        case "smali": return .smali
        case "arsc": return .arsc
        case "xml": return .xml
        case "txt", "md": return .text
        case "json": return .json
        default: return .unknown
        }
    }
}

enum FileType: String, CaseIterable {
    case apk = "APK"
    case ipa = "IPA"
    case dex = "DEX"
    case so = "SO"
    case smali = "Smali"
    case arsc = "Arsc"
    case xml = "XML"
    case text = "文本"
    case json = "JSON"
    case unknown = "未知"
    
    var icon: String {
        switch self {
        case .apk: return "doc.zip"
        case .ipa: return "doc.fill"
        case .dex: return "doc.text.magnifyingglass"
        case .so: return "cpu"
        case .smali: return "chevron.left.forwardslash.chevron.right"
        case .arsc: return "paintpalette"
        case .xml: return "doc.xml"
        case .text: return "doc.text"
        case .json: return "curlybraces"
        case .unknown: return "questionmark"
        }
    }
}

// MARK: - APK信息模型
struct APKInfo: Codable {
    var package: String = ""
    var appName: String = ""
    var versionName: String = ""
    var versionCode: Int = 0
    var minSDK: Int = 0
    var targetSDK: Int = 0
    var mainActivity: String = ""
    var fileSize: Int64 = 0
    
    var permissions: [String] = []
    var activities: [String] = []
    var services: [String] = []
    var receivers: [String] = []
    var providers: [String] = []
    
    var classes: [String: [String]] = [:]
    var certificates: [[String: String]] = []
    var manifestXML: String = ""
    var dexFiles: [String] = []
    
    var fileSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}

// MARK: - AI Provider
enum AIProvider: String, CaseIterable {
    case openAI = "OpenAI"
    case claude = "Claude"
    case local = "本地模型"
    case custom = "自定义"
}

// MARK: - 项目信息
struct ProjectInfo: Identifiable, Codable {
    let id = UUID()
    var name: String
    var path: String
    var type: String
    var created: Date
    var lastOpened: Date
}

// MARK: - 聊天消息
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    enum MessageRole: String {
        case user = "user"
        case assistant = "assistant"
    }
}

// MARK: - 文件导入管理器
struct FileImportManager {
    static let supportedTypes: [UTType] = [
        .archive,
        .application,
        .data,
        .zip,
        .xml,
        .plainText,
        .json,
        .executable,
        .binaryPropertyList,
        .dylib,
        .shellScript,
        UTType(filenameExtension: "apk") ?? .data,
        UTType(filenameExtension: "ipa") ?? .data,
        UTType(filenameExtension: "dex") ?? .data,
        UTType(filenameExtension: "so") ?? .data,
        UTType(filenameExtension: "smali") ?? .plainText,
        UTType(filenameExtension: "arsc") ?? .data,
        UTType(filenameExtension: "jadx") ?? .data,
        UTType(filenameExtension: "jar") ?? .archive,
        UTType(filenameExtension: "keystore") ?? .data,
        UTType(filenameExtension: "jks") ?? .data,
        UTType(filenameExtension: "p12") ?? .data,
        UTType(filenameExtension: "cer") ?? .data,
        UTType(filenameExtension: "crt") ?? .data,
        UTType(filenameExtension: "dex2jar") ?? .data,
        UTType(filenameExtension: "class") ?? .data,
        UTType(filenameExtension: "jar") ?? .archive,
        UTType(filenameExtension: "aar") ?? .archive,
    ]
}