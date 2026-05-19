//
//  NegativeConverter.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import CoreImage
import Foundation

struct NegativeConverter {
    func render(_ image: CIImage, adjustments: NegativeAdjustments) -> CIImage {
        var renderedImage = applyCrop(to: image, cropRect: adjustments.cropRect)

        if let filmBaseColor = adjustments.filmBaseColor {
            renderedImage = convertNegative(renderedImage, filmBaseColor: filmBaseColor)

            if let blackPointColor = adjustments.blackPointColor {
                renderedImage = subtract(color: blackPointColor, from: renderedImage)
            }

            if let whitePointColor = adjustments.whitePointColor {
                renderedImage = stretchWhitePoint(renderedImage, whitePointColor: whitePointColor)
            }
        }

        let whiteBalanceAdjusted = applyWhiteBalanceControls(to: renderedImage, adjustments: adjustments)
        let colorAdjusted = applyColorControls(to: whiteBalanceAdjusted, adjustments: adjustments)

        return colorAdjusted
    }

    private func applyColorControls(to image: CIImage, adjustments: NegativeAdjustments) -> CIImage {
        let exposureAdjusted = image.applyingFilter(
            "CIExposureAdjust",
            parameters: [
                kCIInputEVKey: adjustments.exposure
            ]
        )

        return exposureAdjusted.applyingFilter(
            "CIColorControls",
            parameters: [
                kCIInputContrastKey: adjustments.contrast,
                kCIInputSaturationKey: adjustments.saturation
            ]
        ).applyingFilter(
            "CIVibrance",
            parameters: [
                "inputAmount": adjustments.vibrance
            ]
        )
    }

    private func applyWhiteBalanceControls(to image: CIImage, adjustments: NegativeAdjustments) -> CIImage {
        image.applyingFilter(
            "CITemperatureAndTint",
            parameters: [
                "inputNeutral": CIVector(x: 6500, y: 0),
                "inputTargetNeutral": CIVector(
                    x: 6500 + adjustments.temperature * 3500,
                    y: adjustments.tint * 150
                )
            ]
        )
    }

    private func applyCrop(to image: CIImage, cropRect: CGRect?) -> CIImage {
        guard let cropRect else {
            return image
        }

        return image.cropped(to: cropRect.intersection(image.extent))
    }

    private func convertNegative(_ image: CIImage, filmBaseColor: ColorSample) -> CIImage {
        let inverted = image.applyingFilter("CIColorInvert")
        let invertedFilmBase = ColorSample(
            red: 1 - filmBaseColor.red,
            green: 1 - filmBaseColor.green,
            blue: 1 - filmBaseColor.blue
        )

        return subtract(color: invertedFilmBase, from: inverted).applyingFilter(
            "CIColorClamp",
            parameters: [
                "inputMinComponents": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputMaxComponents": CIVector(x: 1, y: 1, z: 1, w: 1)
            ]
        )
    }

    private func subtract(color: ColorSample, from image: CIImage) -> CIImage {
        image.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputBiasVector": CIVector(
                    x: -color.red,
                    y: -color.green,
                    z: -color.blue,
                    w: 0
                )
            ]
        )
    }

    private func stretchWhitePoint(_ image: CIImage, whitePointColor: ColorSample) -> CIImage {
        image.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: 1 / max(whitePointColor.red, 0.01), y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1 / max(whitePointColor.green, 0.01), z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1 / max(whitePointColor.blue, 0.01), w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)
            ]
        ).applyingFilter(
            "CIColorClamp",
            parameters: [
                "inputMinComponents": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputMaxComponents": CIVector(x: 1, y: 1, z: 1, w: 1)
            ]
        )
    }

}
