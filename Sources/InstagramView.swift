import SwiftUI
import WebKit

/// Full-screen instagram.com with Resources/filter.js injected into every page.
struct InstagramView: UIViewRepresentable {
    static let home = URL(string: "https://www.instagram.com/")!

    // Instagram serves a degraded page to WKWebView's default user agent.
    static let userAgent =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 " +
        "(KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default() // keeps you logged in between launches
        config.allowsInlineMediaPlayback = true

        if let url = Bundle.main.url(forResource: "filter", withExtension: "js"),
           let source = try? String(contentsOf: url, encoding: .utf8) {
            config.userContentController.addUserScript(
                WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            )
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = Self.userAgent
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.reload), for: .valueChanged)
        webView.scrollView.refreshControl = refresh

        context.coordinator.webView = webView
        webView.load(URLRequest(url: Self.home))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        weak var webView: WKWebView?

        // Hosts that stay inside the app; any other page opens in Safari.
        private static let internalHosts = [
            "instagram.com", "facebook.com", "fbcdn.net", "cdninstagram.com", "fbsbx.com",
        ]

        @objc func reload() {
            webView?.reload()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor action: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = action.request.url, let scheme = url.scheme?.lowercased() else {
                return decisionHandler(.allow)
            }
            if ["about", "blob", "data"].contains(scheme) {
                return decisionHandler(.allow)
            }
            // instagram:// and other app links would open the real Instagram app.
            guard scheme == "http" || scheme == "https" else {
                return decisionHandler(.cancel)
            }
            let isMainFrame = action.targetFrame?.isMainFrame ?? true
            let host = url.host?.lowercased() ?? ""
            let isInternal = Self.internalHosts.contains { host == $0 || host.hasSuffix("." + $0) }
            if isMainFrame && !isInternal {
                UIApplication.shared.open(url)
                return decisionHandler(.cancel)
            }
            decisionHandler(.allow)
        }

        // Links with target="_blank" load in place instead of a new window.
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for action: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if action.targetFrame == nil {
                webView.load(action.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
        }
    }
}
