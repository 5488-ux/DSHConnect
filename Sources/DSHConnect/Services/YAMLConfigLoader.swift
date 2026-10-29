import Foundation
import Yams

enum YAMLConfigLoader {
    static func loadBundled() -> DSHConfig {
        guard let url = Bundle.main.url(forResource: "dsh", withExtension: "yaml"),
              let text = try? String(contentsOf: url, encoding: .utf8),
              let config = try? YAMLDecoder().decode(DSHConfig.self, from: text) else { return DSHConfig() }
        return config
    }

    static func load(from url: URL) -> DSHConfig? {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        return try? YAMLDecoder().decode(DSHConfig.self, from: text)
    }
}
