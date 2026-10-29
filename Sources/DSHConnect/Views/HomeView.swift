import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ConnectionStore
    @State private var showMenu = false
    @State private var showSearch = false
    @State private var showComposer = false
    @State private var selectedChat: ChatSelection?

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    topBar
                    HStack { Text("最近").font(.title3.weight(.semibold)); Spacer(); Button { showComposer = true } label: { Image(systemName: "square.and.pencil").font(.title3) }.buttonStyle(.plain).foregroundStyle(.secondary) }
                        .padding(.horizontal, 24).padding(.top, 30)
                    LazyVStack(alignment: .leading, spacing: 26) {
                        if store.remoteCapabilities.sessions.isEmpty { Text("DSH 未返回最近会话").foregroundStyle(.secondary) }
                        else { ForEach(store.remoteCapabilities.sessions) { session in Button { selectedChat = ChatSelection(title: session.title) } label: { Text(session.title).font(.system(size: 18)).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading) }.buttonStyle(.plain).foregroundStyle(.primary) } }
                    }.padding(.horizontal, 24).padding(.top, 22).padding(.bottom, 145)
                }
            }.scrollIndicators(.hidden)
            composer
        }
        .sheet(isPresented: $showMenu) { MenuView().environmentObject(store).presentationDetents([.medium, .large]) }
        .sheet(isPresented: $showSearch) { SearchView().presentationDetents([.large]) }
        .sheet(isPresented: $showComposer) { ComposerView().environmentObject(store).presentationDetents([.large]) }
        .sheet(item: $selectedChat) { selection in ChatDetailView(title: selection.title).environmentObject(store).presentationDetents([.large]) }
    }

    private var topBar: some View {
        HStack {
            CircleIconButton(systemName: "line.3.horizontal") { showMenu = true }
            Spacer()
            Button { store.isShowingConnectionSheet = true } label: {
                VStack(spacing: 3) {
                    HStack(spacing: 5) { Text("Codex").font(.headline); Image(systemName: "chevron.down").font(.caption.weight(.bold)) }
                    HStack(spacing: 5) { Circle().fill(store.status == .connected ? .green : .gray).frame(width: 7, height: 7); Image(systemName: "laptopcomputer").font(.caption); Text(store.selectedEndpoint?.name ?? store.config.host).font(.caption).foregroundStyle(.secondary) }
                }
            }.buttonStyle(.plain).foregroundStyle(.primary)
            Spacer()
            CircleIconButton(systemName: "magnifyingglass") { showSearch = true }
        }.padding(.horizontal, 24).padding(.top, 12)
    }

    private var composer: some View {
        HStack(spacing: 12) {
            Button { showComposer = true } label: { Image(systemName: "plus").font(.title2) }.buttonStyle(.plain)
            Text("向 Codex 提问").foregroundStyle(.secondary); Spacer(); Image(systemName: "mic").font(.title3)
            Button { store.reconnect() } label: { Image(systemName: store.status == .connected ? "waveform" : "arrow.clockwise").font(.headline).foregroundStyle(.white).frame(width: 44, height: 44).background(.blue, in: Circle()) }.buttonStyle(.plain)
        }.padding(.horizontal, 18).padding(.vertical, 10).background(.ultraThinMaterial, in: Capsule()).overlay(Capsule().stroke(Color.black.opacity(0.1), lineWidth: 1)).padding(.horizontal, 24).padding(.bottom, 14)
    }
}

private struct ChatSelection: Identifiable { let title: String; var id: String { title } }
