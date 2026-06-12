import SwiftUI

// MARK: - 灵动玻璃效果修饰器
struct GlassBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
    }
}

struct GlassButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct GlassNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
    }
}

// MARK: - View 扩展
extension View {
    func glassBackground() -> some View {
        modifier(GlassBackgroundModifier())
    }
    
    func glassButtonStyle() -> some View {
        modifier(GlassButtonModifier())
    }
    
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
    
    func glassNavBar() -> some View {
        modifier(GlassNavBarModifier())
    }
}

// MARK: - 自定义玻璃卡片
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .glassCard()
    }
}

// MARK: - 玻璃按钮
struct GlassButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    init(title: String, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
}

// MARK: - 玻璃标题
struct GlassSectionHeader: View {
    let title: String
    let systemImage: String
    
    init(title: String, systemImage: String = "chevron.right") {
        self.title = title
        self.systemImage = systemImage
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.headline)
            Text(title)
                .font(.headline)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 玻璃列表行（@ViewBuilder 版本）
struct GlassListRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
            )
    }
}

// MARK: - 信息行（兼容 label:value:icon 格式）
struct GlassInfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        GlassListRow {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.body)
                        .fontWeight(.medium)
                }
                Spacer()
            }
        }
    }
}