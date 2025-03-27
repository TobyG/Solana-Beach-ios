import SwiftUI

struct DelegatorsListView: View {
    let pubkey: String
    @StateObject private var viewModel = DelegatorsViewModel()
    
    private func formatStake(_ stake: Int64) -> String {
        // Convert from lamports (9 decimals) to SOL
        let solAmount = Double(stake) / 1_000_000_000
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if let formatted = formatter.string(from: NSNumber(value: solAmount)) {
            return formatted
        }
        return "0"
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                VStack {
                    Text("Error loading delegators")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task {
                            await viewModel.fetchDelegators(validatorPubkey: pubkey)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if viewModel.delegators.isEmpty {
                Text("No delegators found")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                List(viewModel.delegators) { delegator in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(StringUtils.shortenPubkey(delegator.pubkey))
                            .font(.headline)
                        
                        HStack {
                            Text("Stake:")
                            Spacer()
                            Text("\(formatStake(delegator.lamports)) SOL")
                                .bold()
                        }
                        
                       
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Delegators")
        .task {
            await viewModel.fetchDelegators(validatorPubkey: pubkey)
        }
    }
}

#Preview {
    NavigationView {
        DelegatorsListView(pubkey: "1234567890abcdefghijklmnopqrstuvwxyz")
    }
} 
