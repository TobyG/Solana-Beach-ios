import SwiftUI

struct ValidatorsView: View {
    @StateObject private var viewModel = ValidatorsViewModel()
    
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
    
    private func formatCommission(_ commission: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: commission)) ?? "0.00"
    }
    
    private func calculateSuperminority(validators: [Validator]) -> Int {
        let totalStake = validators.reduce(0) { $0 + $1.activatedStake }
        let targetStake = Double(totalStake) * 0.33 // 33% of total stake
        
        let sortedValidators = validators.sorted { $0.activatedStake > $1.activatedStake }
        var currentStake: Int64 = 0
        var count = 0
        
        for validator in sortedValidators {
            currentStake += validator.activatedStake
            count += 1
            if Double(currentStake) >= targetStake {
                break
            }
        }
        
        return count
    }
    
    private var statsCard: some View {
        VStack(spacing: 8) {
            Text("Network Statistics")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(viewModel.allValidators.count)")
                        .font(.title)
                        .bold()
                    Text("Total Validators")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(calculateSuperminority(validators: viewModel.allValidators))")
                        .font(.title)
                        .bold()
                    Text("Superminority")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func validatorRow(for validator: Validator) -> some View {
        NavigationLink(destination: ValidatorDetailsView(pubkey: validator.votePubkey)) {
            HStack(spacing: 12) {
                if let pictureURL = validator.pictureURL,
                   let url = URL(string: pictureURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.gray)
                            )
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(validator.moniker.isEmpty ? StringUtils.shortenPubkey(validator.votePubkey) : validator.moniker)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatStake(validator.activatedStake))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text("\(formatCommission(validator.commission))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    VStack {
                        Text("Error: \(error.localizedDescription)")
                        Button("Retry") {
                            Task {
                                await viewModel.fetchValidators()
                            }
                        }
                        .padding()
                    }
                } else if viewModel.allValidators.isEmpty || viewModel.topValidators.isEmpty {
                    Text("No validators found")
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            statsCard
                            
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.topValidators) { validator in
                                    validatorRow(for: validator)
                                    
                                    if validator.id != viewModel.topValidators.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Validators")
            .task {
                await viewModel.fetchValidators()
            }
        }
    }
}

#Preview {
    ValidatorsView()
} 
