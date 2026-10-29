import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: ConnectionStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) { Image(systemName: "magnifyingglass").font(.title2).foregroundStyle(.secondary); TextField("搜索 DSH 会话", text: $query); CircleIconButton(systemName: "xmark", size: 48) { dismiss() } }.padding(.horizontal, 24).padding(.top, 12)
            HStack { Text("最近").font(.title3.weight(.semibold)); Spacer(); Image(systemName: "square.and.pencil").foregroundStyle(.secondary) }.padding(.horizontal, 30).padding(.top, 34).padding(.bottom, 24)
            ScrollView { LazyVStack(alignment: .leading, spacing: 25) { let sessions = store.remoteCapabilities.sessions.filter { query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) }; if sessions.isEmpty { Text("DSH 未返回匹配会话").foregroundStyle(.secondary) } else { ForEach(sessions) { session in Text(session.title).font(.system(size: 18)) } } }.padding(.horizontal, 30) }
        }
    }
}
