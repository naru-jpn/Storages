import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    private let webView: WKWebView

    init(fileUrl: URL) {
        webView = WKWebView(frame: .zero)
        webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl.deletingLastPathComponent())
    }

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
