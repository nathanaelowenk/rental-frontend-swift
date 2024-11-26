import SwiftUI
import WebKit

struct ReadingWebView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @StateObject private var webViewModel = WebViewModel()
    
    var body: some View {
        NavigationStack {
            WebView(url: url, viewModel: webViewModel)
                .onAppear {
                    print("\n=== ReadingWebView Appeared ===")
                    print("Loading URL: \(url)")
                    print("WebViewModel state: isLoading=\(webViewModel.isLoading)")
                }
                .onChange(of: webViewModel.isLoading) { newValue in
                    print("WebViewModel loading state changed: \(newValue)")
                }
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Reading")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            print("Done button tapped")
                            dismiss()
                        }
                    }
                    
                    if webViewModel.isLoading {
                        ToolbarItem(placement: .navigationBarLeading) {
                            ProgressView()
                        }
                    }
                }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    ReadingWebView(url: URL(string: "https://drive.google.com/file/d/1ni0w8T8iGawleW-UdKr91DMsD22Pfh7U/view?usp=sharing")!)
} 
