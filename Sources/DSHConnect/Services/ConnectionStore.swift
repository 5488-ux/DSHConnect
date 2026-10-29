import Foundation
import SwiftUI
import Combine

@MainActor
final class ConnectionStore: ObservableObject {
    @Published var config: DSHConfig
    @Published var status: ConnectionStatus = .idle
    @Published var selectedEndpoint: DSHEndpoint?
    @Published var webURL: URL?
    @Published var discoveredEndpoints: [DSHEndpoint] = []
    @Published var remoteCapabilities = DSHRemoteCapabilities()
    @Published var selectedModelID: String?
    @Published var isShowingConnectionSheet = false
    @Published var isShowingAdvancedSheet = false
    @Published var isShowingModelSheet = false

    let discovery = DSHDiscoveryService()
    private var autoConnectTask: Task<Void, Never>?
    private var discoveryCancellable: AnyCancellable?

    init() {
        config = YAMLConfigLoader.loadBundled()
        discoveryCancellable = discovery.$endpoints.sink { [weak self] endpoints in
            Task { @MainActor [weak self] in
                guard let self else { return }
                discoveredEndpoints = endpoints
                if let endpoint = endpoints.first, status == .discovering { connect(to: endpoint) }
            }
        }
        discovery.start(serviceTypes: [config.discovery.service] + config.discovery.fallbackServices)
        autoConnectTask = Task { [weak self] in
            guard let self else { return }
            status = .discovering
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            if let endpoint = discovery.endpoints.first { connect(to: endpoint) }
            else if config.autoConnect {
                let hosts = [config.host] + config.fallbackHosts
                var connectedHost: String?
                for host in hosts where connectedHost == nil {
                    if await Self.isReachable(host: host, port: config.port, scheme: config.scheme, path: config.path, token: config.token) { connectedHost = host }
                }
                if let connectedHost { connect(to: connectedHost, port: config.port) }
                else { status = .failed("没有找到可连接的 DSH 主机") }
            }
            else { status = .disconnected }
        }
    }

    deinit { autoConnectTask?.cancel() }

    func connect(to endpoint: DSHEndpoint) {
        selectedEndpoint = endpoint
        connect(to: endpoint.host, port: endpoint.port)
    }

    func connect(to host: String, port: Int) {
        status = .connecting
        var components = URLComponents()
        components.scheme = config.scheme
        components.host = host
        components.port = port
        components.path = config.path.isEmpty ? "/" : config.path
        if !config.token.isEmpty { components.queryItems = [URLQueryItem(name: "token", value: config.token)] }
        guard let url = components.url else { status = .failed("地址无效"); return }
        webURL = url
        Task { @MainActor [weak self] in
            guard let self else { return }
            if await Self.isReachable(url: url, token: config.token) {
                status = .connected
                loadCapabilities(from: url)
            } else {
                webURL = nil
                status = .failed("无法连接 DSH，请检查地址、端口和局域网权限")
            }
        }
    }

    func disconnect() { status = .disconnected; webURL = nil }
    func reconnect() {
        if let endpoint = selectedEndpoint { connect(to: endpoint) }
        else { connect(to: config.host, port: config.port) }
    }

    func importYAML(from url: URL) {
        guard let imported = YAMLConfigLoader.load(from: url) else { status = .failed("YAML 配置无法读取"); return }
        config = imported
        discovery.start(serviceTypes: [config.discovery.service] + config.discovery.fallbackServices)
        if config.autoConnect { reconnect() }
    }

    func loadCapabilities(from url: URL) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            remoteCapabilities = await DSHCapabilitiesService.load(baseURL: url, token: config.token)
            if selectedModelID == nil { selectedModelID = remoteCapabilities.models.first?.id }
        }
    }

    func selectModel(_ modelID: String) {
        selectedModelID = modelID
        guard let url = webURL else { return }
        Task { _ = await DSHCapabilitiesService.setDefaultModel(baseURL: url, token: config.token, modelID: modelID) }
    }

    private static func isReachable(url: URL, token: String) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        if !token.isEmpty { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        guard let (_, response) = try? await URLSession.shared.data(for: request), let http = response as? HTTPURLResponse else { return false }
        return (200..<500).contains(http.statusCode)
    }

    private static func isReachable(host: String, port: Int, scheme: String, path: String, token: String) async -> Bool {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path.isEmpty ? "/" : path
        if !token.isEmpty { components.queryItems = [URLQueryItem(name: "token", value: token)] }
        guard let url = components.url else { return false }
        return await isReachable(url: url, token: token)
    }
}
