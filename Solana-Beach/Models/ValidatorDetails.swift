import Foundation

struct ValidatorDetailsResponse: Codable {
    let validator: ValidatorDetails
    let slots: [[Slot]]
    let historic: [HistoricData]
    let latestBlocks: [Block]
}

struct ValidatorDetails: Codable {
    let activatedStake: Int64
    let stakePercentage: String
    let commission: Double
    let epochCredits: [[Int64]]
    let epochVoteAccount: Bool
    let lastVote: Int64
    let nodePubkey: String
    let rootSlot: Int64
    let votePubkey: String
    let blockProduction: BlockProduction
    let delegatingStakeAccounts: [StakeAccount]
    let delegatorCount: Int
    let location: Location
    let moniker: String
    let website: String
    let pictureURL: String
    let version: String
    let details: String
    let asn: ASN
}

struct BlockProduction: Codable {
    let leaderSlots: Int
    let skippedSlots: Int
}

struct StakeAccount: Codable, Identifiable {
    let pubkey: String
    let lamports: Int64
    let data: StakeAccountData
    
    var id: String { pubkey }
}

struct StakeAccountData: Codable {
    let state: Int
    let meta: StakeAccountMeta
    let lockup: Lockup?
    let stake: Stake
}

struct StakeAccountMeta: Codable {
    let rent_exempt_reserve: Int64
    let authorized: Authorized
}

struct Authorized: Codable {
    let staker: String
    let withdrawer: String
}

struct Lockup: Codable {
    let unix_timestamp: Int64
    let epoch: Int64
    let custodian: String
}

struct Stake: Codable {
    let delegation: Delegation
    let credits_observed: Int64
}

struct Delegation: Codable {
    let voter_pubkey: String
    let stake: Int64
    let activation_epoch: Int64
    let warmup_cooldown_rate: Double
}

struct Location: Codable {
    let country: String
}

struct ASN: Codable {
    let code: Int
    let organization: String
}

struct Slot: Codable {
    let relativeSlot: Int64
    let absoluteSlot: Int64
    let confirmedBlock: Bool
}

struct HistoricData: Codable {
    let stake: Int64
    let delegators: Int
    let timestamp: String
}

struct Block: Codable {
    let blocknumber: Int64
    let blocktime: BlockTime
    let metrics: BlockMetrics
    let proposer: String
}

struct BlockTime: Codable {
    let absolute: Int64
    let relative: Int64
}

struct BlockMetrics: Codable {
    let txcount: Int
    let failedtxs: Int
    let totalfees: Int64
    let instructions: Int
    let sucessfultxs: Int
    let innerinstructions: Int
    let totalvaluemoved: Int64
} 
