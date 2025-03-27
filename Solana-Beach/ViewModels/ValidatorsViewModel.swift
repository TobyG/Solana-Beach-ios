import Foundation

@MainActor
class ValidatorsViewModel: ObservableObject {
    @Published var allValidators: [Validator] = []
    @Published var topValidators: [Validator] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let cacheKey = "cached_validators"
    private let cacheTimestampKey = "cached_validators_timestamp"
    private let cacheExpirationInterval: TimeInterval = 300 // 5 minutes
    
    private struct CachedData: Codable {
        let allValidators: [Validator]
        let topValidators: [Validator]
    }
    
    init() {
        loadFromCache()
    }
    
    private func loadFromCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let timestamp = UserDefaults.standard.object(forKey: cacheTimestampKey) as? Date,
              Date().timeIntervalSince(timestamp) < cacheExpirationInterval,
              let cachedData = try? JSONDecoder().decode(CachedData.self, from: data) else {
            return
        }
        
        allValidators = cachedData.allValidators
        topValidators = cachedData.topValidators
    }
    
    private func saveToCache() {
        let cachedData = CachedData(allValidators: allValidators, topValidators: topValidators)
        if let encoded = try? JSONEncoder().encode(cachedData) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: cacheTimestampKey)
        }
    }
    
    func fetchValidators() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            // Fetch all validators for network statistics
            let allUrl = URL(string: "\(Environment.baseURL)/validators/all")!
            var allRequest = URLRequest(url: allUrl)
            allRequest.allHTTPHeaderFields = Environment.headers
            
            let (allData, allResponse) = try await URLSession.shared.data(for: allRequest)
            
            if let httpResponse = allResponse as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let errorMessage = "API returned status code \(httpResponse.statusCode)"
                    throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            }
            
            allValidators = try JSONDecoder().decode([Validator].self, from: allData)
            
            // Fetch top validators for the list
            let topUrl = URL(string: "\(Environment.baseURL)/validators/top")!
            var topRequest = URLRequest(url: topUrl)
            topRequest.allHTTPHeaderFields = Environment.headers
            
            let (topData, topResponse) = try await URLSession.shared.data(for: topRequest)
            
            if let httpResponse = topResponse as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let errorMessage = "API returned status code \(httpResponse.statusCode)"
                    throw NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            }
            
            topValidators = try JSONDecoder().decode([Validator].self, from: topData)
            
            // Save to cache after successful fetch
            saveToCache()
            
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