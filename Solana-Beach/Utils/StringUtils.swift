import Foundation

enum StringUtils {
    static func shortenPubkey(_ pubkey: String) -> String {
        guard pubkey.count > 8 else { return pubkey }
        let prefix = String(pubkey.prefix(4))
        let suffix = String(pubkey.suffix(4))
        return "\(prefix)...\(suffix)"
    }
} 