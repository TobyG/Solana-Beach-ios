import SwiftUI

struct SlotsListView: View {
    let pubkey: String
    @StateObject private var viewModel = SlotsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                VStack {
                    Text("Error loading slots")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task {
                            await viewModel.fetchSlots(validatorPubkey: pubkey)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if viewModel.slots.isEmpty {
                Text("No slots found")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(viewModel.slots.indices, id: \.self) { epochIndex in
                        Section(header: Text("Epoch \(epochIndex + 1)")) {
                            ForEach(viewModel.slots[epochIndex], id: \.absoluteSlot) { slot in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Slot \(slot.relativeSlot)")
                                            .font(.headline)
                                        Spacer()
                                        Text(slot.confirmedBlock ? "Confirmed" : "Skipped")
                                            .foregroundColor(slot.confirmedBlock ? .green : .red)
                                    }
                                    
                                    Text("Absolute Slot: \(slot.absoluteSlot)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Proposed Slots")
        .task {
            await viewModel.fetchSlots(validatorPubkey: pubkey)
        }
    }
}

#Preview {
    NavigationView {
        SlotsListView(pubkey: "1234567890abcdefghijklmnopqrstuvwxyz")
    }
} 