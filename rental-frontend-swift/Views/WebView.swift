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
        
        // Initial load only
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Don't reload if URLs are the same or if it's just a hash change
        if let currentUrl = webView.url {
            let currentUrlWithoutHash = currentUrl.deletingFragment()
            let newUrlWithoutHash = url.deletingFragment()
            
            if currentUrlWithoutHash != newUrlWithoutHash && viewModel.url != url {
                viewModel.url = url
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                webView.load(request)
            }
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        private var loadedInitialUrl = false
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("Navigation type: \(navigationAction.navigationType.rawValue)")
            print("Navigating to: \(navigationAction.request.url?.absoluteString ?? "nil")")
            
            // Allow hash changes without reloading
            if let requestUrl = navigationAction.request.url,
               let currentUrl = webView.url,
               requestUrl.deletingFragment() == currentUrl.deletingFragment() {
                decisionHandler(.allow)
                return
            }
            
            // Handle initial load
            if !loadedInitialUrl {
                loadedInitialUrl = true
                decisionHandler(.allow)
                return
            }
            
            // Handle external links
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.viewModel.isLoading = true
            print("Started loading: \(webView.url?.absoluteString ?? "nil")")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.viewModel.isLoading = false
            parent.viewModel.canGoBack = webView.canGoBack
            parent.viewModel.title = webView.title ?? ""
            parent.viewModel.url = webView.url
            print("Finished loading: \(webView.url?.absoluteString ?? "nil")")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.isLoading = false
            print("WebView error: \(error.localizedDescription)")
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