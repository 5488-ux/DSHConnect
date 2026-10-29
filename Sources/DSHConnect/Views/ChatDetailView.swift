import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject private var store: ConnectionStore
    @Environment(\.dismiss) private var dismiss
    let title: String
    var body: some View {
        VStack(spacing: 0) {
            HStack { CircleIconButton(systemName: "chevron.left", size: 50) { dismiss() }; VStack(spacing: 2) { Text(title).font(.headline).lineLimit(1); HStack(spacing: 5) { Circle().fill(.green).frame(width: 7, height: 7); Text(store.selectedEndpoint?.name ?? "DSH").font(.caption).foregroundStyle(.secondary) } }; Spacer(); CircleIconButton(systemName: "square.and.pencil", size: 50) {}; CircleIconButton(systemName: "ellipsis", size: 50) {} }.padding(.horizontal, 18).padding(.top, 12)
            ScrollView { VStack(alignment: .leading, spacing: 22) { Text("DSH 会话").font(.subheadline).foregroundStyle(.secondary).padding(.top, 18); Text("此页面由 DSH Web UI 提供真实会话内容。连接层只负责发现主机、传递授权令牌和保持页面会话。"); HStack { Image(systemName: "network"); Text(store.webURL?.absoluteString ?? "未连接").font(.subheadline).foregroundStyle(.secondary) }; Divider(); Text("如果 DSH 页面没有加载，检查主机是否监听局域网地址，以及 dsh.yaml 中的端口和 token。").foregroundStyle(.secondary) }.padding(24) }.scrollIndicators(.hidden)
        }
    }
}
