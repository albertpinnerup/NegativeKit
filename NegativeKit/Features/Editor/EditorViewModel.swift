//
//  EditorViewModel.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import AppKit
import CoreImage
import Foundation

@MainActor
final class EditorViewModel: ObservableObject {
    @Published private(set) var document: ImageDocument?
    @Published private(set) var previewImage: NSImage?
    @Published private(set) var renderedExtent: CGRect = .zero
    @Published var showsBeforeImage = false {
        didSet { renderPreview() }
    }
    @Published var selectedTool: EditorTool = .filmBorder
    @Published var exposure: Double = 0 {
        didSet { updateAdjustmentsAndPreview() }
    }
    @Published var contrast: Double = 1 {
        didSet { updateAdjustmentsAndPreview() }
    }
    @Published var temperature: Double = 0 {
        didSet { updateAdjustmentsAndPreview() }
    }
    @Published var tint: Double = 0 {
        didSet { updateAdjustmentsAndPreview() }
    }
    @Published var vibrance: Double = 0 {
        didSet { updateAdjustmentsAndPreview() }
    }
    @Published var saturation: Double = 1 {
        didSet { updateAdjustmentsAndPreview() }
    }
    @Published var selectedExportFormat: ExportFormat = .jpeg
    @Published var errorMessage: String?

    private let imageLoader = ImageLoader()
    private let negativeConverter = NegativeConverter()
    private let previewRenderer = PreviewRenderer()
    private let imageExporter = ImageExporter()

    var hasDocument: Bool {
        document != nil
    }

    var documentTitle: String {
        document?.displayName ?? "No image selected"
    }

    var toolHint: String {
        switch selectedTool {
        case .filmBorder:
            "Click a clear film border area. Conversion starts after this sample."
        case .blackPoint:
            "Click the darkest area that should become black."
        case .whitePoint:
            "Click the brightest area that should become white."
        case .whiteBalance:
            "Click a neutral gray or white area."
        case .crop:
            "Drag over the image to crop."
        }
    }

    var filmBorderStatus: String {
        sampleStatus(document?.adjustments.filmBaseColor)
    }

    var blackPointStatus: String {
        sampleStatus(document?.adjustments.blackPointColor)
    }

    var whitePointStatus: String {
        sampleStatus(document?.adjustments.whitePointColor)
    }

    var whiteBalanceStatus: String {
        sampleStatus(document?.adjustments.whiteBalanceColor)
    }

    var cropStatus: String {
        guard let cropRect = document?.adjustments.cropRect else {
            return "Not set"
        }

        return "\(Int(cropRect.width)) x \(Int(cropRect.height))"
    }

    func openImage() {
        guard let url = FilePicker.chooseImage() else {
            return
        }

        loadImage(at: url)
    }

    func loadImage(at url: URL) {
        do {
            document = try imageLoader.loadImage(at: url)
            syncControlsFromDocument()
            renderedExtent = document?.sourceImage.extent ?? .zero
            renderPreview()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func autoSampleFilmBorder() {
        guard let document else {
            return
        }

        let extent = document.sourceImage.extent
        let sampleSize = max(min(extent.width, extent.height) * 0.06, 12)
        let inset = sampleSize * 0.5
        let sampleRects = [
            CGRect(x: extent.minX + inset, y: extent.minY + inset, width: sampleSize, height: sampleSize),
            CGRect(x: extent.maxX - sampleSize - inset, y: extent.minY + inset, width: sampleSize, height: sampleSize),
            CGRect(x: extent.minX + inset, y: extent.maxY - sampleSize - inset, width: sampleSize, height: sampleSize),
            CGRect(x: extent.maxX - sampleSize - inset, y: extent.maxY - sampleSize - inset, width: sampleSize, height: sampleSize)
        ]

        let samples = sampleRects.compactMap { rect in
            previewRenderer.averageColor(in: rect, image: document.sourceImage)
        }

        guard let sample = samples.max(by: { $0.luminance < $1.luminance }), sample.luminance > 0.03 else {
            errorMessage = "Could not find a clear film border automatically. Try selecting it manually."
            return
        }

        self.document?.adjustments.filmBaseColor = sample
        renderPreview()
    }

    func exportImage() {
        guard let document else {
            return
        }

        let baseName = document.originalFileURL.deletingPathExtension().lastPathComponent
        let suggestedName = "\(baseName)-positive.\(selectedExportFormat.fileExtension)"

        guard let url = FilePicker.chooseExportDestination(
            suggestedName: suggestedName,
            format: selectedExportFormat
        ) else {
            return
        }

        do {
            let renderedImage = negativeConverter.render(
                document.sourceImage,
                adjustments: document.adjustments
            )
            try imageExporter.export(renderedImage, to: url, format: selectedExportFormat)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetAdjustments() {
        document?.adjustments = NegativeAdjustments()
        syncControlsFromDocument()
        renderPreview()
    }

    func handlePreviewClick(at point: CGPoint) {
        guard document != nil else {
            return
        }

        switch selectedTool {
        case .filmBorder:
            guard let sample = sampleColor(at: point, in: .source), sample.luminance > 0.03 else {
                errorMessage = "That film border sample is too dark. Pick a clear, bright film-base area."
                return
            }

            document?.adjustments.filmBaseColor = sample
        case .blackPoint:
            document?.adjustments.blackPointColor = sampleColor(at: point, in: .renderedWithoutBlackPoint)
        case .whitePoint:
            document?.adjustments.whitePointColor = sampleColor(at: point, in: .renderedWithoutWhitePoint)
        case .whiteBalance:
            document?.adjustments.whiteBalanceColor = sampleColor(at: point, in: .renderedWithoutWhiteBalance)
        case .crop:
            return
        }

        renderPreview()
    }

    func setCrop(from startPoint: CGPoint, to endPoint: CGPoint) {
        guard document != nil else {
            return
        }

        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        ).intersection(renderedExtent)

        guard rect.width > 8, rect.height > 8 else {
            return
        }

        document?.adjustments.cropRect = rect
        renderPreview()
    }

    func clearCrop() {
        document?.adjustments.cropRect = nil
        renderPreview()
    }

    private func updateAdjustmentsAndPreview() {
        guard var adjustments = document?.adjustments else {
            return
        }

        adjustments.exposure = exposure
        adjustments.contrast = contrast
        adjustments.temperature = temperature
        adjustments.tint = tint
        adjustments.vibrance = vibrance
        adjustments.saturation = saturation
        document?.adjustments = adjustments
        renderPreview()
    }

    private func syncControlsFromDocument() {
        let adjustments = document?.adjustments ?? NegativeAdjustments()
        exposure = adjustments.exposure
        contrast = adjustments.contrast
        temperature = adjustments.temperature
        tint = adjustments.tint
        vibrance = adjustments.vibrance
        saturation = adjustments.saturation
    }

    private func renderPreview() {
        guard let document else {
            previewImage = nil
            renderedExtent = .zero
            return
        }

        let renderedImage = showsBeforeImage
            ? document.sourceImage
            : negativeConverter.render(
                document.sourceImage,
                adjustments: document.adjustments
            )
        renderedExtent = renderedImage.extent
        previewImage = previewRenderer.makePreviewImage(from: renderedImage)
    }

    private enum SamplingMode {
        case source
        case renderedWithoutBlackPoint
        case renderedWithoutWhitePoint
        case renderedWithoutWhiteBalance
    }

    private func sampleColor(at point: CGPoint, in mode: SamplingMode) -> ColorSample? {
        guard let document else {
            return nil
        }

        var adjustments = document.adjustments
        switch mode {
        case .source:
            return previewRenderer.sampleColor(at: point, in: document.sourceImage)
        case .renderedWithoutBlackPoint:
            adjustments.blackPointColor = nil
        case .renderedWithoutWhitePoint:
            adjustments.whitePointColor = nil
        case .renderedWithoutWhiteBalance:
            adjustments.whiteBalanceColor = nil
        }

        let image = negativeConverter.render(document.sourceImage, adjustments: adjustments)
        return previewRenderer.sampleColor(at: point, in: image)
    }

    private func sampleStatus(_ sample: ColorSample?) -> String {
        guard let sample else {
            return "Not set"
        }

        return "\(Int(sample.red * 255)), \(Int(sample.green * 255)), \(Int(sample.blue * 255))"
    }
}
