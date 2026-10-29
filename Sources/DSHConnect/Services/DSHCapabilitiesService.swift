import Foundation

struct DSHRemoteCapabilities {
    var models: [DSHModel] = []
    var projects: [DSHProject] = []
    var sessions: [DSHSession] = []
    var providers: [String] = []
    var settings: [String: String] = [:]
}

enum DSHCapabilitiesService {
    static func load(baseURL: URL, token: String) async -> DSHRemoteCapabilities {
        async let models = firstJSON(baseURL: baseURL, token: token, paths: ["api/v1/models", "models", "api/models"])
        async let projects = firstJSON(baseURL: baseURL, token: token, paths: ["api/v1/workspaces", "workspaces", "api/projects"])
        async let sessions = firstJSON(baseURL: baseURL, token: token, paths: ["api/v1/sessions", "sessions", "api/sessions"])
        async let providers = firstJSON(baseURL: baseURL, token: token, paths: ["api/v1/providers", "providers", "api/providers"])
        async let settings = firstJSON(baseURL: baseURL, token: token, paths: ["api/v1/settings", "settings", "api/settings"])
        return await DSHRemoteCapabilities(models: parseModels(await models), projects: parseProjects(await projects), sessions: parseSessions(await sessions), providers: parseStrings(await providers), settings: parseSettings(await settings))
    }

    static func setDefaultModel(baseURL: URL, token: String, modelID: String) async -> Bool {
        for path in ["api/v1/models/default", "models/default", "api/models/default"] {
            guard let url = URL(string: path, relativeTo: baseURL)?.absoluteURL else { continue }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if !token.isEmpty { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
            request.httpBody = try? JSONSerialization.data(withJSONObject: ["model": modelID])
            if let (_, response) = try? await URLSession.shared.data(for: request), let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) { return true }
        }
        return false
    }

    private static func firstJSON(baseURL: URL, token: String, paths: [String]) async -> Any? {
        for path in paths {
            guard let url = URL(string: path, relativeTo: baseURL)?.absoluteURL else { continue }
            var request = URLRequest(url: url)
            request.timeoutInterval = 8
            if !token.isEmpty { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
            guard let (data, response) = try? await URLSession.shared.data(for: request), let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode), let json = try? JSONSerialization.jsonObject(with: data) else { continue }
            return json
        }
        return nil
    }

    private static func array(_ value: Any?) -> [[String: Any]] {
        if let items = value as? [[String: Any]] { return items }
        if let root = value as? [String: Any] {
            for key in ["data", "items", "models", "workspaces", "projects", "sessions", "providers", "results"] { if let items = root[key] as? [[String: Any]] { return items } }
        }
        return []
    }

    private static func parseModels(_ value: Any?) -> [DSHModel] { array(value).compactMap { item in guard let id = (item["id"] as? String) ?? (item["model"] as? String) else { return nil }; return DSHModel(id: id, name: (item["displayName"] as? String) ?? (item["name"] as? String) ?? id, provider: item["provider"] as? String) } }
    private static func parseProjects(_ value: Any?) -> [DSHProject] { array(value).compactMap { item in guard let id = (item["id"] as? String) ?? (item["workspaceId"] as? String) else { return nil }; return DSHProject(id: id, name: (item["name"] as? String) ?? (item["title"] as? String) ?? id) } }
    private static func parseSessions(_ value: Any?) -> [DSHSession] { array(value).compactMap { item in guard let id = item["id"] as? String else { return nil }; return DSHSession(id: id, title: (item["title"] as? String) ?? (item["name"] as? String) ?? id) } }
    private static func parseStrings(_ value: Any?) -> [String] { array(value).compactMap { ($0["name"] as? String) ?? ($0["id"] as? String) } }
    private static func parseSettings(_ value: Any?) -> [String: String] { guard let root = value as? [String: Any] else { return [:] }; return root.compactMapValues { item in if let text = item as? String { return text }; if let bool = item as? Bool { return bool ? "true" : "false" }; if let number = item as? NSNumber { return number.stringValue }; return nil } }
}
