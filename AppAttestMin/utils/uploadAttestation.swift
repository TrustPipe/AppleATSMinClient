//
//  uploadAttestation.swift
//  AppAttestMin
//
//  Created by Harold on 2025/8/24.
//

import Foundation

/// 上传 attestation/ assertion 到服务器
/// - Parameters:
///   - data: 证书二进制数据
///   - urlString: 服务器地址
/// - Returns: 服务器返回的 Data
func uploadAttestation(_ data: Data, to urlString: String) async throws -> Data {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    request.httpBody = data

    let (respData, response) = try await URLSession.shared.data(for: request)

    guard let httpResp = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    guard (200..<300).contains(httpResp.statusCode) else {
        let body = String(data: respData, encoding: .utf8) ?? ""
        throw NSError(
            domain: "UploadError",
            code: httpResp.statusCode,
            userInfo: [NSLocalizedDescriptionKey: "Server returned \(httpResp.statusCode): \(body)"]
        )
    }

    return respData
}
