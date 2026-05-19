//
//  NegativeAdjustments.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import Foundation
import CoreGraphics

struct ColorSample: Equatable {
    var red: Double
    var green: Double
    var blue: Double

    var isEmpty: Bool {
        red == 0 && green == 0 && blue == 0
    }

    var luminance: Double {
        0.2126 * red + 0.7152 * green + 0.0722 * blue
    }
}

struct NegativeAdjustments: Equatable {
    var exposure: Double = 0
    var contrast: Double = 1
    var temperature: Double = 0
    var tint: Double = 0
    var vibrance: Double = 0
    var saturation: Double = 1
    var filmBaseColor: ColorSample?
    var blackPointColor: ColorSample?
    var whiteBalanceColor: ColorSample?
    var cropRect: CGRect?
}
