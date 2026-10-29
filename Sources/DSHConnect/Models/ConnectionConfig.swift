import Foundation

struct DiscoveryConfig: Codable {
    var service: String = "_dsh._tcp"
    var fallbackServices: [String] = ["_http._tcp"]
}

struct DSHConfig: Codable {
    var name: String = "DSH"
    var host: String = "localhost"
    var port: Int = 3080
    var scheme: String = "http"
    var path: String = "/"
    var token: String = ""
    var autoConnect: Bool = true
    var fallbackHosts: [String] = []
    var discovery: DiscoveryConfig = DiscoveryConfig()
}

struct DSHEndpoint: Identifiable, Equatable {
    let id: String
    let name: String
    let host: String
    let port: Int
}

struct DSHModel: Identifiable, Equatable {
    let id: String
    let name: String
    let provider: String?
}

struct DSHProject: Identifiable, Equatable {
    let id: String
    let name: String
}

struct DSHSession: Identifiable, Equatable {
    let id: String
    let title: String
}

enum ConnectionStatus: Equatable {
    case idle, discovering, connecting, connected, disconnected
    case failed(String)

    var title: String {
        switch self {
        case .idle: return "未连接"
        case .discovering: return "正在查找 DSH"
        case .connecting: return "正在连接"
        case .connected: return "已连接"
        case .disconnected: return "已断开"
        case .failed(let message): return message
        }
    }
}
