import SwiftUI
import WebKit

struct PaymentWebView: View {
    let url: URL
    let orderId: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AppViewModel
    @StateObject private var webViewModel = WebViewModel()
    @State private var paymentStatus: PaymentStatus = .pending
    @State private var showingSuccessView = false
    @State private var showingCanceledView = false
    
    var body: some View {
        NavigationStack {
            WebView(url: url, viewModel: webViewModel)
                .onAppear {
                    print("\n=== PaymentWebView Appeared ===")
                    print("Loading URL: \(url)")
                    startPolling()
                }
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    
                    if webViewModel.isLoading {
                        ToolbarItem(placement: .navigationBarLeading) {
                            ProgressView()
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingSuccessView) {
                    PaymentSuccessView()
                        .onDisappear {
                            dismiss()
                        }
                }
                .fullScreenCover(isPresented: $showingCanceledView) {
                    PaymentCanceledView()
                        .onDisappear {
                            dismiss()
                        }
                }
                .sheet(isPresented: $showingSuccessView) {
                    PaymentSuccessView()
                        .onDisappear {
                            Task {
                                try? await viewModel.fetchBooks()
                                await viewModel.fetchRentedBooks()
                                dismiss()
                            }
                        }
                }
        }
        .interactiveDismissDisabled()
    }
    
    private func startPolling() {
        // Start polling every 3 seconds
        Task {
            while paymentStatus == .pending {
                do {
                    let status = try await APIService.shared.checkTransactionStatus(orderId: orderId)
                    if let paymentStatus = PaymentStatus(rawValue: status.status) {
                        await MainActor.run {
                            self.paymentStatus = paymentStatus
                            
                            switch paymentStatus {
                            case .settlement:
                                showingSuccessView = true
                            case .canceled:
                                showingCanceledView = true
                            case .pending:
                                break
                            }
                        }
                    }
                    
                    if paymentStatus != .pending {
                        break
                    }
                    
                    try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                } catch {
                    print("Error checking transaction status: \(error)")
                    break
                }
            }
        }
    }
}
