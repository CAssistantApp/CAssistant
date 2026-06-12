import SwiftUI

struct PermissionAnalysisView: View {
    @EnvironmentObject var appState: AppState

    private var groupedPermissions: [(RiskLevel, [PermissionInfo])] {
        let grouped = Dictionary(grouping: appState.permissions, by: { $0.riskLevel })
        let sortedKeys: [RiskLevel] = [.critical, .dangerous, .signature, .normal, .unknown]
        return sortedKeys.compactMap { key in
            grouped[key].map { (key, $0) }
        }
    }

    private var criticalCount: Int {
        appState.permissions.filter { $0.riskLevel == .critical }.count
    }

    private var dangerousCount: Int {
        appState.permissions.filter { $0.riskLevel == .dangerous }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            if appState.permissions.isEmpty {
                emptyStateView
            } else {
                // 统计概览
                statisticsHeader

                // 权限列表
                List {
                    ForEach(groupedPermissions, id: \.0) { riskLevel, permissions in
                        Section {
                            ForEach(permissions) { permission in
                                permissionRow(permission)
                            }
                        } header: {
                            HStack {
                                GlassBadge(text: riskLevel.rawValue, color: riskLevel.color)
                                Text("\(permissions.count) 个权限")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("权限分析")
    }

    // MARK: - Statistics Header
    private var statisticsHeader: some View {
        HStack(spacing: 12) {
            statBadge(label: "总数", value: "\(appState.permissions.count)", color: .blue)
            statBadge(label: "危险", value: "\(dangerousCount)", color: .orange)
            statBadge(label: "严重", value: "\(criticalCount)", color: .red)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private func statBadge(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 0.5)
        )
    }

    // MARK: - Permission Row
    private func permissionRow(_ permission: PermissionInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: permissionIcon(for: permission.riskLevel))
                    .foregroundColor(permission.riskLevel.color)
                    .frame(width: 20)

                Text(permission.name)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Spacer()

                GlassBadge(text: permission.riskLevel.rawValue, color: permission.riskLevel.color)
            }

            if !permission.description.isEmpty {
                Text(permission.description)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 28)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Permission Icon
    private func permissionIcon(for riskLevel: RiskLevel) -> String {
        switch riskLevel {
        case .critical:
            return "exclamationmark.shield.fill"
        case .dangerous:
            return "exclamationmark.triangle.fill"
        case .signature:
            return "checkmark.shield.fill"
        case .normal:
            return "checkmark.circle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "shield.slash")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("暂无权限数据")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text("请先导入并分析 APK 文件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
struct PermissionAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionAnalysisView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}