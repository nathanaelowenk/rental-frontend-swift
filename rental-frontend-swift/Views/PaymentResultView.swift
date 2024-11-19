import SwiftUI

struct PaymentSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Payment Successful!")
                    .font(.title)
                    .bold()
                
                Text("Your book rental has been confirmed.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Done") {
                    Task {
                        // Refresh both books and rentals data
                        try? await viewModel.fetchBooks()
                        await viewModel.fetchRentedBooks()
                        // Dismiss all sheets
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
            .navigationBarHidden(true)
            .interactiveDismissDisabled() // Prevent swipe to dismiss
        }
    }
}

struct PaymentCanceledView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AppViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Payment Canceled")
                    .font(.title)
                    .bold()
                
                Text("The payment process was canceled.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    PaymentSuccessView()
        .environmentObject(AppViewModel())
} 