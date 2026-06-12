import SwiftUI

struct ClassStructureView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedClass: ClassInfo?

    private var filteredClasses: [ClassInfo] {
        if searchText.isEmpty {
            return appState.classes
        }
        return appState.classes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.superClass.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        if appState.classes.isEmpty {
            emptyStateView
        } else {
            GlassSplitView {
                classListView
                classDetailView
            }
        }
    }

    // MARK: - Class List View
    private var classListView: some View {
        VStack(spacing: 0) {
            GlassSearchBar(text: $searchText, placeholder: "搜索类名...")
                .padding(8)

            if filteredClasses.isEmpty {
                VStack {
                    Spacer()
                    Text("未找到匹配的类")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredClasses) { classInfo in
                            classRow(classInfo)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(minWidth: 200, maxWidth: 300)
        .background(.ultraThinMaterial)
    }

    private func classRow(_ classInfo: ClassInfo) -> some View {
        Button {
            withAnimation {
                selectedClass = classInfo
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: classIcon(for: classInfo))
                    .font(.caption)
                    .foregroundColor(selectedClass?.id == classInfo.id ? .accentColor : .secondary)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(shortClassName(classInfo.name))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(selectedClass?.id == classInfo.id ? .accentColor : .primary)
                        .lineLimit(1)
                    Text("\(classInfo.methods.count) 方法, \(classInfo.fields.count) 字段")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedClass?.id == classInfo.id ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(Color.clear))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Class Detail View
    private var classDetailView: some View {
        Group {
            if let selected = selectedClass {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 类名头
                        classNameHeader(selected)

                        // 基本信息
                        classBasicInfo(selected)

                        // 接口
                        if !selected.interfaces.isEmpty {
                            interfacesSection(selected)
                        }

                        // 方法列表
                        if !selected.methods.isEmpty {
                            methodsSection(selected)
                        }

                        // 字段列表
                        if !selected.fields.isEmpty {
                            fieldsSection(selected)
                        }
                    }
                    .padding()
                }
            } else {
                noSelectionView
            }
        }
        .frame(minWidth: 300)
        .background(.ultraThinMaterial)
    }

    // MARK: - Class Name Header
    private func classNameHeader(_ classInfo: ClassInfo) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: classIcon(for: classInfo))
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text(shortClassName(classInfo.name))
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }

            Text(classInfo.name)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    // MARK: - Basic Info
    private func classBasicInfo(_ classInfo: ClassInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            GlassSectionHeader(title: "基本信息", icon: "info.circle")

            VStack(spacing: 6) {
                GlassInfoRow(label: "超类", value: classInfo.superClass, icon: "arrow.up.doc")
                GlassInfoRow(label: "源文件", value: classInfo.sourceFile, icon: "doc.text")
                GlassInfoRow(label: "访问标志", value: classInfo.accessFlags, icon: "lock")
                GlassInfoRow(label: "方法数", value: "\(classInfo.methods.count)", icon: "function")
                GlassInfoRow(label: "字段数", value: "\(classInfo.fields.count)", icon: "square.grid.3x3")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Interfaces Section
    private func interfacesSection(_ classInfo: ClassInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            GlassSectionHeader(title: "接口 (\(classInfo.interfaces.count))", icon: "link")

            VStack(spacing: 4) {
                ForEach(classInfo.interfaces, id: \.self) { interface in
                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(interface)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Methods Section
    private func methodsSection(_ classInfo: ClassInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            GlassSectionHeader(title: "方法 (\(classInfo.methods.count))", icon: "function")

            VStack(spacing: 4) {
                ForEach(Array(classInfo.methods.enumerated()), id: \.offset) { index, method in
                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .frame(width: 24, alignment: .trailing)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Text(method)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Fields Section
    private func fieldsSection(_ classInfo: ClassInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            GlassSectionHeader(title: "字段 (\(classInfo.fields.count))", icon: "square.grid.3x3")

            VStack(spacing: 4) {
                ForEach(Array(classInfo.fields.enumerated()), id: \.offset) { index, field in
                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .frame(width: 24, alignment: .trailing)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.green)
                        Text(field)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    // MARK: - No Selection
    private var noSelectionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("选择一个类查看详情")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "cube.transparent")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("暂无类数据")
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

    // MARK: - Helpers
    private func classIcon(for classInfo: ClassInfo) -> String {
        let name = classInfo.name.lowercased()
        if name.contains("activity") { return "rectangle.portrait.and.arrow.right" }
        if name.contains("service") { return "gearshape.2" }
        if name.contains("receiver") || name.contains("broadcast") { return "antenna.radiowaves.left.and.right" }
        if name.contains("provider") { return "externaldrive" }
        if name.contains("application") { return "app.badge" }
        if name.contains("fragment") { return "square.on.square" }
        if name.contains("view") || name.contains("layout") { return "rectangle.3.group" }
        if name.contains("adapter") { return "list.bullet" }
        return "cube"
    }

    private func shortClassName(_ fullName: String) -> String {
        let components = fullName.components(separatedBy: ".")
        return components.last ?? fullName
    }
}

// MARK: - Preview
struct ClassStructureView_Previews: PreviewProvider {
    static var previews: some View {
        ClassStructureView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}