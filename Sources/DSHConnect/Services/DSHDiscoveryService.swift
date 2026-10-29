import Foundation
import Combine

final class DSHDiscoveryService: NSObject, ObservableObject {
    @Published private(set) var endpoints: [DSHEndpoint] = []
    private var browsers: [NetServiceBrowser] = []
    private var services: [NetService] = []

    func start(serviceTypes: [String]) {
        stop()
        endpoints = []
        for rawType in serviceTypes {
            let type = rawType.hasSuffix(".") ? rawType : rawType + "."
            let browser = NetServiceBrowser()
            browser.delegate = self
            browsers.append(browser)
            browser.searchForServices(ofType: type, inDomain: "local.")
        }
    }

    func stop() {
        browsers.forEach { $0.stop() }
        browsers.removeAll()
        services.removeAll()
    }
}

extension DSHDiscoveryService: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        services.append(service)
        service.resolve(withTimeout: 3)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        endpoints.removeAll { $0.id == service.name + service.type }
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {}
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {}
}

extension DSHDiscoveryService: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let rawHost = sender.hostName else { return }
        let host = rawHost.hasSuffix(".") ? String(rawHost.dropLast()) : rawHost
        let endpoint = DSHEndpoint(id: sender.name + sender.type, name: sender.name, host: host, port: sender.port)
        if !endpoints.contains(endpoint) { endpoints.append(endpoint) }
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {}
}
