//
//  BundleExtensions.swift
//  GitPulse
//
//  iOS equivalent of Android's BuildConfig fields.
//  In Android, buildConfigField() in build.gradle generates a BuildConfig class.
//  In iOS, xcconfig values are bridged through Info.plist and read via Bundle.
//
//  Android usage:  BuildConfig.BASE_URL
//  iOS usage:      Bundle.main.baseURL
//

import Foundation

extension Bundle {

    /// API base URL — equivalent to Android's BuildConfig.BASE_URL
    var baseURL: String {
        infoDictionary?["BASE_URL"] as? String ?? "https://api.github.com"
    }

    /// API domain for SSL pinning — equivalent to Android's BuildConfig.BASE_DOMAIN
    var baseDomain: String {
        infoDictionary?["BASE_DOMAIN"] as? String ?? "api.github.com"
    }

    /// Whether HTTP logging is enabled — equivalent to Android's HttpLoggingInterceptor level
    var isLoggingEnabled: Bool {
        (infoDictionary?["ENABLE_LOGGING"] as? String) == "YES"
    }

    /// Whether Core Data encryption is enabled — equivalent to Android's BuildConfig.DB_ENCRYPTION_ENABLED
    var isDBEncryptionEnabled: Bool {
        (infoDictionary?["DB_ENCRYPTION_ENABLED"] as? String) == "YES"
    }
}
