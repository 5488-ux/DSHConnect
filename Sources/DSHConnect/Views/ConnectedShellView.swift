import SwiftUI

struct ConnectedShellView: View {
    @EnvironmentObject private var store: ConnectionStore
    @State private var showMenu = false
    @State private var showSearch = false
    @State private var showComposer = false
    @State private var showThinking = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if let url = store.webURL { DSHWebView(url: url, token: store.config.token).ignoresSafeArea() }
            VStack(spacing: 0) {
                header
                Spacer()
                footer
            }
        }
        .sheet(isPresented: $showMenu) { MenuView().environmentObject(store).presentationDetents([.medium, .large]) }
        .sheet(isPresented: $showSearch) { SearchView().environmentObject(store).presentationDetents([.large]) }
        .sheet(isPresented: $showComposer) { ComposerView().environmentObject(store).presentationDetents([.large]) }
        .sheet(isPresented: $showThinking) { ThinkingOverlay().presentationDetents([.medium]) }
        .sheet(isPresented: $store.isShowingConnectionSheet) { ConnectionSettingsView().environmentObject(store).presentationDetents([.large]) }
        .sheet(isPresented: $store.isShowingAdvancedSheet) { AdvancedSettingsView().environmentObject(store).presentationDetents([.medium, .large]) }
    }

    private var header: some View {
        HStack {
            CircleIconButton(systemName: "line.3.horizontal") { showMenu = true }
            Spacer()
            VStack(spacing: 2) {
                Text("DSH").font(.headline)
                HStack(spacing: 5) { Circle().fill(.green).frame(width: 7, height: 7); Image(systemName: "laptopcomputer").font(.caption); Text(store.selectedEndpoint?.name ?? store.config.host).font(.caption).foregroundStyle(.secondary) }
            }
            Spacer()
            CircleIconButton(systemName: "magnifyingglass") { showSearch = true }
        }.padding(.horizontal, 22).padding(.top, 12)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button { showComposer = true } label: { Image(systemName: "plus").font(.title2) }.buttonStyle(.plain)
            Text("向 DSH 提问").foregroundStyle(.secondary)
            Spacer()
            Button { showThinking = true } label: { Image(systemName: "bolt.fill").font(.title3) }.buttonStyle(.plain)
            Image(systemName: "mic").font(.title3)
            Button { store.reconnect() } label: { Image(systemName: "waveform").font(.headline).foregroundStyle(.white).frame(width: 44, height: 44).background(.blue, in: Circle()) }.buttonStyle(.plain)
        }.padding(.horizontal, 18).padding(.vertical, 10).background(.ultraThinMaterial, in: Capsule()).overlay(Capsule().stroke(Color.black.opacity(0.1), lineWidth: 1)).padding(.horizontal, 24).padding(.bottom, 14)
    }
}
