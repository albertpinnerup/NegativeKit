//
//  GradientSlider.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import SwiftUI

struct GradientSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let gradient: LinearGradient
    let format: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, value))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            GeometryReader { proxy in
                let progress = progress(for: value)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(gradient)
                        .frame(height: 8)
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.16), lineWidth: 1)
                        }

                    Circle()
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .stroke(Color.primary.opacity(0.32), lineWidth: 1)
                        .shadow(color: .black.opacity(0.18), radius: 2, y: 1)
                        .frame(width: 16, height: 16)
                        .offset(x: max(0, min(proxy.size.width - 16, progress * proxy.size.width - 8)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            updateValue(at: gesture.location.x, width: proxy.size.width)
                        }
                )
            }
            .frame(height: 18)
        }
    }

    private func progress(for value: Double) -> Double {
        let span = range.upperBound - range.lowerBound

        guard span > 0 else {
            return 0
        }

        return (value - range.lowerBound) / span
    }

    private func updateValue(at xPosition: CGFloat, width: CGFloat) {
        guard width > 0 else {
            return
        }

        let progress = min(max(Double(xPosition / width), 0), 1)
        value = range.lowerBound + progress * (range.upperBound - range.lowerBound)
    }
}
