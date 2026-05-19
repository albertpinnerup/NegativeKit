//
//  EditorTool.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import Foundation

enum EditorTool: String, CaseIterable, Identifiable {
    case filmBorder = "Film Border"
    case blackPoint = "Black Point"
    case whiteBalance = "White Balance"
    case crop = "Crop"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .filmBorder:
            "rectangle.dashed"
        case .blackPoint:
            "circle.lefthalf.filled"
        case .whiteBalance:
            "eyedropper.halffull"
        case .crop:
            "crop"
        }
    }
}
