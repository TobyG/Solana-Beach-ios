import Foundation

struct Validator: Codable, Identifiable {
    let activatedStake: Int64
    let commission: Double
    let votePubkey: String
    let delegatorCount: Int
    let ll: [Double]?
    let moniker: String
    let version: String
    let lastVote: Int64
    let pictureURL: String?
    
    var id: String { votePubkey }
} 
