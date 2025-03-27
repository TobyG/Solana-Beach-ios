import Foundation

@MainActor
class DelegatorsViewModel: ObservableObject {
    @Published var delegators: [StakeAccount] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchDelegators(validatorPubkey: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let url = URL(string: "\(Environment.baseURL)/validators/\(validatorPubkey)")!
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = Environment.headers
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let errorMessage = "API returned status code \(httpResponse.statusCode)"
                    throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            }
            
            let validatorResponse = try JSONDecoder().decode(ValidatorDetailsResponse.self, from: data)
            delegators = validatorResponse.validator.delegatingStakeAccounts
            
        } catch {
            print("Network or decoding error:", error)
            if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorCancelled {
                print("Request was cancelled")
                return
            }
            self.error = error
        }
        
        isLoading = false
    }
} 