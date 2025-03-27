import Foundation

@MainActor
class ValidatorDetailsViewModel: ObservableObject {
    @Published var validatorDetails: ValidatorDetails?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let cacheExpirationInterval: TimeInterval = 300 // 5 minutes
    
    private func cacheKey(for pubkey: String) -> String {
        return "validator_details_\(pubkey)"
    }
    
    private func cacheTimestampKey(for pubkey: String) -> String {
        return "validator_details_timestamp_\(pubkey)"
    }
    
    private func loadFromCache(pubkey: String) {
        guard let data = UserDefaults.standard.data(forKey: cacheKey(for: pubkey)),
              let timestamp = UserDefaults.standard.object(forKey: cacheTimestampKey(for: pubkey)) as? Date,
              Date().timeIntervalSince(timestamp) < cacheExpirationInterval,
              let cachedData = try? JSONDecoder().decode(ValidatorDetails.self, from: data) else {
            return
        }
        
        validatorDetails = cachedData
    }
    
    private func saveToCache(pubkey: String) {
        guard let validatorDetails = validatorDetails else { return }
        
        if let encoded = try? JSONEncoder().encode(validatorDetails) {
            UserDefaults.standard.set(encoded, forKey: cacheKey(for: pubkey))
            UserDefaults.standard.set(Date(), forKey: cacheTimestampKey(for: pubkey))
        }
    }
    
    func fetchValidatorDetails(nodePubkey: String) async {
        guard !isLoading else { return }
        
        // Try to load from cache first
        loadFromCache(pubkey: nodePubkey)
        
        // If we have cached data and it's not expired, don't fetch from network
        if validatorDetails != nil {
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let url = URL(string: "\(Environment.baseURL)/validator/\(nodePubkey)")!
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = Environment.headers
            
            print("Making request to:", url.absoluteString)
            print("Headers:", request.allHTTPHeaderFields ?? [:])
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Print raw JSON for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response:")
                print(jsonString)
            }
            
            // Check HTTP response status
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
                print("Response Headers:", httpResponse.allHeaderFields)
                
                if httpResponse.statusCode != 200 {
                    let errorMessage = "API returned status code \(httpResponse.statusCode)"
                    print(errorMessage)
                    throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            }
            
            do {
                let response = try JSONDecoder().decode(ValidatorDetailsResponse.self, from: data)
                validatorDetails = response.validator
                print("Successfully decoded validator details for \(response.validator.moniker)")
                
                // Save to cache after successful fetch
                saveToCache(pubkey: nodePubkey)
            } catch {
                print("Decoding error details:")
                print(error)
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                        print("Debug description:", context.debugDescription)
                    case .typeMismatch(let type, let context):
                        print("Type '\(type)' mismatch at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                        print("Debug description:", context.debugDescription)
                    case .valueNotFound(let type, let context):
                        print("Value of type '\(type)' not found at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                        print("Debug description:", context.debugDescription)
                    case .dataCorrupted(let context):
                        print("Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                        print("Debug description:", context.debugDescription)
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                throw error
            }
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
