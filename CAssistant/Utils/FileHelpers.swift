import Foundation
import UniformTypeIdentifiers

// MARK: - 文件辅助工具
enum FileHelpers {

    static func tempDirectory() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("CAssistant_\(UUID().uuidString.prefix(8))")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func fileSizeString(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    static func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: date)
    }

    static func hexString(from data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    static func md5(_ data: Data) -> String {
        var ctx = MD5Context()
        ctx.update(data: data)
        return ctx.finalize()
    }

    static func sha1(_ data: Data) -> String {
        var ctx = SHA1Context()
        ctx.update(data: data)
        return ctx.finalize()
    }

    static func sha256(_ data: Data) -> String {
        var ctx = SHA256Context()
        ctx.update(data: data)
        return ctx.finalize()
    }
}

// MARK: - 简易哈希实现
private struct MD5Context {
    private var a: UInt32 = 0x67452301
    private var b: UInt32 = 0xefcdab89
    private var c: UInt32 = 0x98badcfe
    private var d: UInt32 = 0x10325476
    private var buffer = Data()
    private var totalLength: UInt64 = 0

    private let k: [UInt32] = [
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
    ]

    private let s: [Int] = [7,12,17,22,7,12,17,22,7,12,17,22,7,12,17,22,5,9,14,20,5,9,14,20,5,9,14,20,5,9,14,20,4,11,16,23,4,11,16,23,4,11,16,23,4,11,16,23,6,10,15,21,6,10,15,21,6,10,15,21,6,10,15,21]

    mutating func update(data: Data) {
        buffer.append(data)
        totalLength += UInt64(data.count)
        while buffer.count >= 64 {
            let chunk = buffer.prefix(64)
            buffer.removeFirst(64)
            process(chunk)
        }
    }

    mutating func finalize() -> String {
        var padding = Data([0x80])
        let totalBits = totalLength * 8
        let currentLen = buffer.count % 64
        let padLen = currentLen < 56 ? 56 - currentLen : 120 - currentLen
        padding.append(Data(repeating: 0, count: padLen))
        var lenBytes = Data()
        lenBytes.append(contentsOf: withUnsafeBytes(of: totalBits.littleEndian) { Data($0) })
        update(data: padding)
        update(data: lenBytes)
        return String(format: "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                      a.littleEndian >> 0 & 0xff, a.littleEndian >> 8 & 0xff, a.littleEndian >> 16 & 0xff, a.littleEndian >> 24 & 0xff,
                      b.littleEndian >> 0 & 0xff, b.littleEndian >> 8 & 0xff, b.littleEndian >> 16 & 0xff, b.littleEndian >> 24 & 0xff,
                      c.littleEndian >> 0 & 0xff, c.littleEndian >> 8 & 0xff, c.littleEndian >> 16 & 0xff, c.littleEndian >> 24 & 0xff,
                      d.littleEndian >> 0 & 0xff, d.littleEndian >> 8 & 0xff, d.littleEndian >> 16 & 0xff, d.littleEndian >> 24 & 0xff)
    }

    private mutating func process(_ chunk: Data) {
        var m = [UInt32](repeating: 0, count: 16)
        for i in 0..<16 {
            m[i] = chunk.withUnsafeBytes { $0.load(fromByteOffset: i*4, as: UInt32.self) }
        }
        var aa = a, bb = b, cc = c, dd = d
        for i in 0..<64 {
            var f: UInt32 = 0
            var g: Int = 0
            if i < 16 { f = (bb & cc) | (~bb & dd); g = i }
            else if i < 32 { f = (dd & bb) | (~dd & cc); g = (5*i + 1) % 16 }
            else if i < 48 { f = bb ^ cc ^ dd; g = (3*i + 5) % 16 }
            else { f = cc ^ (bb | ~dd); g = (7*i) % 16 }
            let temp = dd
            dd = cc; cc = bb
            bb = bb &+ rotateLeft(aa &+ f &+ k[i] &+ m[g], s[i])
            aa = temp
        }
        a = a &+ aa; b = b &+ bb; c = c &+ cc; d = d &+ dd
    }

    private func rotateLeft(_ x: UInt32, _ n: Int) -> UInt32 { (x << n) | (x >> (32 - n)) }
}

private struct SHA1Context {
    private var h: [UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0]
    private var buffer = Data()
    private var totalLength: UInt64 = 0

    mutating func update(data: Data) {
        buffer.append(data)
        totalLength += UInt64(data.count)
        while buffer.count >= 64 {
            let chunk = buffer.prefix(64)
            buffer.removeFirst(64)
            process(chunk)
        }
    }

    mutating func finalize() -> String {
        var padding = Data([0x80])
        let totalBits = totalLength * 8
        let currentLen = buffer.count % 64
        let padLen = currentLen < 56 ? 56 - currentLen : 120 - currentLen
        padding.append(Data(repeating: 0, count: padLen))
        var lenBytes = Data()
        lenBytes.append(contentsOf: withUnsafeBytes(of: totalBits.bigEndian) { Data($0) })
        update(data: padding)
        update(data: lenBytes)
        return h.map { String(format: "%08x", $0) }.joined()
    }

    private mutating func process(_ chunk: Data) {
        var w = [UInt32](repeating: 0, count: 80)
        for i in 0..<16 {
            w[i] = chunk.withUnsafeBytes { $0.load(fromByteOffset: i*4, as: UInt32.self).bigEndian }
        }
        for i in 16..<80 {
            w[i] = rotateLeft(w[i-3] ^ w[i-8] ^ w[i-14] ^ w[i-16], 1)
        }
        var a = h[0], b = h[1], c = h[2], d = h[3], e = h[4]
        for i in 0..<80 {
            let f: UInt32, k: UInt32
            if i < 20 { f = (b & c) | (~b & d); k = 0x5a827999 }
            else if i < 40 { f = b ^ c ^ d; k = 0x6ed9eba1 }
            else if i < 60 { f = (b & c) | (b & d) | (c & d); k = 0x8f1bbcdc }
            else { f = b ^ c ^ d; k = 0xca62c1d6 }
            let t = rotateLeft(a, 5) &+ f &+ e &+ k &+ w[i]
            e = d; d = c; c = rotateLeft(b, 30); b = a; a = t
        }
        h[0] = h[0] &+ a; h[1] = h[1] &+ b; h[2] = h[2] &+ c; h[3] = h[3] &+ d; h[4] = h[4] &+ e
    }

    private func rotateLeft(_ x: UInt32, _ n: Int) -> UInt32 { (x << n) | (x >> (32 - n)) }
}

private struct SHA256Context {
    private var h: [UInt32] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    ]
    private var buffer = Data()
    private var totalLength: UInt64 = 0

    private let k: [UInt32] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ]

    mutating func update(data: Data) {
        buffer.append(data)
        totalLength += UInt64(data.count)
        while buffer.count >= 64 {
            let chunk = buffer.prefix(64)
            buffer.removeFirst(64)
            process(chunk)
        }
    }

    mutating func finalize() -> String {
        var padding = Data([0x80])
        let totalBits = totalLength * 8
        let currentLen = buffer.count % 64
        let padLen = currentLen < 56 ? 56 - currentLen : 120 - currentLen
        padding.append(Data(repeating: 0, count: padLen))
        var lenBytes = Data()
        lenBytes.append(contentsOf: withUnsafeBytes(of: totalBits.bigEndian) { Data($0) })
        update(data: padding)
        update(data: lenBytes)
        return h.map { String(format: "%08x", $0) }.joined()
    }

    private mutating func process(_ chunk: Data) {
        var w = [UInt32](repeating: 0, count: 64)
        for i in 0..<16 {
            w[i] = chunk.withUnsafeBytes { $0.load(fromByteOffset: i*4, as: UInt32.self).bigEndian }
        }
        for i in 16..<64 {
            let s0 = rotateRight(w[i-15], 7) ^ rotateRight(w[i-15], 18) ^ (w[i-15] >> 3)
            let s1 = rotateRight(w[i-2], 17) ^ rotateRight(w[i-2], 19) ^ (w[i-2] >> 10)
            w[i] = w[i-16] &+ s0 &+ w[i-7] &+ s1
        }
        var a = h[0], b = h[1], c = h[2], d = h[3], e = h[4], f = h[5], g = h[6], hh = h[7]
        for i in 0..<64 {
            let S1 = rotateRight(e, 6) ^ rotateRight(e, 11) ^ rotateRight(e, 25)
            let ch = (e & f) ^ (~e & g)
            let t1 = hh &+ S1 &+ ch &+ k[i] &+ w[i]
            let S0 = rotateRight(a, 2) ^ rotateRight(a, 13) ^ rotateRight(a, 22)
            let maj = (a & b) ^ (a & c) ^ (b & c)
            let t2 = S0 &+ maj
            hh = g; g = f; f = e; e = d &+ t1; d = c; c = b; b = a; a = t1 &+ t2
        }
        h[0] = h[0] &+ a; h[1] = h[1] &+ b; h[2] = h[2] &+ c; h[3] = h[3] &+ d
        h[4] = h[4] &+ e; h[5] = h[5] &+ f; h[6] = h[6] &+ g; h[7] = h[7] &+ hh
    }

    private func rotateRight(_ x: UInt32, _ n: Int) -> UInt32 { (x >> n) | (x << (32 - n)) }
}