import SwiftUI

struct ConnectionLandingView: View {
    @EnvironmentObject private var store: ConnectionStore
    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "point.3.connected.trianglepath.dotted").font(.system(size: 58)).foregroundStyle(.blue)
            Text("DSH Connect").font(.largeTitle.weight(.semibold))
            Text(store.status.title).font(.headline).foregroundStyle(.secondary)
            if let endpoint = store.discoveredEndpoints.first {
                Button("连接 \(endpoint.name)") { store.connect(to: endpoint) }.buttonStyle(.borderedProminent)
            }
            Button("打开连接设置") { store.isShowingConnectionSheet = true }.buttonStyle(.bordered)
            if case .failed(let message) = store.status { Text(message).foregroundStyle(.red) }
        }.padding(30)
    }
}
