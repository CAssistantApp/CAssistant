import Foundation
import SwiftUI

// MARK: - 安全文件处理工具
struct SecurityScopedHelper {
    
    /// 安全读取文件内容
    static func readSecurityScopedFile(at url: URL) throws -> Data {
        guard url.startAccessingSecurityScopedResource() else {
            throw SecurityError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        return try Data(contentsOf: url)
    }
    
    /// 安全读取文件字符串
    static func readSecurityScopedString(at url: URL) throws -> String {
        let data = try readSecurityScopedFile(at: url)
        return String(decoding: data, as: UTF8.self)
    }
    
    enum SecurityError: Error, LocalizedError {
        case accessDenied
        
        var errorDescription: String? {
            switch self {
            case .accessDenied: return "安全范围访问被拒绝"
            }
        }
    }
}

// MARK: - 文件类型检测
struct FileTypeDetector {
    static func detect(from url: URL) -> FileType {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "apk": return .apk
        case "ipa": return .ipa
        case "dex": return .dex
        case "so": return .so
        case "smali": return .smali
        case "arsc": return .arsc
        case "xml": return .xml
        case "txt", "md", "markdown": return .text
        case "json": return .json
        default: return .unknown
        }
    }
}

// MARK: - 文件大小格式化
extension Int64 {
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}

extension Int {
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }
}