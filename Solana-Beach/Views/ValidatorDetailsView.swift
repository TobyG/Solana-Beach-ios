import SwiftUI

struct ValidatorDetailsView: View {
    let pubkey: String
    @StateObject private var viewModel = ValidatorDetailsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                VStack {
                    Text("Error loading validator details")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task {
                            await viewModel.fetchValidatorDetails(nodePubkey: pubkey)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if let validator = viewModel.validatorDetails {
                List {
                    // Validator Details Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            AsyncImage(url: URL(string: validator.pictureURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            } placeholder: {
                                ProgressView()
                            }
                            
                            Text(validator.moniker)
                                .font(.title2)
                                .bold()
                            
                            Link(destination: URL(string: validator.website)!) {
                                Text(validator.website)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text("Stake:")
                                Spacer()
                                Text("\(validator.activatedStake)")
                                    .bold()
                            }
                            
                            HStack {
                                Text("Commission:")
                                Spacer()
                                Text("\(validator.commission)%")
                                    .bold()
                            }
                            
                            Text(validator.details)
                                .font(.body)
                            
                           
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Navigation Links Section
                    Section {
                        NavigationLink(destination: DelegatorsListView(pubkey: pubkey)) {
                            HStack {
                                Text("Delegators")
                                Spacer()
                                Text("\(validator.delegatorCount)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        NavigationLink(destination: SlotsListView(pubkey: pubkey)) {
                            Text("Proposed Slots")
                        }
                    }
                }
            } else {
                VStack {
                    Text("No validator details available")
                        .font(.headline)
                    Text("Please try again later")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(viewModel.validatorDetails?.moniker.isEmpty == false ?
            viewModel.validatorDetails?.moniker ?? "" :
            StringUtils.shortenPubkey(pubkey))
        .task {
            await viewModel.fetchValidatorDetails(nodePubkey: pubkey)
        }
    }
}

#Preview {
    NavigationView {
        ValidatorDetailsView(pubkey: "1234567890abcdefghijklmnopqrstuvwxyz")
    }
} 
