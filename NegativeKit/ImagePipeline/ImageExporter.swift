//
//  ImageExporter.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import CoreImage
import Foundation
import UniformTypeIdentifiers

enum ExportFormat: String, CaseIterable, Identifiable {
    case jpeg = "JPEG"
    case tiff = "TIFF"

    var id: Self { self }

    var contentType: UTType {
        switch self {
        case .jpeg:
            .jpeg
        case .tiff:
            .tiff
        }
    }

    var fileExtension: String {
        switch self {
        case .jpeg:
            "jpg"
        case .tiff:
            "tiff"
        }
    }
}

struct ImageExporter {
    private let context = CIContext(options: [
        .workingColorSpace: CGColorSpace(name: CGColorSpace.displayP3) as Any,
        .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any
    ])

    func export(_ image: CIImage, to url: URL, format: ExportFormat) throws {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let destinationURL = normalizedExportURL(url, for: format)

        switch format {
        case .jpeg:
            try context.writeJPEGRepresentation(
                of: image,
                to: destinationURL,
                colorSpace: colorSpace,
                options: [:]
            )
        case .tiff:
            try context.writeTIFFRepresentation(
                of: image,
                to: destinationURL,
                format: .RGBA8,
                colorSpace: colorSpace,
                options: [:]
            )
        }
    }

    private func normalizedExportURL(_ url: URL, for format: ExportFormat) -> URL {
        guard url.pathExtension.isEmpty else {
            return url
        }

        return url.appendingPathExtension(format.fileExtension)
    }
}
