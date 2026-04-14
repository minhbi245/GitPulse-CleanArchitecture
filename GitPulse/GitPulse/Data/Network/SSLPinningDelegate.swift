//
//  SSLPinningDelegate.swift
//  GitPulse
//
//  Created by Leo Nguyen on 14/4/26.
//

import Foundation
import CryptoKit

/// SSL certificate pinning via URLSession delegate.
/// Equivalent to: Android's OkHttp `CertificatePinner`.
///
/// Android: OkHttp intercepts the TLS handshake, extracts the server's public key,
/// hashes it with SHA256, and compares to the pinned hash.
///
/// iOS: URLSession calls this delegate during TLS handshake. We extract the server's
/// public key from the certificate chain, hash with SHA256, and compare to pinned hash.
/// If no match, reject the connection.
///
/// Debug builds allow mismatched pins (development convenience).
/// Release builds reject mismatched pins.
final class SSLPinningDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {

    /// Pinned public key hashes (SHA256, base64-encoded) per domain.
    ///
    /// To generate a pin hash:
    ///   openssl s_client -connect api.github.com:443 2>/dev/null | \
    ///     openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | \
    ///     openssl dgst -sha256 -binary | openssl enc -base64
    ///
    /// Include primary + backup pins to survive certificate rotation.
    private let pinnedDomains: [String: [String]]

    /// Default pins for GitHub API. Replace placeholders with real hashes before release.
    static let defaultPins: [String: [String]] = [
        "api.github.com": [
            "PLACEHOLDER_PRIMARY_PIN_HASH",
            "PLACEHOLDER_BACKUP_PIN_HASH"
        ]
    ]

    init(pinnedDomains: [String: [String]] = SSLPinningDelegate.defaultPins) {
        self.pinnedDomains = pinnedDomains
        super.init()
    }

    /// URLSession authentication challenge — equivalent to OkHttp `CertificatePinner.check()`.
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let host = challenge.protectionSpace.host
        guard let expectedHashes = pinnedDomains[host] else {
            // Not a pinned domain — fall back to system validation.
            completionHandler(.performDefaultHandling, nil)
            return
        }

        var trustError: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &trustError) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let leafCertificate = leafCertificate(from: serverTrust),
              let publicKey = SecCertificateCopyKey(leafCertificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let hashBase64 = Data(SHA256.hash(data: publicKeyData)).base64EncodedString()

        if expectedHashes.contains(hashBase64) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }

        #if DEBUG
        print("[SSL] Pin mismatch for \(host). Got: \(hashBase64)")
        completionHandler(.performDefaultHandling, nil)
        #else
        completionHandler(.cancelAuthenticationChallenge, nil)
        #endif
    }

    /// Extract leaf certificate using modern API when available.
    /// `SecTrustGetCertificateAtIndex` is deprecated on iOS 15+.
    private func leafCertificate(from trust: SecTrust) -> SecCertificate? {
        if #available(iOS 15.0, *) {
            let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate]
            return chain?.first
        } else {
            return SecTrustGetCertificateAtIndex(trust, 0)
        }
    }
}
