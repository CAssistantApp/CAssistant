import SwiftUI

struct ComponentAnalysisView: View {
    @EnvironmentObject var appState: AppState

    private var groupedComponents: [(ComponentType, [ComponentInfo])] {
        let grouped = Dictionary(grouping: appState.components, by: { $0.componentType })
        return ComponentType.allCases.compactMap { type in
            grouped[type].map { (type, $0) }
        }
    }

    var body: some View {
        if appState.components.isEmpty {
            emptyStateView
        } else {
            List {
                ForEach(groupedComponents, id: \.0) { type, components in
                    Section {
                        DisclosureGroup {
                            ForEach(components) { component in
                                componentRow(component)
                            }
                        } label: {
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(.accentColor)
                                Text(type.rawValue)
                                    .font(.headline)
                                Spacer()
                                GlassBadge(text: "\(components.count)", color: .accentColor)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Component Row
    private func componentRow(_ component: ComponentInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: componentIcon(for: component))
                    .foregroundColor(.accentColor)
                    .frame(width: 20)

                Text(shortComponentName(component.name))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Spacer()

                GlassBadge(
                    text: component.exported ? "已导出" : "未导出",
                    color: component.exported ? .orange : .green
                )
            }

            if !component.name.isEmpty {
                Text(component.name)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                if !component.permission.isEmpty {
                    GlassBadge(text: component.permission, color: .blue)
                }

                if !component.intentFilters.isEmpty {
                    GlassBadge(text: "\(component.intentFilters.count) 个 IntentFilter", color: .purple)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.leading, 4)
    }

    // MARK: - Component Icon
    private func componentIcon(for component: ComponentInfo) -> String {
        let name = component.name.lowercased()
        if name.contains("main") { return "house.fill" }
        if name.contains("setting") { return "gearshape.fill" }
        if name.contains("about") { return "info.circle.fill" }
        if name.contains("login") { return "lock.fill" }
        if name.contains("web") { return "globe" }
        return component.componentType.icon
    }

    private func shortComponentName(_ fullName: String) -> String {
        let components = fullName.components(separatedBy: ".")
        return components.last ?? fullName
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "square.grid.3x3")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("暂无组件数据")
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
struct ComponentAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        ComponentAnalysisView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}