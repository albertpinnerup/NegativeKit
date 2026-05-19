//
//  ImageDocument.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import CoreImage
import Foundation

struct ImageDocument {
    let originalFileURL: URL
    let sourceImage: CIImage
    var adjustments: NegativeAdjustments

    var displayName: String {
        originalFileURL.lastPathComponent
    }
}
