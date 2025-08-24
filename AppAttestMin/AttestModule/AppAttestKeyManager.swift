//
//  AppAttestKeyManager.swift
//  AppAttestMin
//
//  Created by Harold on 2025/8/24.
//

import DeviceCheck

enum KeyManagerError: Error {
    case unsupported
    case keyGenFailed
    case noKey
}

/// 专门管理 KeyID（生成、存取）
final class AppAttestKeyManager {
    static let shared = AppAttestKeyManager()
    private init() {}

    private let keyIDKey = "AppAttestKeyID"

    /// 从本地取已保存的 keyID
    func currentKeyID() -> String? {
        UserDefaults.standard.string(forKey: keyIDKey)
    }

    /// 强制生成一个新的 keyID（并覆盖存储）
    func generateKeyID() async throws -> String {
        guard DCAppAttestService.shared.isSupported else {
            throw KeyManagerError.unsupported
        }
        return try await withCheckedThrowingContinuation { cont in
            DCAppAttestService.shared.generateKey { keyID, err in
                if let err = err {
                    cont.resume(throwing: err)
                    return
                }
                guard let kid = keyID else {
                    cont.resume(throwing: KeyManagerError.keyGenFailed)
                    return
                }
                UserDefaults.standard.setValue(kid, forKey: self.keyIDKey)
                cont.resume(returning: kid)
            }
        }
    }

    /// 获取一个可用的 keyID，如果没有就生成
    func keyIDOrCreate() async throws -> String {
        if let kid = currentKeyID() {
            return kid
        }
        return try await generateKeyID()
    }

    /// 清除已保存的 keyID
    func reset() {
        UserDefaults.standard.removeObject(forKey: keyIDKey)
    }
}
