import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var shouldGoBack: Bool = false
    @Published var title: String = ""
    @Published var url: URL?
}

struct WebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var viewModel: WebViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        print("\n=== Creating WKWebView ===")
        print("Initial URL: \(url)")
        
        // Configure WKWebViewConfiguration
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.processPool = WKProcessPool()
        
        // Configure WKPreferences
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        // Configure WKWebpagePreferences
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        
        // Create WKWebView
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        // Load the URL
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        print("Loading initial request: \(request)")
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Don't reload if URLs are the same
        guard context.coordinator.initialUrl != url else { return }
        context.coordinator.initialUrl = url
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        var initialUrl: URL
        
        init(_ parent: WebView) {
            self.parent = parent
            self.initialUrl = parent.url
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("\n=== WebView Navigation Request ===")
            print("URL: \(navigationAction.request.url?.absoluteString ?? "nil")")
            print("Navigation Type: \(navigationAction.navigationType.rawValue)")
            
            // Always allow navigation
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("\n=== WebView Started Loading ===")
            print("URL: \(webView.url?.absoluteString ?? "nil")")
            parent.viewModel.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("\n=== WebView Finished Loading ===")
            print("URL: \(webView.url?.absoluteString ?? "nil")")
            print("Title: \(webView.title ?? "nil")")
            parent.viewModel.isLoading = false
            parent.viewModel.canGoBack = webView.canGoBack
            parent.viewModel.title = webView.title ?? ""
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("\n=== WebView Failed to Load ===")
            print("Error: \(error.localizedDescription)")
            parent.viewModel.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("\n=== WebView Failed Provisional Navigation ===")
            print("Error: \(error.localizedDescription)")
            parent.viewModel.isLoading = false
        }
        
        // Handle new windows
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            print("\n=== WebView Create New Window ===")
            print("URL: \(navigationAction.request.url?.absoluteString ?? "nil")")
            
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        // Add this method to handle authentication challenges
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension URL {
    func deletingFragment() -> URL {
        if var components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            components.fragment = nil
            return components.url ?? self
        }
        return self
    }
}
