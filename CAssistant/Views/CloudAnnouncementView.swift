import SwiftUI

struct CloudAnnouncementView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) var openURL
    @State private var selectedAnnouncement: CloudAnnouncement?
    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                GlassSectionHeader(title: "云端公告", icon: "bell.badge.fill")
                Spacer()
                if !appState.announcements.isEmpty {
                    GlassButton(title: "全部已读", icon: "envelope.open.fill") {
                        markAllRead()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if appState.announcements.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(appState.announcements) { item in
                        announcementRow(item)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .onTapGesture {
                                selectedAnnouncement = item
                                showDetail = true
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                // 底部统计
                HStack {
                    Spacer()
                    Text("共 \(appState.announcements.count) 条公告")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showDetail) {
            if let announcement = selectedAnnouncement {
                announcementDetailView(announcement)
            }
        }
    }

    // MARK: - 空状态
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("暂无公告")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("当有新公告时会显示在这里")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
    }

    // MARK: - 公告行
    private func announcementRow(_ item: CloudAnnouncement) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    // 等级图标 + 彩色圆形背景
                    Image(systemName: item.level.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(item.level.color)
                        )

                    // 标题和内容
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text(item.content)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    // 等级标签 + 未读蓝点
                    VStack(alignment: .trailing, spacing: 6) {
                        GlassBadge(text: item.level.rawValue, color: item.level.color)
                        if !item.isRead {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                }

                // 发布日期
                HStack {
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text(FileHelpers.formatDate(item.publishDate))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(14)
        }
    }

    // MARK: - 详情视图
    private func announcementDetailView(_ announcement: CloudAnnouncement) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 等级标签行
                    HStack(spacing: 8) {
                        Image(systemName: announcement.level.icon)
                            .foregroundColor(announcement.level.color)
                            .font(.system(size: 16))
                        GlassBadge(text: announcement.level.rawValue, color: announcement.level.color)
                        Spacer()
                        if !announcement.isRead {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 6, height: 6)
                                Text("未读")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // 标题
                    Text(announcement.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Divider()
                        .background(.white.opacity(0.1))

                    // 完整内容
                    Text(announcement.content)
                        .font(.body)
                        .foregroundColor(.primary)

                    // 发布日期
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("发布于 \(FileHelpers.formatDate(announcement.publishDate))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer().frame(height: 8)

                    // 操作按钮
                    VStack(spacing: 12) {
                        GlassButton(title: "标记已读", icon: "envelope.open.fill") {
                            markRead(announcement.id)
                            showDetail = false
                        }

                        if let urlStr = announcement.url,
                           let url = URL(string: urlStr) {
                            GlassButton(title: "打开链接", icon: "safari.fill") {
                                openURL(url)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            .navigationTitle("公告详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        showDetail = false
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - 操作方法
    private func markRead(_ id: String) {
        if let index = appState.announcements.firstIndex(where: { $0.id == id }) {
            appState.announcements[index].isRead = true
        }
    }

    private func markAllRead() {
        for i in appState.announcements.indices {
            appState.announcements[i].isRead = true
        }
    }
}

// MARK: - Preview
struct CloudAnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        CloudAnnouncementView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}