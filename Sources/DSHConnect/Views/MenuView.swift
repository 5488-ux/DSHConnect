import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var store: ConnectionStore
    @Environment(\.dismiss) private var dismiss
    @State private var sortedByProject = true
    @State private var recentFirst = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            menuRow("bell", "优先级")
            menuRow(sortedByProject ? "checkmark.folder" : "folder", "按项目") { sortedByProject.toggle() }
            menuRow("clock.arrow.circlepath", "按时间倒序排列")
            Divider().padding(.vertical, 10)
            menuRow(recentFirst ? "checkmark.bubble" : "bubble.left", "优先显示“最近”") { recentFirst.toggle() }
            Divider().padding(.vertical, 10)
            Text("管理").font(.subheadline).foregroundStyle(.secondary).padding(.bottom, 8)
            menuRow("archivebox", "已归档任务")
            menuRow("link", "添加连接") { store.isShowingConnectionSheet = true; dismiss() }
            menuRow("gearshape", "设置") { store.isShowingConnectionSheet = true; dismiss() }
            menuRow("slider.horizontal.3", "高级模型设置") { store.isShowingAdvancedSheet = true; dismiss() }
            Divider().padding(.vertical, 10)
            Text("连接状态").font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 8) { Circle().fill(store.status == .connected ? .green : .gray).frame(width: 8, height: 8); Text(store.status.title) }.padding(.top, 10)
        }.padding(26)
    }

    private func menuRow(_ icon: String, _ title: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) { Label(title, systemImage: icon).font(.title3).foregroundStyle(.primary).padding(.vertical, 11) }.buttonStyle(.plain)
    }
}
