import SwiftUI

// MARK: - 灵动玻璃按钮
struct GlassButton: View {
    let title: String
    let icon: String
    var color: Color = .accentColor
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 0.5)
            )
            .foregroundColor(color)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 玻璃信息行
struct GlassInfoRow: View {
    let label: String
    let value: String
    var icon: String = "info.circle"

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
        )
    }
}

// MARK: - 玻璃分区标题
struct GlassSectionHeader: View {
    let title: String
    var icon: String = "folder"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 玻璃卡片容器
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
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

// MARK: - 玻璃导航行
struct GlassNavRow: View {
    let title: String
    let icon: String
    var subtitle: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 28)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    if let sub = subtitle {
                        Text(sub)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 玻璃标签
struct GlassBadge: View {
    let text: String
    var color: Color = .accentColor

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(color.opacity(0.3), lineWidth: 0.5)
            )
            .foregroundColor(color)
    }
}

// MARK: - 玻璃进度条
struct GlassProgressBar: View {
    let progress: Double
    var color: Color = .accentColor

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.thinMaterial)
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(geo.size.width * progress, geo.size.width)), height: 8)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - 玻璃分割视图
struct GlassSplitView<Left: View, Right: View>: View {
    let left: Left
    let right: Right

    init(@ViewBuilder content: () -> TupleView<(Left, Right)>) {
        let t = content()
        left = t.value.0
        right = t.value.1
    }

    init(left: Left, right: Right) {
        self.left = left
        self.right = right
    }

    var body: some View {
        HStack(spacing: 0) {
            left
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(width: 0.5)
            right
        }
    }
}

// MARK: - 玻璃文件树行
struct GlassFileTreeRow: View {
    let name: String
    let icon: String
    var isSelected: Bool = false
    var level: Int = 0
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if level > 0 {
                    Spacer().frame(width: CGFloat(level) * 16)
                }
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(width: 16)
                Text(name)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .accentColor : .primary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(Color.clear))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 玻璃搜索栏
struct GlassSearchBar: View {
    @Binding var text: String
    var placeholder: String = "搜索..."

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.tertiary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
        )
    }
}

// MARK: - 玻璃代码编辑器
struct GlassCodeEditor: View {
    @Binding var text: String
    var language: String = "smali"
    @State private var lineCount: Int = 1

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(1...lineCount, id: \.self) { i in
                        Text("\(i)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .frame(minWidth: 32, alignment: .trailing)
                            .padding(.trailing, 8)
                            .padding(.vertical, 1)
                    }
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)

                TextEditor(text: $text)
                    .font(.system(size: 13, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: CGFloat(lineCount) * 20 + 24)
                    .onChange(of: text) { _, newValue in
                        lineCount = text.components(separatedBy: "\n").count
                    }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.08), lineWidth: 0.5)
        )
        .onAppear {
            lineCount = text.components(separatedBy: "\n").count
        }
    }
}