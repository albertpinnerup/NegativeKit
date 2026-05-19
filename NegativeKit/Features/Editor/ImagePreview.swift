//
//  ImagePreview.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import SwiftUI

struct ImagePreview: View {
    let image: NSImage?
    let renderedExtent: CGRect
    let selectedTool: EditorTool
    let onClick: (CGPoint) -> Void
    let onCrop: (CGPoint, CGPoint) -> Void

    @State private var cropStartPoint: CGPoint?
    @State private var cropCurrentPoint: CGPoint?

    var body: some View {
        GeometryReader { proxy in
            let imageRect = fittedImageRect(in: proxy.size)

            ZStack {
                Rectangle()
                    .fill(Color(nsColor: .underPageBackgroundColor))

                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .padding(24)

                    if let cropOverlay = cropOverlayRect(in: imageRect) {
                        Rectangle()
                            .stroke(.white, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                            .background(Color.black.opacity(0.12))
                            .frame(width: cropOverlay.width, height: cropOverlay.height)
                            .position(x: cropOverlay.midX, y: cropOverlay.midY)
                    }
                } else {
                    ContentUnavailableView(
                        "Open a negative",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Choose a TIFF, JPEG, PNG, or DNG file to begin.")
                    )
                }
            }
            .contentShape(Rectangle())
            .gesture(interactionGesture(imageRect: imageRect))
        }
    }

    private func interactionGesture(imageRect: CGRect) -> some Gesture {
        DragGesture(minimumDistance: selectedTool == .crop ? 4 : 0)
            .onChanged { value in
                guard selectedTool == .crop, imageRect.contains(value.startLocation) else {
                    return
                }

                cropStartPoint = value.startLocation
                cropCurrentPoint = value.location
            }
            .onEnded { value in
                guard imageRect.contains(value.startLocation) else {
                    cropStartPoint = nil
                    cropCurrentPoint = nil
                    return
                }

                if selectedTool == .crop {
                    if let startPoint = imagePoint(from: value.startLocation, in: imageRect),
                       let endPoint = imagePoint(from: value.location, in: imageRect) {
                        onCrop(startPoint, endPoint)
                    }
                } else if let point = imagePoint(from: value.location, in: imageRect) {
                    onClick(point)
                }

                cropStartPoint = nil
                cropCurrentPoint = nil
            }
    }

    private func fittedImageRect(in size: CGSize) -> CGRect {
        guard let image, image.size.width > 0, image.size.height > 0 else {
            return .zero
        }

        let availableSize = CGSize(
            width: max(size.width - 48, 0),
            height: max(size.height - 48, 0)
        )
        let imageAspect = image.size.width / image.size.height
        let availableAspect = availableSize.width / max(availableSize.height, 1)

        let fittedSize: CGSize
        if imageAspect > availableAspect {
            fittedSize = CGSize(width: availableSize.width, height: availableSize.width / imageAspect)
        } else {
            fittedSize = CGSize(width: availableSize.height * imageAspect, height: availableSize.height)
        }

        return CGRect(
            x: (size.width - fittedSize.width) / 2,
            y: (size.height - fittedSize.height) / 2,
            width: fittedSize.width,
            height: fittedSize.height
        )
    }

    private func imagePoint(from viewPoint: CGPoint, in imageRect: CGRect) -> CGPoint? {
        guard !renderedExtent.isEmpty, imageRect.contains(viewPoint) else {
            return nil
        }

        let normalizedX = (viewPoint.x - imageRect.minX) / imageRect.width
        let normalizedY = 1 - ((viewPoint.y - imageRect.minY) / imageRect.height)

        return CGPoint(
            x: renderedExtent.minX + normalizedX * renderedExtent.width,
            y: renderedExtent.minY + normalizedY * renderedExtent.height
        )
    }

    private func cropOverlayRect(in imageRect: CGRect) -> CGRect? {
        guard let cropStartPoint, let cropCurrentPoint else {
            return nil
        }

        let startPoint = clamped(cropStartPoint, to: imageRect)
        let currentPoint = clamped(cropCurrentPoint, to: imageRect)

        return CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(currentPoint.x - startPoint.x),
            height: abs(currentPoint.y - startPoint.y)
        )
    }

    private func clamped(_ point: CGPoint, to rect: CGRect) -> CGPoint {
        CGPoint(
            x: min(max(point.x, rect.minX), rect.maxX),
            y: min(max(point.y, rect.minY), rect.maxY)
        )
    }
}
