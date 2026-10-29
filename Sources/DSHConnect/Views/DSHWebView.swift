import SwiftUI
import WebKit

struct DSHWebView: UIViewRepresentable {
    let url: URL
    let token: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.backgroundColor = .systemBackground
        return view
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        if !token.isEmpty { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        webView.load(request)
    }
}
