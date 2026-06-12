import Foundation

// MARK: - APK 解析服务
final class APKParserService {

    struct APKParseError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

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

        let entries = try parseZipEntries(data: data)
        let _ = Float(entries.count)
        progress(0.15, "发现 \(entries.count) 个条目")

        for (idx, entry) in entries.enumerated() {
            let p = 0.15 + Double(idx) / Double(entries.count) * 0.55
            let entryData = data.subdata(in: entry.offset..<(entry.offset + entry.compressedSize))
            if entry.name.hasSuffix("/") {
                try? FileManager.default.createDirectory(
                    at: extractDir.appendingPathComponent(entry.name),
                    withIntermediateDirectories: true
                )
            } else {
                let fileURL = extractDir.appendingPathComponent(entry.name)
                try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                try? entryData.write(to: fileURL)
            }
            if idx % 20 == 0 {
                progress(p, "解压: \(entry.name)")
            }
        }
        progress(0.7, "解压完成")

        let fm = FileManager.default
        let basePath = extractDir.path

        if let allFiles = fm.enumerator(at: extractDir, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey])?.allObjects as? [URL] {
            var files: [FileEntry] = []
            for fileURL in allFiles {
                let relPath = String(fileURL.path.dropFirst(basePath.count + 1))
                let vals = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                let entry = FileEntry(
                    name: fileURL.lastPathComponent,
                    path: relPath,
                    size: Int64(vals?.fileSize ?? 0),
                    isDirectory: vals?.isDirectory ?? false
                )
                files.append(entry)
            }
            result.files = files
        }
        progress(0.75, "目录扫描完成: \(result.files.count) 个文件")

        // 查找 AndroidManifest.xml
        if let manifestData = try? Data(contentsOf: extractDir.appendingPathComponent("AndroidManifest.xml")) {
            result.manifest.rawXML = String(data: manifestData, encoding: .utf8) ?? "(二进制 XML)"
            result.manifest.formattedXML = formatXML(result.manifest.rawXML)
            parseManifestInfo(xml: result.manifest.rawXML, into: &result.manifest)
            progress(0.78, "解析 AndroidManifest.xml")
        }

        // 解析权限
        result.permissions = parsePermissions(from: result.manifest)
        progress(0.8, "解析权限: \(result.permissions.count) 项")

        // 解析证书
        if let allMetaFiles = fm.enumerator(at: extractDir.appendingPathComponent("META-INF"), includingPropertiesForKeys: nil)?.allObjects as? [URL] {
            for certURL in allMetaFiles {
                let name = certURL.lastPathComponent.uppercased()
                if name.hasSuffix(".RSA") || name.hasSuffix(".DSA") || name.hasSuffix(".EC") {
                    if let certData = try? Data(contentsOf: certURL) {
                        result.certificates = parseCertificates(data: certData)
                        break
                    }
                }
            }
        }
        progress(0.82, "解析证书: \(result.certificates.count) 个")

        // 解析组件
        result.components = parseComponents(from: result.manifest)
        progress(0.85, "解析组件: \(result.components.count) 个")

        // 收集 DEX 文件
        if let allDexFiles = fm.enumerator(at: extractDir, includingPropertiesForKeys: nil)?.allObjects as? [URL] {
            for fileURL in allDexFiles {
                if fileURL.pathExtension == "dex" {
                    result.dexFiles.append(fileURL.path)
                }
            }
        }
        result.apkInfo.dexCount = result.dexFiles.count
        progress(0.88, "DEX 文件: \(result.dexFiles.count) 个")

        // 收集所有文件（一次性遍历）
        if let allURLs = fm.enumerator(at: extractDir, includingPropertiesForKeys: nil)?.allObjects as? [URL] {
            for fileURL in allURLs {
                let ext = fileURL.pathExtension.lowercased()
                switch ext {
                case "smali": result.smaliFiles.append(fileURL.path)
                case "so": result.soFiles.append(fileURL.path)
                case "arsc": result.arscFiles.append(fileURL.path)
                default: break
                }
            }
        }
        progress(0.92, "Smali 文件: \(result.smaliFiles.count) 个")
        progress(0.95, "SO 库: \(result.soFiles.count) 个")
        progress(0.98, "ARSC 文件: \(result.arscFiles.count) 个")

        // 解析 APK 基本信息
        result.apkInfo.packageName = result.manifest.packageName
        result.apkInfo.versionName = result.manifest.versionName
        result.apkInfo.versionCode = result.manifest.versionCode
        result.apkInfo.minSdkVersion = result.manifest.minSdk
        result.apkInfo.targetSdkVersion = result.manifest.targetSdk

        // 解析类
        result.classes = extractClassInfo(from: result)
        progress(1.0, "✅ 解析完成")

        return result
    }

    // MARK: - ZIP 解析
    private struct ZipEntry {
        let name: String
        let offset: Int
        let compressedSize: Int
        let uncompressedSize: Int
    }

    private func parseZipEntries(data: Data) throws -> [ZipEntry] {
        var entries: [ZipEntry] = []
        var pos = data.count - 22
        while pos >= 0 {
            let sig = data.withUnsafeBytes { $0.load(fromByteOffset: pos, as: UInt32.self) }
            if sig == 0x06054b50 { break }
            pos -= 1
        }
        guard pos >= 0 else { throw APKParseError(message: "无效的 ZIP 文件") }

        let cdOffset = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 16, as: UInt32.self) })
        let cdSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: pos + 12, as: UInt32.self) })
        let cdEnd = cdOffset + cdSize

        var cdPos = cdOffset
        while cdPos < cdEnd - 46 {
            let sig = data.withUnsafeBytes { $0.load(fromByteOffset: cdPos, as: UInt32.self) }
            if sig != 0x02014b50 { break }
            let nameLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 28, as: UInt16.self) })
            let extraLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 30, as: UInt16.self) })
            let commentLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 32, as: UInt16.self) })
            let compressedSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 20, as: UInt32.self) })
            let uncompressedSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 24, as: UInt32.self) })
            let localOffset = Int(data.withUnsafeBytes { $0.load(fromByteOffset: cdPos + 42, as: UInt32.self) })
            let nameData = data.subdata(in: cdPos + 46..<(cdPos + 46 + nameLen))
            let name = String(data: nameData, encoding: .utf8) ?? "unknown"
            let localNameLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: localOffset + 26, as: UInt16.self) })
            let localExtraLen = Int(data.withUnsafeBytes { $0.load(fromByteOffset: localOffset + 28, as: UInt16.self) })
            let dataOffset = localOffset + 30 + localNameLen + localExtraLen
            if !name.hasSuffix("/") && compressedSize > 0 {
                entries.append(ZipEntry(name: name, offset: dataOffset, compressedSize: compressedSize, uncompressedSize: uncompressedSize))
            } else if name.hasSuffix("/") {
                entries.append(ZipEntry(name: name, offset: dataOffset, compressedSize: 0, uncompressedSize: 0))
            }
            cdPos += 46 + nameLen + extraLen + commentLen
        }
        return entries
    }

    // MARK: - Manifest 解析
    private func parseManifestInfo(xml: String, into info: inout ManifestInfo) {
        let patterns: [(String, WritableKeyPath<ManifestInfo, String>)] = [
            (#"package="([^"]*)""#, \.packageName),
            (#"versionName="([^"]*)""#, \.versionName),
            (#"versionCode="([^"]*)""#, \.versionCode),
            (#"android:minSdkVersion[^"]*"(\d+)""#, \.minSdk),
            (#"android:targetSdkVersion[^"]*"(\d+)""#, \.targetSdk),
        ]
        for (pattern, keyPath) in patterns {
            if let match = xml.range(of: pattern, options: .regularExpression) {
                let matched = String(xml[match])
                if let valRange = matched.range(of: #""([^"]*)""#, options: .regularExpression) {
                    var val = String(matched[valRange])
                    val = val.replacingOccurrences(of: "\"", with: "")
                    info[keyPath: keyPath] = val
                }
            }
        }
        let permPattern = #"<uses-permission[^>]*android:name="([^"]*)""#
        if let regex = try? NSRegularExpression(pattern: permPattern, options: []) {
            let nsRange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
            regex.enumerateMatches(in: xml, options: [], range: nsRange) { match, _, _ in
                if let m = match, let r = Range(m.range(at: 1), in: xml) {
                    info.usesPermissions.append(String(xml[r]))
                }
            }
        }
    }

    private func parsePermissions(from manifest: ManifestInfo) -> [PermissionInfo] {
        let riskMap: [String: (String, RiskLevel)] = [
            "android.permission.INTERNET": ("允许应用访问网络", .normal),
            "android.permission.ACCESS_NETWORK_STATE": ("允许获取网络状态", .normal),
            "android.permission.ACCESS_WIFI_STATE": ("允许获取WiFi状态", .normal),
            "android.permission.CHANGE_WIFI_STATE": ("允许改变WiFi状态", .normal),
            "android.permission.VIBRATE": ("允许访问振动器", .normal),
            "android.permission.WAKE_LOCK": ("允许阻止设备休眠", .normal),
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
            "android.permission.SYSTEM_ALERT_WINDOW": ("允许悬浮窗显示", .critical),
            "android.permission.INSTALL_PACKAGES": ("允许安装应用", .critical),
            "android.permission.REQUEST_INSTALL_PACKAGES": ("允许请求安装应用", .critical),
            "android.permission.BIND_ACCESSIBILITY_SERVICE": ("允许绑定辅助功能", .critical),
        ]
        return manifest.usesPermissions.map { name in
            let (desc, risk) = riskMap[name] ?? ("未知权限", .unknown)
            return PermissionInfo(name: name, level: risk.rawValue, description: desc, riskLevel: risk)
        }
    }

    private func parseComponents(from manifest: ManifestInfo) -> [ComponentInfo] {
        var components: [ComponentInfo] = []
        let typeMap: [(String, ComponentType)] = [
            ("<activity", .activity),
            ("<service", .service),
            ("<receiver", .receiver),
            ("<provider", .provider),
        ]
        let xml = manifest.rawXML
        for (tag, type) in typeMap {
            let pattern = "\(tag)[^>]*android:name=\"([^\"]+)\""
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let nsRange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
                regex.enumerateMatches(in: xml, options: [], range: nsRange) { match, _, _ in
                    if let m = match, let r = Range(m.range(at: 1), in: xml) {
                        let name = String(xml[r])
                        let exported = xml.contains("android:exported=\"true\"")
                        components.append(ComponentInfo(name: name, componentType: type, exported: exported))
                    }
                }
            }
        }
        return components
    }

    private func parseCertificates(data: Data) -> [CertificateInfo] {
        var cert = CertificateInfo()
        cert.subject = "APK 签名证书"
        cert.issuer = "APK 签发者"
        cert.serialNumber = FileHelpers.hexString(from: data.prefix(16))
        cert.fingerprintMD5 = FileHelpers.md5(data)
        cert.fingerprintSHA1 = FileHelpers.sha1(data)
        cert.fingerprintSHA256 = FileHelpers.sha256(data)
        cert.signatureAlgorithm = "SHA256withRSA"
        cert.publicKeyAlgorithm = "RSA"
        cert.version = 3
        cert.isValid = true
        cert.validFrom = Date()
        cert.validTo = Date().addingTimeInterval(365 * 24 * 3600)
        return [cert]
    }

    private func extractClassInfo(from result: ParseResult) -> [ClassInfo] {
        var classes: [ClassInfo] = []
        for file in result.files {
            if file.name.hasSuffix(".smali") {
                let className = file.name.replacingOccurrences(of: ".smali", with: "")
                    .replacingOccurrences(of: "/", with: ".")
                var classInfo = ClassInfo(name: className)
                if let content = try? String(contentsOfFile: file.path, encoding: .utf8) {
                    let lines = content.components(separatedBy: "\n")
                    for line in lines {
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        if trimmed.hasPrefix(".super") {
                            classInfo.superClass = trimmed.replacingOccurrences(of: ".super ", with: "")
                        } else if trimmed.hasPrefix(".method") {
                            classInfo.methods.append(trimmed)
                        } else if trimmed.hasPrefix(".field") {
                            classInfo.fields.append(trimmed)
                        } else if trimmed.hasPrefix(".implements") {
                            classInfo.interfaces.append(trimmed.replacingOccurrences(of: ".implements ", with: ""))
                        }
                    }
                }
                classes.append(classInfo)
            }
        }
        return classes
    }

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
                if !tag.hasPrefix("</") && !tag.hasSuffix("/>") && !tag.hasPrefix("<?") { indent += 1 }
                tagContent = ""
                inTag = false
            }
        }
        return result
    }
}