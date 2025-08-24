//
//  ContentView.swift
//  AppAttestMin
//
//  Created by Harold on 2025/8/24.
//

import SwiftUI

struct ContentView: View {
    @State private var status = "Ready"
    @State private var exportData: Data? = nil
    @State private var showExporter = false
    @State private var isAttesting = false
    @State private var exportName = "attestation.bin"

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text(status)

                if isAttesting {
                    ProgressView("Attesting…")
                        .padding(.bottom, 4)
                }

                Button("Generate KeyID") {
                    Task {
                        isAttesting = true
                        defer { isAttesting = false }
                        do {
                            let kid = try await AppAttestKeyManager.shared.generateKeyID()
                            status = "New KeyID: \(kid.prefix(10))..."
                        } catch { status = "Key error: \(error)" }
                    }
                }
                .disabled(isAttesting)

                Button("Attestation") {
                    Task {
                        isAttesting = true
                        defer { isAttesting = false }
                        do {
                            status = "Starting attestation…"
                            let kid = try await AppAttestKeyManager.shared.keyIDOrCreate()
                            status = "Preparing challenge…"
                            // let challenge = Data(base64Encoded: "Zmlyc3QtYXR0ZXN0")!
                            let challenge = Data("first-attest".utf8)
                            status = "Requesting attestation from Secure Enclave…"
                            let att = try await AppAttest.shared.attest(keyID: kid, clientData: challenge)
                            status = "Attestation len=\(att.count)"
                            exportName = "attestation.bin"
                            exportData = att
                            showExporter = true
                            status = "Attestation saved"
                        } catch { status = "Attest error: \(error)" }
                    }
                }
                .disabled(isAttesting)

                Button("Assertion") {
                    Task {
                        isAttesting = true
                        defer { isAttesting = false }
                        do {
                            let kid = try await AppAttestKeyManager.shared.keyIDOrCreate()
                            let challenge = Data("HelloETHShenZhen".utf8)
                            let asrt = try await AppAttest.shared.assertion(keyID: kid, clientData: challenge)
                            status = "Assertion len=\(asrt.count)"
                            exportName = "assertion.bin"
                            exportData = asrt
                            showExporter = true
                            status = "Assertion saved"
                        } catch { status = "Assertion error: \(error)" }
                    }
                }
                .disabled(isAttesting)
            }
            .padding()
            .fileExporterSheet(data: $exportData, show: $showExporter, suggestedName: exportName)
        }
    }
}

extension View {
    func fileExporterSheet(data: Binding<Data?>, show: Binding<Bool>, suggestedName: String) -> some View {
        self.sheet(isPresented: show) {
            if let d = data.wrappedValue {
                AttestationFileExporter(data: d, suggestedName: suggestedName)
            } else {
                Text("No data to export")
            }
        }
    }
}

struct AttestationFileExporter: UIViewControllerRepresentable {
    let data: Data
    let suggestedName: String

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedName)
        try? data.write(to: tmpURL)
        let picker = UIDocumentPickerViewController(forExporting: [tmpURL])
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}
