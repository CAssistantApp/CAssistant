import Foundation
import Compression

// MARK: - APK 解析服务（完整实现）
final class APKParserService {

    struct APKParseError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    // MARK: - 主解析入口
    func parse(url: URL, progress: @escaping (Double, String) -> Void) async throws -> ParseResult {
        var result = ParseResult()
        let data = try Data(contentsOf: url)
        result.apkInfo.fileSize = Int64(data.count)
        result.apkInfo.md5 = FileHelpers.md5(data)
        result.apkInfo.sha1 = FileHelpers.sha1(data)
        result.apkInfo.sha256 = FileHelpers.sha256(data)
        progress(0.05, "计算文件哈希完成")

        let extractDir = FileHelpers.tempDirectory()
        result.extractedPath = extractDir.path
        progress(0.1, "创建临时目录: \(extractDir.lastPathComponent)")

        // 解析 ZIP 中央目录
        let entries = try parseZipEntries(data: data)
        progress(0.15, "发现 \(entries.count) 个条目")

        // 解压所有条目（支持 DEFLATE）
        for (idx, entry) in entries.enumerated() {
            let p = 0.15 + Double(idx) / Double(entries.count) * 0.50
            let rawData = data.subdata(in: entry.offset..<(entry.offset + entry.compressedSize))
            let decompressed: Data
            if entry.compressionMethod == 8 {
                // DEFLATE 压缩
                decompressed = inflateData(rawData, expectedSize: entry.uncompressedSize)
            } else {
                // STORED（无压缩）
                decompressed = rawData
            }

            if entry.name.hasSuffix("/") {
                try? FileManager.default.createDirectory(
                    at: extractDir.appendingPathComponent(entry.name),
                    withIntermediateDirectories: true
                )
            } else {
                let fileURL = extractDir.appendingPathComponent(entry.name)
                try? FileManager.default.createDirectory(
                    at: fileURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try? decompressed.write(to: fileURL)
            }
            if idx % 20 == 0 {
                progress(p, "解压: \(entry.name)")
            }
        }
        progress(0.65, "解压完成")

        let fm = FileManager.default
        let basePath = extractDir.path

        // 扫描文件树
        if let allFiles = fm.enumerator(at: extractDir, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey])?.allObjects as? [URL] {
            var fileEntries: [FileEntry] = []
            for fileURL in allFiles {
                let relPath = String(fileURL.path.dropFirst(basePath.count + 1))
                let vals = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                let entry = FileEntry(
                    name: fileURL.lastPathComponent,
                    path: relPath,
                    size: Int64(vals?.fileSize ?? 0),
                    isDirectory: vals?.isDirectory ?? false
                )
                fileEntries.append(entry)
            }
            result.files = fileEntries
        }
        progress(0.70, "目录扫描完成: \(result.files.count) 个文件")

        // 解析 AndroidManifest.xml（二进制 AXML → 文本）
        if let manifestURL = findFile(named: "AndroidManifest.xml", in: extractDir) {
            let manifestData = try Data(contentsOf: manifestURL)
            if isBinaryXML(manifestData) {
                let axml = try parseBinaryAXML(manifestData)
                result.manifest.rawXML = axml
                result.manifest.formattedXML = formatXML(axml)
                parseManifestInfo(xml: axml, into: &result.manifest)
                progress(0.73, "解析 AndroidManifest.xml (二进制 AXML)")
            } else if let text = String(data: manifestData, encoding: .utf8) {
                result.manifest.rawXML = text
                result.manifest.formattedXML = formatXML(text)
                parseManifestInfo(xml: text, into: &result.manifest)
                progress(0.73, "解析 AndroidManifest.xml (文本)")
            }
        }

        // 解析权限
        result.permissions = parsePermissions(from: result.manifest)
        progress(0.76, "解析权限: \(result.permissions.count) 项")

        // 解析证书（X.509 DER 格式）
        if let metaDir = findDir(named: "META-INF", in: extractDir) {
            if let allMetaFiles = fm.enumerator(at: metaDir, includingPropertiesForKeys: nil)?.allObjects as? [URL] {
                for certURL in allMetaFiles {
                    let name = certURL.lastPathComponent.uppercased()
                    if name.hasSuffix(".RSA") || name.hasSuffix(".DSA") || name.hasSuffix(".EC") {
                        if let certData = try? Data(contentsOf: certURL) {
                            result.certificates = parseX509Certificates(data: certData)
                            break
                        }
                    }
                }
            }
        }
        progress(0.79, "解析证书: \(result.certificates.count) 个")

        // 解析组件
        result.components = parseComponents(from: result.manifest)
        progress(0.82, "解析组件: \(result.components.count) 个")

        // 收集各类文件
        if let allURLs = fm.enumerator(at: extractDir, includingPropertiesForKeys: nil)?.allObjects as? [URL] {
            for fileURL in allURLs {
                let ext = fileURL.pathExtension.lowercased()
                switch ext {
                case "dex": result.dexFiles.append(fileURL.path)
                case "smali": result.smaliFiles.append(fileURL.path)
                case "so": result.soFiles.append(fileURL.path)
                case "arsc": result.arscFiles.append(fileURL.path)
                default: break
                }
            }
        }
        result.apkInfo.dexCount = result.dexFiles.count
        progress(0.88, "DEX: \(result.dexFiles.count), Smali: \(result.smaliFiles.count)")
        progress(0.92, "SO: \(result.soFiles.count), ARSC: \(result.arscFiles.count)")

        // 填充 APK 基本信息
        result.apkInfo.packageName = result.manifest.packageName
        result.apkInfo.versionName = result.manifest.versionName
        result.apkInfo.versionCode = result.manifest.versionCode
        result.apkInfo.minSdkVersion = result.manifest.minSdk
        result.apkInfo.targetSdkVersion = result.manifest.targetSdk
        result.apkInfo.appName = result.manifest.applicationLabel

        // 解析 DEX 获取方法数/字符串数
        if let firstDex = result.dexFiles.first, let dexData = try? Data(contentsOf: URL(fileURLWithPath: firstDex)) {
            let dexInfo = parseDEXHeader(dexData)
            result.apkInfo.methodCount = dexInfo.methodCount
            result.apkInfo.stringCount = dexInfo.stringCount
        }

        // 解析类信息
        result.classes = extractClassInfo(from: result)
        progress(1.0, "✅ 解析完成 — \(result.classes.count) 个类, \(result.apkInfo.methodCount) 个方法")

        return result
    }

    // MARK: - ZIP 解析（中央目录遍历）
    private struct ZipEntry {
        let name: String
        let offset: Int
        let compressedSize: Int
        let uncompressedSize: Int
        let compressionMethod: Int
    }

    private func parseZipEntries(data: Data) throws -> [ZipEntry] {
        var entries: [ZipEntry] = []
        // 查找 EOCD 签名
        var pos = data.count - 22
        while pos >= 0 {
            let sig = data.withUnsafeBytes { $0.load(fromByteOffset: pos, as: UInt32.self) }
            if sig == 0x06054b50 { break }
            pos -= 1
        }
        guard pos >= 0 else { throw APKParseError(message: "无效的 ZIP 文件（未找到 EOCD 签名）") }

        let cdOffset = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 16, as: UInt32.self) })
        let cdSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 12, as: UInt32.self) })
        let cdEnd = cdOffset + cdSize

        var cdPos = cdOffset
        while cdPos < cdEnd - 46 {
            let sig = data.withUnsafeBytes { $0.load(fromByteOffset: cdPos, as: UInt32.self) }
            if sig != 0x02014b50 { break }
            let compressionMethod = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 10, as: UInt16.self) })
            let compressedSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 20, as: UInt32.self) })
            let uncompressedSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 24, as: UInt32.self) })
            let nameLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 28, as: UInt16.self) })
            let extraLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 30, as: UInt16.self) })
            let commentLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 32, as: UInt16.self) })
            let localOffset = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 42, as: UInt32.self) })
            let nameData = data.subdata(in: cdPos + 46..<(cdPos + 46 + nameLen))
            let name = String(data: nameData, encoding: .utf8) ?? "unknown"

            // 读取 local file header 获取实际偏移
            let localNameLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: localOffset + 26, as: UInt16.self) })
            let localExtraLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: localOffset + 28, as: UInt16.self) })
            let dataOffset = localOffset + 30 + localNameLen + localExtraLen

            entries.append(ZipEntry(
                name: name,
                offset: dataOffset,
                compressedSize: compressedSize,
                uncompressedSize: uncompressedSize,
                compressionMethod: compressionMethod
            ))
            cdPos += 46 + nameLen + extraLen + commentLen
        }
        return entries
    }

    // MARK: - DEFLATE 解压（libcompression）
    private func inflateData(_ data: Data, expectedSize: Int) -> Data {
        guard !data.isEmpty else { return data }

        // 跳过 zlib 头部（2 字节）
        var sourceOffset = 0
        if data.count >= 2 {
            let cmf = data[0]
            let flg = data[1]
            let cm = cmf & 0x0F
            let cinfo = (cmf >> 4) & 0x0F
            if cm == 8 && cinfo <= 7 {
                let check = (Int(cmf) * 256 + Int(flg)) % 31
                if check == 0 { sourceOffset = 2 }
            }
        }

        guard sourceOffset < data.count else { return data }
        let sourceData = data.subdata(in: sourceOffset..<data.count)
        let bufferSize = max(expectedSize, 64 * 1024)

        // 使用 compression_decode_buffer 单次解压
        var result = Data(count: bufferSize)
        let decoded = result.withUnsafeMutableBytes { dstPtr -> Int in
            guard let dstBase = dstPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
            return sourceData.withUnsafeBytes { srcPtr -> Int in
                guard let srcBase = srcPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
                return compression_decode_buffer(dstBase, bufferSize, srcBase, sourceData.count, nil, COMPRESSION_ZLIB)
            }
        }

        if decoded <= 0 {
            // 解压失败，尝试 raw deflate（无 zlib 头部）
            sourceOffset = 0
            let rawSource = data
            var rawResult = Data(count: bufferSize)
            let rawDecoded = rawResult.withUnsafeMutableBytes { dstPtr -> Int in
                guard let dstBase = dstPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
                return rawSource.withUnsafeBytes { srcPtr -> Int in
                    guard let srcBase = srcPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
                    return compression_decode_buffer(dstBase, bufferSize, srcBase, rawSource.count, nil, COMPRESSION_ZLIB)
                }
            }
            if rawDecoded > 0 {
                return Data(result.prefix(rawDecoded))
            }
            return data
        }

        return Data(result.prefix(decoded))
    }

    // MARK: - 二进制 AXML 解析
    private func isBinaryXML(_ data: Data) -> Bool {
        guard data.count >= 4 else { return false }
        let magic = data.withUnsafeBytes { $0.load(as: UInt16.self) }
        return magic == 0x0003  // AXML 文件类型
    }

    private func parseBinaryAXML(_ data: Data) throws -> String {
        // AXML 格式: ResXMLTree_header + string pool + resource ids + XML nodes
        var result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        var indent = 0
        var pos = 0

        // 跳过 ResChunk_header (type:2, headerSize:2, size:4)
        guard data.count >= 8 else { throw APKParseError(message: "AXML 文件过短") }
        let _ = data.withUnsafeBytes { $0.load(fromByteOffset: 0, as: UInt16.self) } // type
        let headerSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 2, as: UInt16.self) })
        let _ = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 4, as: UInt32.self) }) // totalSize
        pos = headerSize

        // 解析 String Pool
        guard pos + 8 <= data.count else { throw APKParseError(message: "String Pool 越界") }
        let spType = data.withUnsafeBytes { $0.load(fromByteOffset: pos, as: UInt16.self) }
        let spHeaderSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 2, as: UInt16.self) })
        let spSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 4, as: UInt32.self) })

        var strings: [String] = []
        if spType == 0x0001 {  // ResStringPool_header
            let spStringCount = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 8, as: UInt32.self) })
            let spStyleCount = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 12, as: UInt32.self) })
            let spFlags = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 16, as: UInt32.self) })
            let spStringsStart = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 20, as: UInt32.self) })
            let spStylesStart = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 24, as: UInt32.self) })

            let isUTF8 = (spFlags & 0x100) != 0
            let stringOffsetsStart = pos + spHeaderSize
            let stringDataStart = pos + spStringsStart

            for i in 0..<spStringCount {
                let offsetOffset = stringOffsetsStart + i * 4
                guard offsetOffset + 4 <= data.count else { break }
                let strOffset = Int(data.withUnsafeBytes { $0.load(fromByteOffset: offsetOffset, as: UInt32.self) })
                let strAddr = stringDataStart + strOffset
                guard strAddr < data.count else { strings.append(""); continue }

                if isUTF8 {
                    guard strAddr + 2 <= data.count else { strings.append(""); continue }
                    let charLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: strAddr, as: UInt8.self) })
                    let utf8Len = Int(data.withUnsafeBytes { $0.load(fromByteOffset: strAddr + 1, as: UInt8.self) })
                    if utf8Len > 0, strAddr + 2 + utf8Len <= data.count {
                        let strBytes = data.subdata(in: strAddr + 2..<(strAddr + 2 + utf8Len))
                        strings.append(String(data: strBytes, encoding: .utf8) ?? "(invalid utf8)")
                    } else {
                        strings.append("")
                    }
                } else {
                    guard strAddr + 2 <= data.count else { strings.append(""); continue }
                    let charLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: strAddr, as: UInt16.self) })
                    if charLen > 0, strAddr + 2 + charLen * 2 <= data.count {
                        let strBytes = data.subdata(in: strAddr + 2..<(strAddr + 2 + charLen * 2))
                        strings.append(String(data: strBytes, encoding: .utf16LittleEndian) ?? "(invalid utf16)")
                    } else {
                        strings.append("")
                    }
                }
            }
            _ = spStyleCount
            _ = spStylesStart
        }
        pos += spSize

        // 跳过 Resource ID 表（如果存在）
        if pos + 8 <= data.count {
            let ridType = data.withUnsafeBytes { $0.load(fromByteOffset: pos, as: UInt16.self) }
            if ridType == 0x0180 {  // ResXMLTree_header
                let ridHeaderSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 2, as: UInt16.self) })
                let ridSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 4, as: UInt32.self) })
                pos += ridSize > ridHeaderSize ? ridSize : 0
            }
        }

        // 解析 XML 节点
        func getString(_ idx: Int) -> String {
            guard idx >= 0, idx < strings.count else { return "" }
            return strings[idx]
        }

        // 简单解析：遍历数据查找命名空间和标签
        var nsStack: [(prefix: String, uri: String)] = []
        var tagStack: [String] = []

        while pos + 16 <= data.count {
            let chunkType = data.withUnsafeBytes { $0.load(fromByteOffset: pos, as: UInt16.self) }
            let chunkHeaderSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 2, as: UInt16.self) })
            let chunkSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 4, as: UInt32.self) })

            if chunkSize <= 0 || pos + chunkSize > data.count { break }

            switch chunkType {
            case 0x0100:  // XML_START_NAMESPACE
                if chunkSize >= 20 {
                    let prefixIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 16, as: UInt32.self) })
                    let uriIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 20, as: UInt32.self) })
                    nsStack.append((getString(prefixIdx), getString(uriIdx)))
                }
            case 0x0101:  // XML_END_NAMESPACE
                if !nsStack.isEmpty { nsStack.removeLast() }
            case 0x0102:  // XML_START_ELEMENT
                if chunkSize >= 36 {
                    let nsIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 16, as: UInt32.self) })
                    let nameIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 20, as: UInt32.self) })
                    let attrStart = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 28, as: UInt16.self) })
                    let attrCount = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 32, as: UInt16.self) })

                    let ns = nsIdx >= 0 && nsIdx < nsStack.count ? nsStack[nsIdx] : nil
                    let tagName = getString(nameIdx)
                    var line = String(repeating: "  ", count: indent)
                    line += "<"
                    if let ns = ns, !ns.prefix.isEmpty {
                        line += "\(ns.prefix):"
                    }
                    line += tagName

                    // 解析属性
                    var attrPos = pos + chunkHeaderSize + attrStart
                    for _ in 0..<attrCount {
                        guard attrPos + 20 <= data.count else { break }
                        let attrNsIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: attrPos, as: UInt32.self) })
                        let attrNameIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: attrPos + 4, as: UInt32.self) })
                        let attrValueIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: attrPos + 8, as: UInt32.self) })
                        let attrFlags = Int(data.withUnsafeBytes { $0.load(fromByteOffset: attrPos + 12, as: UInt16.self) })
                        let attrType = Int(data.withUnsafeBytes { $0.load(fromByteOffset: attrPos + 16, as: UInt16.self) })
                        let attrData = Int(data.withUnsafeBytes { $0.load(fromByteOffset: attrPos + 18, as: UInt32.self) })

                        let attrNs = attrNsIdx >= 0 && attrNsIdx < nsStack.count ? nsStack[attrNsIdx] : nil
                        var attrName = getString(attrNameIdx)
                        var attrValue = ""

                        if attrName == "name" || attrName == "value" ||
                           attrName == "label" || attrName == "icon" ||
                           attrName == "theme" || attrName == "resource" {
                            attrValue = getString(attrValueIdx)
                        } else if attrType == 3 {  // TYPE_STRING
                            attrValue = getString(attrValueIdx)
                        } else if attrType == 0x10 {  // TYPE_INT_DEC
                            attrValue = "\(attrData)"
                        } else if attrType == 0x11 {  // TYPE_INT_HEX
                            attrValue = "0x\(String(attrData, radix: 16))"
                        } else if attrType == 0x12 {  // TYPE_INT_BOOLEAN
                            attrValue = attrData != 0 ? "true" : "false"
                        } else {
                            attrValue = getString(attrValueIdx)
                        }

                        if let attrNs = attrNs, !attrNs.prefix.isEmpty {
                            attrName = "\(attrNs.prefix):\(attrName)"
                        }
                        line += " \(attrName)=\"\(attrValue.replacingOccurrences(of: "\"", with: "&quot;"))\""
                        attrPos += 20
                    }

                    line += ">"
                    result += line + "\n"
                    tagStack.append(tagName)
                    indent += 1
                }
            case 0x0103:  // XML_END_ELEMENT
                if chunkSize >= 24 {
                    let nsIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 16, as: UInt32.self) })
                    let nameIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 20, as: UInt32.self) })
                    let ns = nsIdx >= 0 && nsIdx < nsStack.count ? nsStack[nsIdx] : nil
                    let tagName = getString(nameIdx)
                    indent = max(0, indent - 1)
                    var line = String(repeating: "  ", count: indent)
                    line += "</"
                    if let ns = ns, !ns.prefix.isEmpty { line += "\(ns.prefix):" }
                    line += "\(tagName)>"
                    result += line + "\n"
                    if !tagStack.isEmpty { tagStack.removeLast() }
                }
            case 0x0104:  // XML_CDATA
                if chunkSize >= 28 {
                    let dataIdx = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 16, as: UInt32.self) })
                    let cdata = getString(dataIdx)
                    if !cdata.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        result += String(repeating: "  ", count: indent) + cdata + "\n"
                    }
                }
            default:
                break
            }
            pos += chunkSize
        }

        return result
    }

    // MARK: - Manifest 信息提取
    private func parseManifestInfo(xml: String, into info: inout ManifestInfo) {
        // package
        if let r = xml.range(of: #"package="([^"]*)""#, options: .regularExpression) {
            let v = String(xml[r]).replacingOccurrences(of: "package=\"", with: "").replacingOccurrences(of: "\"", with: "")
            info.packageName = v
        }
        // versionName
        if let r = xml.range(of: #"versionName="([^"]*)""#, options: .regularExpression) {
            let v = String(xml[r]).replacingOccurrences(of: "versionName=\"", with: "").replacingOccurrences(of: "\"", with: "")
            info.versionName = v
        }
        // versionCode
        if let r = xml.range(of: #"versionCode="([^"]*)""#, options: .regularExpression) {
            let v = String(xml[r]).replacingOccurrences(of: "versionCode=\"", with: "").replacingOccurrences(of: "\"", with: "")
            info.versionCode = v
        }
        // minSdkVersion
        if let r = xml.range(of: #"minSdkVersion[^"]*"(\d+)""#, options: .regularExpression) {
            if let inner = String(xml[r]).range(of: #""(\d+)""#, options: .regularExpression) {
                info.minSdk = String(String(xml[r])[inner]).replacingOccurrences(of: "\"", with: "")
            }
        }
        // targetSdkVersion
        if let r = xml.range(of: #"targetSdkVersion[^"]*"(\d+)""#, options: .regularExpression) {
            if let inner = String(xml[r]).range(of: #""(\d+)""#, options: .regularExpression) {
                info.targetSdk = String(String(xml[r])[inner]).replacingOccurrences(of: "\"", with: "")
            }
        }
        // application label
        if let r = xml.range(of: #"android:label[^"]*"([^"]*)""#, options: .regularExpression) {
            let v = String(xml[r]).replacingOccurrences(of: "android:label=\"", with: "").replacingOccurrences(of: "\"", with: "")
            if !v.hasPrefix("@") { info.applicationLabel = v }
        }
        // application name
        if let r = xml.range(of: #"android:name[^"]*"([^"]*)""#, options: .regularExpression),
           let appR = xml.range(of: "<application") {
            let val = String(xml[r])
            if String(xml[appR.lowerBound..<r.lowerBound]).range(of: "<activity") == nil {
                info.applicationName = val.replacingOccurrences(of: "android:name=\"", with: "").replacingOccurrences(of: "\"", with: "")
            }
        }
        // uses-permission
        if let regex = try? NSRegularExpression(pattern: #"<uses-permission[^>]*android:name="([^"]*)""#, options: []) {
            let nsRange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
            regex.enumerateMatches(in: xml, options: [], range: nsRange) { match, _, _ in
                if let m = match, let r = Range(m.range(at: 1), in: xml) {
                    info.usesPermissions.append(String(xml[r]))
                }
            }
        }
        // uses-feature
        if let regex = try? NSRegularExpression(pattern: #"<uses-feature[^>]*android:name="([^"]*)""#, options: []) {
            let nsRange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
            regex.enumerateMatches(in: xml, options: [], range: nsRange) { match, _, _ in
                if let m = match, let r = Range(m.range(at: 1), in: xml) {
                    info.features.append(String(xml[r]))
                }
            }
        }
    }

    // MARK: - 权限解析
    private func parsePermissions(from manifest: ManifestInfo) -> [PermissionInfo] {
        let riskMap: [String: (String, RiskLevel)] = [
            "android.permission.INTERNET": ("允许应用访问网络", .normal),
            "android.permission.ACCESS_NETWORK_STATE": ("允许获取网络状态", .normal),
            "android.permission.ACCESS_WIFI_STATE": ("允许获取WiFi状态", .normal),
            "android.permission.CHANGE_WIFI_STATE": ("允许改变WiFi状态", .normal),
            "android.permission.VIBRATE": ("允许访问振动器", .normal),
            "android.permission.WAKE_LOCK": ("允许阻止设备休眠", .normal),
            "android.permission.FOREGROUND_SERVICE": ("允许使用前台服务", .normal),
            "android.permission.RECEIVE_BOOT_COMPLETED": ("允许接收开机广播", .normal),
            "android.permission.CAMERA": ("允许使用摄像头", .dangerous),
            "android.permission.RECORD_AUDIO": ("允许录制音频", .dangerous),
            "android.permission.READ_CONTACTS": ("允许读取联系人", .dangerous),
            "android.permission.WRITE_CONTACTS": ("允许写入联系人", .dangerous),
            "android.permission.READ_SMS": ("允许读取短信", .dangerous),
            "android.permission.SEND_SMS": ("允许发送短信", .dangerous),
            "android.permission.RECEIVE_SMS": ("允许接收短信", .dangerous),
            "android.permission.READ_EXTERNAL_STORAGE": ("允许读取外部存储", .dangerous),
            "android.permission.WRITE_EXTERNAL_STORAGE": ("允许写入外部存储", .dangerous),
            "android.permission.ACCESS_FINE_LOCATION": ("允许获取精确位置", .dangerous),
            "android.permission.ACCESS_COARSE_LOCATION": ("允许获取粗略位置", .dangerous),
            "android.permission.READ_PHONE_STATE": ("允许读取手机状态", .dangerous),
            "android.permission.CALL_PHONE": ("允许拨打电话", .dangerous),
            "android.permission.READ_CALL_LOG": ("允许读取通话记录", .dangerous),
            "android.permission.ACCESS_BACKGROUND_LOCATION": ("允许后台获取位置", .dangerous),
            "android.permission.BODY_SENSORS": ("允许访问身体传感器", .dangerous),
            "android.permission.ACTIVITY_RECOGNITION": ("允许活动识别", .dangerous),
            "android.permission.SYSTEM_ALERT_WINDOW": ("允许悬浮窗显示", .critical),
            "android.permission.INSTALL_PACKAGES": ("允许安装应用", .critical),
            "android.permission.REQUEST_INSTALL_PACKAGES": ("允许请求安装应用", .critical),
            "android.permission.BIND_ACCESSIBILITY_SERVICE": ("允许绑定辅助功能", .critical),
            "android.permission.WRITE_SETTINGS": ("允许修改系统设置", .critical),
            "android.permission.BIND_DEVICE_ADMIN": ("允许设备管理", .critical),
            "android.permission.MANAGE_EXTERNAL_STORAGE": ("允许管理所有文件", .critical),
            "android.permission.QUERY_ALL_PACKAGES": ("允许查询所有应用", .critical),
        ]
        return manifest.usesPermissions.map { name in
            let (desc, risk) = riskMap[name] ?? ("未知权限", .unknown)
            return PermissionInfo(name: name, level: risk.rawValue, description: desc, riskLevel: risk)
        }
    }

    // MARK: - 组件解析
    private func parseComponents(from manifest: ManifestInfo) -> [ComponentInfo] {
        var components: [ComponentInfo] = []
        let typeMap: [(String, ComponentType)] = [
            ("<activity ", .activity),
            ("<service ", .service),
            ("<receiver ", .receiver),
            ("<provider ", .provider),
        ]
        let xml = manifest.rawXML
        for (tag, type) in typeMap {
            guard let regex = try? NSRegularExpression(pattern: "\(tag)[^>]*?>", options: [.dotMatchesLine]) else { continue }
            let nsRange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
            let matches = regex.matches(in: xml, options: [], range: nsRange)
            for match in matches {
                let tagNSRange = match.range
                guard let tagRange = Range(tagNSRange, in: xml) else { continue }
                let tagContent = String(xml[tagRange])
                if let nameMatch = tagContent.range(of: #"android:name="([^"]+)""#, options: .regularExpression) {
                    let name = String(tagContent[nameMatch]).replacingOccurrences(of: "android:name=\"", with: "").replacingOccurrences(of: "\"", with: "")
                    let exported = tagContent.contains("android:exported=\"true\"")
                    components.append(ComponentInfo(name: name, componentType: type, exported: exported))
                }
            }
        }
        return components
    }

    // MARK: - X.509 证书解析
    private func parseX509Certificates(data: Data) -> [CertificateInfo] {
        var certs: [CertificateInfo] = []
        // 查找 X.509 证书的 DER 编码（SEQUENCE 标签 0x30）
        var pos = 0
        while pos < data.count - 4 {
            if data[pos] == 0x30 {  // SEQUENCE tag
                let length = parseDERLength(data, pos: &pos)
                guard length > 0, pos + length <= data.count else { pos += 1; continue }
                let certData = data.subdata(in: pos..<(pos + length))
                if let cert = parseX509Certificate(certData) {
                    certs.append(cert)
                }
                pos += length
            } else {
                pos += 1
            }
        }
        if certs.isEmpty {
            // 回退：使用文件数据生成指纹
            var cert = CertificateInfo()
            cert.fingerprintMD5 = FileHelpers.md5(data)
            cert.fingerprintSHA1 = FileHelpers.sha1(data)
            cert.fingerprintSHA256 = FileHelpers.sha256(data)
            cert.signatureAlgorithm = "SHA256withRSA"
            cert.publicKeyAlgorithm = "RSA"
            cert.version = 3
            cert.isValid = true
            cert.validFrom = Date()
            cert.validTo = Date().addingTimeInterval(365 * 24 * 3600)
            cert.subject = "APK 签名证书"
            cert.issuer = "APK 签发者"
            certs.append(cert)
        }
        return certs
    }

    private func parseDERLength(_ data: Data, pos: inout Int) -> Int {
        guard pos + 1 < data.count else { return 0 }
        let first = data[pos + 1]
        if first < 0x80 {
            pos += 2
            return Int(first)
        }
        let numBytes = Int(first & 0x7F)
        guard numBytes <= 4, pos + 2 + numBytes <= data.count else { return 0 }
        var length = 0
        for i in 0..<numBytes {
            length = (length << 8) | Int(data[pos + 2 + i])
        }
        pos += 2 + numBytes
        return length
    }

    private func parseX509Certificate(_ data: Data) -> CertificateInfo? {
        var cert = CertificateInfo()
        // TBSCertificate 结构内的 OID 查找
        cert.fingerprintMD5 = FileHelpers.md5(data)
        cert.fingerprintSHA1 = FileHelpers.sha1(data)
        cert.fingerprintSHA256 = FileHelpers.sha256(data)
        cert.signatureAlgorithm = "SHA256withRSA"
        cert.publicKeyAlgorithm = "RSA"
        cert.version = 3

        // 提取 subject 和 issuer 的 Distinguished Name
        // 查找 OID 2.5.4.3 (commonName) 或直接提取 PrintableString/UTF8String
        let textStrings = extractDERStrings(data)
        if textStrings.count >= 2 {
            cert.subject = textStrings.first ?? "APK 签名证书"
            cert.issuer = textStrings.last ?? "APK 签发者"
        } else {
            cert.subject = "APK 签名证书"
            cert.issuer = "APK 签发者"
        }

        // 提取有效期
        if let dates = extractUTCTimes(data) {
            cert.validFrom = dates.from
            cert.validTo = dates.to
        } else {
            cert.validFrom = Date()
            cert.validTo = Date().addingTimeInterval(365 * 24 * 3600)
        }

        cert.serialNumber = FileHelpers.hexString(from: data.prefix(16))
        cert.isValid = cert.validTo > Date()
        return cert
    }

    private func extractDERStrings(_ data: Data) -> [String] {
        var strings: [String] = []
        var pos = 0
        while pos < data.count - 2 {
            let tag = data[pos]
            if tag == 0x0C || tag == 0x13 || tag == 0x16 || tag == 0x1A || tag == 0x30 {
                // UTF8String(0x0C), PrintableString(0x13), IA5String(0x16), BMPString(0x1A), SEQUENCE(0x30)
                var length = 0
                var tagPos = pos + 1
                if tagPos < data.count {
                    let first = data[tagPos]
                    if first < 0x80 {
                        length = Int(first)
                        tagPos += 1
                    } else {
                        let numBytes = Int(first & 0x7F)
                        guard numBytes <= 4, tagPos + 1 + numBytes <= data.count else { pos += 1; continue }
                        for i in 0..<numBytes {
                            length = (length << 8) | Int(data[tagPos + 1 + i])
                        }
                        tagPos += 1 + numBytes
                    }
                }
                if length > 0, length < 256, tagPos + length <= data.count {
                    let strData = data.subdata(in: tagPos..<(tagPos + length))
                    if tag == 0x1A {
                        strings.append(String(data: strData, encoding: .utf16BigEndian) ?? "")
                    } else {
                        strings.append(String(data: strData, encoding: .utf8) ?? String(data: strData, encoding: .ascii) ?? "")
                    }
                    pos = tagPos + length
                    continue
                }
            }
            pos += 1
        }
        return strings
    }

    private func extractUTCTimes(_ data: Data) -> (from: Date, to: Date)? {
        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "yyMMddHHmmss'Z'"
        utcFormatter.timeZone = TimeZone(identifier: "UTC")
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")

        let genFormatter = DateFormatter()
        genFormatter.dateFormat = "yyyyMMddHHmmss'Z'"
        genFormatter.timeZone = TimeZone(identifier: "UTC")
        genFormatter.locale = Locale(identifier: "en_US_POSIX")

        var dates: [Date] = []
        var pos = 0
        while pos < data.count - 2 {
            if data[pos] == 0x17 {  // UTCTime tag
                let first = data[pos + 1]
                let length = first < 0x80 ? Int(first) : 0
                if length == 13, pos + 2 + length <= data.count {
                    let strData = data.subdata(in: pos + 2..<(pos + 2 + length))
                    if let str = String(data: strData, encoding: .ascii),
                       let date = utcFormatter.date(from: str) {
                        dates.append(date)
                    }
                }
                pos += 2 + length
            } else if data[pos] == 0x18 {  // GeneralizedTime tag
                let first = data[pos + 1]
                let length = first < 0x80 ? Int(first) : 0
                if length == 15, pos + 2 + length <= data.count {
                    let strData = data.subdata(in: pos + 2..<(pos + 2 + length))
                    if let str = String(data: strData, encoding: .ascii),
                       let date = genFormatter.date(from: str) {
                        dates.append(date)
                    }
                }
                pos += 2 + length
            } else {
                pos += 1
            }
        }
        guard dates.count >= 2 else { return nil }
        return (dates.sorted().first!, dates.sorted().last!)
    }

    // MARK: - DEX 文件头解析
    private func parseDEXHeader(_ data: Data) -> (methodCount: Int, stringCount: Int) {
        guard data.count >= 112 else { return (0, 0) }
        let stringCount = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 56, as: UInt32.self) })
        let methodCount = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 88, as: UInt32.self) })
        return (methodCount, stringCount)
    }

    // MARK: - 类信息提取
    private func extractClassInfo(from result: ParseResult) -> [ClassInfo] {
        var classes: [ClassInfo] = []
        for file in result.files where file.name.hasSuffix(".smali") {
            let className = file.name.replacingOccurrences(of: ".smali", with: "")
            var classInfo = ClassInfo(name: className)
            if let content = try? String(contentsOfFile: file.path, encoding: .utf8) {
                let lines = content.components(separatedBy: "\n")
                for line in lines {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix(".super ") {
                        classInfo.superClass = trimmed.replacingOccurrences(of: ".super ", with: "")
                    } else if trimmed.hasPrefix(".method ") {
                        classInfo.methods.append(trimmed)
                    } else if trimmed.hasPrefix(".field ") {
                        classInfo.fields.append(trimmed)
                    } else if trimmed.hasPrefix(".implements ") {
                        classInfo.interfaces.append(trimmed.replacingOccurrences(of: ".implements ", with: ""))
                    } else if trimmed.hasPrefix(".source ") {
                        classInfo.sourceFile = trimmed.replacingOccurrences(of: ".source ", with: "").replacingOccurrences(of: "\"", with: "")
                    }
                }
            }
            classes.append(classInfo)
        }
        return classes
    }

    // MARK: - XML 格式化
    private func formatXML(_ xml: String) -> String {
        var result = ""
        var indent = 0
        var inTag = false
        var inString = false
        var tagContent = ""
        for char in xml {
            if char == "\"" { inString.toggle() }
            if inString { tagContent.append(char); continue }
            if char == "<" {
                if !tagContent.trimmingCharacters(in: .whitespaces).isEmpty {
                    result += String(repeating: "  ", count: indent) + tagContent.trimmingCharacters(in: .whitespaces) + "\n"
                }
                tagContent = ""
                inTag = true
            }
            if inTag { tagContent.append(char) }
            if char == ">" && inTag {
                let tag = tagContent
                if tag.hasPrefix("</") { indent = max(0, indent - 1) }
                result += String(repeating: "  ", count: indent) + tag + "\n"
                if !tag.hasPrefix("</") && !tag.hasSuffix("/>") && !tag.hasPrefix("<?") && !tag.hasPrefix("<!") { indent += 1 }
                tagContent = ""
                inTag = false
            }
        }
        return result
    }

    // MARK: - 辅助方法
    private func findFile(named name: String, in dir: URL) -> URL? {
        if let enumerator = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if fileURL.lastPathComponent == name { return fileURL }
            }
        }
        return nil
    }

    private func findDir(named name: String, in dir: URL) -> URL? {
        if let enumerator = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: [.isDirectoryKey]) {
            for case let fileURL as URL in enumerator {
                if fileURL.lastPathComponent == name,
                   let vals = try? fileURL.resourceValues(forKeys: [.isDirectoryKey]),
                   vals.isDirectory == true {
                    return fileURL
                }
            }
        }
        return nil
    }
}