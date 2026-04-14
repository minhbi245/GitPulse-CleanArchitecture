//
//  BundleExtensions.swift
//  GitPulse
//
//  xcconfig values are bridged through Info.plist and read via Bundle.
//

import Foundation

extension Bundle {

    /// API base URL read from Info.plist (set via xcconfig).
    var baseURL: String {
        infoDictionary?["BASE_URL"] as? String ?? "https://api.github.com"
    }

    /// API domain for SSL pinning — read from Info.plist.
    var baseDomain: String {
        infoDictionary?["BASE_DOMAIN"] as? String ?? "api.github.com"
    }

    /// Whether HTTP logging is enabled — read from Info.plist.
    var isLoggingEnabled: Bool {
        (infoDictionary?["ENABLE_LOGGING"] as? String) == "YES"
    }

    /// Whether Core Data encryption is enabled — read from Info.plist.
    var isDBEncryptionEnabled: Bool {
        (infoDictionary?["DB_ENCRYPTION_ENABLED"] as? String) == "YES"
    }
}
