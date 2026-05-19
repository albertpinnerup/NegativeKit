//
//  PreviewRenderer.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import AppKit
import CoreImage
import Foundation

struct PreviewRenderer {
    private let context = CIContext(options: [
        .workingColorSpace: CGColorSpace(name: CGColorSpace.displayP3) as Any,
        .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any
    ])

    func makePreviewImage(from image: CIImage, maxDimension: CGFloat = 1600) -> NSImage? {
        let scaledImage = scale(image, fittingWithin: maxDimension)
        let extent = scaledImage.extent.integral

        guard let cgImage = context.createCGImage(scaledImage, from: extent) else {
            return nil
        }

        return NSImage(
            cgImage: cgImage,
            size: NSSize(width: extent.width, height: extent.height)
        )
    }

    func sampleColor(at point: CGPoint, in image: CIImage) -> ColorSample? {
        let sampleSize: CGFloat = 9
        let sampleRect = CGRect(
            x: point.x - sampleSize / 2,
            y: point.y - sampleSize / 2,
            width: sampleSize,
            height: sampleSize
        ).intersection(image.extent)

        return averageColor(in: sampleRect, image: image)
    }

    func averageColor(in rect: CGRect, image: CIImage) -> ColorSample? {
        let sampleRect = rect.intersection(image.extent)

        guard !sampleRect.isNull, !sampleRect.isEmpty else {
            return nil
        }

        let averageImage = image
            .cropped(to: sampleRect)
            .applyingFilter(
                "CIAreaAverage",
                parameters: [
                    kCIInputExtentKey: CIVector(cgRect: sampleRect)
                ]
            )

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            averageImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)
        )

        return ColorSample(
            red: Double(bitmap[0]) / 255,
            green: Double(bitmap[1]) / 255,
            blue: Double(bitmap[2]) / 255
        )
    }

    private func scale(_ image: CIImage, fittingWithin maxDimension: CGFloat) -> CIImage {
        let extent = image.extent
        let longestSide = max(extent.width, extent.height)

        guard longestSide > maxDimension, longestSide > 0 else {
            return image
        }

        let scale = maxDimension / longestSide
        return image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }
}
