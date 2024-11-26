import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var searchText = ""
    
    var filteredTransactions: [TransactionHistory] {
        if searchText.isEmpty {
            return viewModel.transactionHistory
        }
        return viewModel.transactionHistory.filter { transaction in
            transaction.itemName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.transactionHistory.isEmpty {
                ContentUnavailableView(
                    "No Transaction History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("You haven't made any transactions yet.")
                )
            } else {
                List(filteredTransactions) { transaction in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(transaction.itemName)
                            .font(.headline)
                        
                        HStack {
                            Text(transaction.formattedPrice)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            StatusBadge(status: transaction.transactionStatus)
                        }
                        
                        HStack {
                            Text(formatDate(transaction.formattedStartDate))
                            Text("→")
                            Text(formatDate(transaction.formattedEndDate))
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.fetchTransactionHistory()
                }
            }
        }
        .navigationTitle("History")
        .searchable(text: $searchText, prompt: "Search transactions...")
        .onAppear {
            Task {
                await viewModel.fetchTransactionHistory()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch status.lowercased() {
        case "settlement":
            return .green
        case "pending":
            return .orange
        case "canceled":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject({
                let viewModel = AppViewModel()
                viewModel.transactionHistory = [
                    TransactionHistory(
                        transactionId: 1,
                        itemId: 1,
                        itemName: "Sample Book",
                        itemPrice: "50000.00",
                        rentalStatus: "active",
                        transactionStatus: "settlement",
                        startDate: "2024-03-14T05:16:11.000Z",
                        endDate: "2024-03-21T05:16:11.000Z"
                    )
                ]
                return viewModel
            }())
    }
} 