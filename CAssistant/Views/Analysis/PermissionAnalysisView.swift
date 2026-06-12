import SwiftUI
import UniformTypeIdentifiers

// MARK: - 权限分析视图
struct PermissionAnalysisView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var searchText = ""
    @State private var selectedFilter: PermissionFilter = .all
    
    enum PermissionFilter: String, CaseIterable {
        case all = "全部"
        case dangerous = "危险"
        case normal = "普通"
        case signature = "签名"
    }
    
    /// 危险权限列表（常见）
    private let dangerousPermissions: Set<String> = [
        "android.permission.READ_CALENDAR",
        "android.permission.WRITE_CALENDAR",
        "android.permission.CAMERA",
        "android.permission.READ_CONTACTS",
        "android.permission.WRITE_CONTACTS",
        "android.permission.GET_ACCOUNTS",
        "android.permission.ACCESS_FINE_LOCATION",
        "android.permission.ACCESS_COARSE_LOCATION",
        "android.permission.ACCESS_BACKGROUND_LOCATION",
        "android.permission.RECORD_AUDIO",
        "android.permission.READ_PHONE_STATE",
        "android.permission.CALL_PHONE",
        "android.permission.READ_CALL_LOG",
        "android.permission.WRITE_CALL_LOG",
        "android.permission.ADD_VOICEMAIL",
        "android.permission.USE_SIP",
        "android.permission.PROCESS_OUTGOING_CALLS",
        "android.permission.BODY_SENSORS",
        "android.permission.SEND_SMS",
        "android.permission.RECEIVE_SMS",
        "android.permission.READ_SMS",
        "android.permission.RECEIVE_WAP_PUSH",
        "android.permission.RECEIVE_MMS",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE",
        "android.permission.ACCESS_MEDIA_LOCATION",
        "android.permission.READ_MEDIA_IMAGES",
        "android.permission.READ_MEDIA_VIDEO",
        "android.permission.READ_MEDIA_AUDIO",
        "android.permission.POST_NOTIFICATIONS",
        "android.permission.BLUETOOTH_SCAN",
        "android.permission.BLUETOOTH_ADVERTISE",
        "android.permission.BLUETOOTH_CONNECT",
        "android.permission.NEARBY_WIFI_DEVICES",
        "android.permission.READ_MEDIA_VISUAL_USER_SELECTED",
    ]
    
    /// 签名权限列表（常见）
    private let signaturePermissions: Set<String> = [
        "android.permission.BIND_ACCESSIBILITY_SERVICE",
        "android.permission.BIND_NOTIFICATION_LISTENER_SERVICE",
        "android.permission.REQUEST_INSTALL_PACKAGES",
        "android.permission.SYSTEM_ALERT_WINDOW",
        "android.permission.WRITE_SETTINGS",
        "android.permission.MANAGE_EXTERNAL_STORAGE",
        "android.permission.INSTALL_PACKAGES",
        "android.permission.DELETE_PACKAGES",
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 统计头部
            statsHeader
                .padding()
            
            // 过滤与搜索
            VStack(spacing: 12) {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("搜索权限名称...", text: $searchText)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                )
                
                // 过滤标签
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PermissionFilter.allCases, id: \.self) { filter in
                            Button(action: { selectedFilter = filter }) {
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(
                                        selectedFilter == filter ?
                                        AnyView(RoundedRectangle(cornerRadius: 16).fill(.tint)) :
                                        AnyView(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                                    )
                                    .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // 权限列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    let permissions = filteredPermissions
                    
                    if permissions.isEmpty {
                        emptyPermissionsView
                    } else {
                        ForEach(permissions, id: \.self) { permission in
                            permissionCard(permission)
                        }
                    }
                }
                .padding()
            }
        }
        .glassBackground()
        .navigationTitle("权限分析")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 统计头部
    private var statsHeader: some View {
        GlassCard {
            HStack(spacing: 0) {
                StatItem(count: appState.currentAPKInfo?.permissions.count ?? 0,
                        label: "权限总数",
                        icon: "hand.raised",
                        color: .blue)
                
                Divider()
                    .frame(height: 40)
                
                StatItem(count: dangerousCount,
                        label: "危险权限",
                        icon: "exclamationmark.triangle",
                        color: .red)
                
                Divider()
                    .frame(height: 40)
                
                StatItem(count: normalCount,
                        label: "普通权限",
                        icon: "checkmark.shield",
                        color: .green)
            }
        }
    }
    
    // MARK: - 统计项
    private struct StatItem: View {
        let count: Int
        let label: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(color)
                    Text("\(count)")
                        .font(.title2.bold())
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - 权限卡片
    private func permissionCard(_ permission: String) -> some View {
        let isDangerous = dangerousPermissions.contains(permission)
        let isSignature = signaturePermissions.contains(permission)
        
        let level: String
        let levelColor: Color
        if isDangerous {
            level = "危险权限"
            levelColor = .red
        } else if isSignature {
            level = "签名权限"
            levelColor = .orange
        } else {
            level = "普通权限"
            levelColor = .green
        }
        
        let shortName = permission.components(separatedBy: ".").last ?? permission
        
        return GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: isDangerous ? "exclamationmark.shield.fill" : "shield")
                        .foregroundStyle(isDangerous ? .red : .green)
                        .font(.title3)
                    
                    Text(shortName)
                        .font(.body.bold())
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(level)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(levelColor.opacity(0.2))
                        )
                        .foregroundStyle(levelColor)
                }
                
                Text(permission)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
    
    // MARK: - 空权限视图
    private var emptyPermissionsView: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 40)
            Image(systemName: "hand.raised.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("未找到匹配的权限")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - 过滤计算
    private var filteredPermissions: [String] {
        guard let permissions = appState.currentAPKInfo?.permissions else { return [] }
        
        let filtered: [String]
        switch selectedFilter {
        case .all:
            filtered = permissions
        case .dangerous:
            filtered = permissions.filter { dangerousPermissions.contains($0) }
        case .normal:
            filtered = permissions.filter { !dangerousPermissions.contains($0) && !signaturePermissions.contains($0) }
        case .signature:
            filtered = permissions.filter { signaturePermissions.contains($0) }
        }
        
        if searchText.isEmpty {
            return filtered
        }
        return filtered.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var dangerousCount: Int {
        guard let permissions = appState.currentAPKInfo?.permissions else { return 0 }
        return permissions.filter { dangerousPermissions.contains($0) }.count
    }
    
    private var normalCount: Int {
        guard let permissions = appState.currentAPKInfo?.permissions else { return 0 }
        return permissions.filter { !dangerousPermissions.contains($0) && !signaturePermissions.contains($0) }.count
    }
}

// MARK: - 预览
#Preview {
    PermissionAnalysisView()
        .environmentObject(AppState())
}