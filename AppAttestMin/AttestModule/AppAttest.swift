//
//  AppAttestManager.swift
//  AppAttestMin
//
//  Created by Harold on 2025/8/24.
//

import DeviceCheck
import CryptoKit

enum AppAttestError: Error {
    case attestFailed
    case assertionFailed
}

/// 专门做 attestation / assertion
final class AppAttest {
    static let shared = AppAttest()
    private init() {}

    /// 第一次 attestation
    func attest(keyID: String, clientData: Data) async throws -> Data {
        return try await withCheckedThrowingContinuation { cont in
            DCAppAttestService.shared.attestKey(keyID, clientDataHash: clientData) { data, err in
                if let err = err {
                    cont.resume(throwing: err); return
                }
                guard let data else {
                    cont.resume(throwing: AppAttestError.attestFailed); return
                }
                cont.resume(returning: data)
            }
        }
    }

    /// 后续 assertion
    func assertion(keyID: String, clientData: Data) async throws -> Data {
        return try await withCheckedThrowingContinuation { cont in
            DCAppAttestService.shared.generateAssertion(keyID, clientDataHash: clientData) { data, err in
                if let err = err {
                    cont.resume(throwing: err); return
                }
                guard let data else {
                    cont.resume(throwing: AppAttestError.assertionFailed); return
                }
                cont.resume(returning: data)
            }
        }
    }
}
