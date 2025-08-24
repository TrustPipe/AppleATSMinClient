//
//  FileSaveHelper.swift
//  AppAttestMin
//
//  Created by Harold on 2025/8/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileExporter: UIViewControllerRepresentable {
    let data: Data
    let suggestedName: String

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // 把 data 写到临时文件
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedName)
        try? data.write(to: tmpURL)

        // 让用户选择保存位置
        let picker = UIDocumentPickerViewController(forExporting: [tmpURL])
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}
