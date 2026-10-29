import SwiftUI

struct RootView: View {
    @StateObject private var store = ConnectionStore()
    var body: some View {
        Group {
            if let url = store.webURL {
                ConnectedShellView().environmentObject(store)
            } else {
                ConnectionLandingView().environmentObject(store)
            }
        }
        .sheet(isPresented: $store.isShowingConnectionSheet) { ConnectionSettingsView().environmentObject(store).presentationDetents([.large]) }
    }
}
