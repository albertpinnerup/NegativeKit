//
//  FilePicker.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import AppKit
import Foundation

enum FilePicker {
    @MainActor
    static func chooseImage() -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = ImageLoader.supportedContentTypes
        panel.prompt = "Open"

        return panel.runModal() == .OK ? panel.url : nil
    }

    @MainActor
    static func chooseExportDestination(
        suggestedName: String,
        format: ExportFormat
    ) -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [format.contentType]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = suggestedName
        panel.prompt = "Export"

        return panel.runModal() == .OK ? panel.url : nil
    }
}
