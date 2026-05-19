//
//  ImageLoader.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import CoreImage
import Foundation
import UniformTypeIdentifiers

enum ImageLoaderError: LocalizedError {
    case unsupportedImage(URL)

    var errorDescription: String? {
        switch self {
        case .unsupportedImage(let url):
            "NegativeKit could not open \(url.lastPathComponent)."
        }
    }
}

struct ImageLoader {
    static let supportedContentTypes: [UTType] = [
        .tiff,
        .jpeg,
        .png,
        .rawImage
    ]

    func loadImage(at url: URL) throws -> ImageDocument {
        let options: [CIImageOption: Any] = [
            .applyOrientationProperty: true
        ]

        guard let image = CIImage(contentsOf: url, options: options) else {
            throw ImageLoaderError.unsupportedImage(url)
        }

        return ImageDocument(
            originalFileURL: url,
            sourceImage: image,
            adjustments: NegativeAdjustments()
        )
    }
}
