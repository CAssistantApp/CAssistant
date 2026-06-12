import Foundation
import SwiftUI

// MARK: - APK解析服务
class APKParserService {
    
    /// 解析APK文件信息
    static func parseAPK(from url: URL) async throws -> APKInfo {
        guard url.startAccessingSecurityScopedResource() else {
            throw APKError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let fileData = try Data(contentsOf: url)
        let fileSize = fileData.count
        
        var info = APKInfo()
        info.fileSize = Int64(fileSize)
        
        // 解析AndroidManifest.xml
        info = try await parseManifest(from: fileData, into: info)
        
        // 解析DEX文件
        info.dexFiles = extractDexFiles(from: fileData)
        
        // 文件列表
        info = await parseFileList(from: fileData, into: info)
        
        return info
    }
    
    private static func parseManifest(from data: Data, into info: APKInfo) async throws -> APKInfo {
        var info = info
        
        // 使用二进制搜索模式解析
        let patterns: [(Data, (String) -> Void)] = [
            (Data("package=\"".utf8), { info.package = $0 }),
            (Data("versionName=\"".utf8), { info.versionName = $0 }),
            (Data("android:versionCode=\"".utf8), { info.versionCode = Int($0) ?? 0 }),
        ]
        
        for (pattern, handler) in patterns {
            if let range = data.range(of: pattern) {
                let start = range.upperBound
                let endData = data[start...]
                if let endRange = endData.range(of: Data("\"".utf8)) {
                    let value = String(decoding: data[start..<endRange.lowerBound], as: UTF8.self)
                    handler(value)
                }
            }
        }
        
        // 提取权限
        let permPattern = Data("uses-permission".utf8)
        var searchRange = data.startIndex..<data.endIndex
        while let range = data.range(of: permPattern, in: searchRange) {
            if let nameRange = data.range(of: Data("android:name=\"".utf8), in: range.upperBound..<data.endIndex) {
                let start = nameRange.upperBound
                if let end = data[start...].range(of: Data("\"".utf8)) {
                    let perm = String(decoding: data[start..<end.lowerBound], as: UTF8.self)
                    info.permissions.append(perm)
                }
            }
            searchRange = range.upperBound..<data.endIndex
        }
        
        // 提取Activity
        let actPattern = Data("activity".utf8)
        searchRange = data.startIndex..<data.endIndex
        while let range = data.range(of: actPattern, in: searchRange) {
            if let nameRange = data.range(of: Data("android:name=\"".utf8), in: range.upperBound..<data.endIndex) {
                let start = nameRange.upperBound
                if let end = data[start...].range(of: Data("\"".utf8)) {
                    let activity = String(decoding: data[start..<end.lowerBound], as: UTF8.self)
                    info.activities.append(activity)
                }
            }
            searchRange = range.upperBound..<data.endIndex
        }
        
        // 提取Service
        let svcPattern = Data("service".utf8)
        searchRange = data.startIndex..<data.endIndex
        while let range = data.range(of: svcPattern, in: searchRange) {
            if let nameRange = data.range(of: Data("android:name=\"".utf8), in: range.upperBound..<data.endIndex) {
                let start = nameRange.upperBound
                if let end = data[start...].range(of: Data("\"".utf8)) {
                    let service = String(decoding: data[start..<end.lowerBound], as: UTF8.self)
                    info.services.append(service)
                }
            }
            searchRange = range.upperBound..<data.endIndex
        }
        
        return info
    }
    
    private static func extractDexFiles(from data: Data) -> [String] {
        var dexFiles: [String] = []
        let dexMagic = Data([0x64, 0x65, 0x78, 0x0a, 0x30, 0x33, 0x35, 0x00]) // "dex\n035\0"
        
        var searchRange = data.startIndex..<data.endIndex
        while let range = data.range(of: dexMagic, in: searchRange) {
            let dexNumber = dexFiles.count + 1
            dexFiles.append("classes\(dexNumber > 1 ? "\(dexNumber)" : "").dex")
            searchRange = range.upperBound..<data.endIndex
        }
        
        return dexFiles.isEmpty ? ["classes.dex"] : dexFiles
    }
    
    private static func parseFileList(from data: Data, into info: APKInfo) async -> APKInfo {
        var info = info
        
        // 提取包名信息
        if info.package.isEmpty {
            let parts = info.package.split(separator: ".")
            if parts.count >= 2 {
                info.appName = String(parts.last ?? "")
            }
        }
        
        return info
    }
    
    enum APKError: Error, LocalizedError {
        case accessDenied
        case invalidFormat
        case parseFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .accessDenied: return "无法访问文件"
            case .invalidFormat: return "无效的APK格式"
            case .parseFailed(let msg): return "解析失败: \(msg)"
            }
        }
    }
}

// MARK: - 二进制搜索扩展
extension Data {
    func range(of data: Data, in range: Range<Index>? = nil) -> Range<Index>? {
        let searchRange = range ?? startIndex..<endIndex
        guard searchRange.upperBound <= endIndex else { return nil }
        
        var searchStart = searchRange.lowerBound
        while searchStart <= searchRange.upperBound - data.count {
            if self[searchStart..<searchStart + data.count] == data {
                return searchStart..<searchStart + data.count
            }
            searchStart += 1
        }
        return nil
    }
}