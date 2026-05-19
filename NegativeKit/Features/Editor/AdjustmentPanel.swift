//
//  AdjustmentPanel.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import SwiftUI

struct AdjustmentPanel: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.documentTitle)
                .font(.headline)
                .lineLimit(2)

            Picker("Tool", selection: $viewModel.selectedTool) {
                ForEach(EditorTool.allCases) { tool in
                    Label(tool.rawValue, systemImage: tool.systemImage).tag(tool)
                }
            }
            .pickerStyle(.menu)
            .disabled(!viewModel.hasDocument)

            Text(viewModel.toolHint)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                sampleRow(title: "Film border", value: viewModel.filmBorderStatus)
                sampleRow(title: "Black point", value: viewModel.blackPointStatus)
                sampleRow(title: "White point", value: viewModel.whitePointStatus)
                sampleRow(title: "White balance", value: viewModel.whiteBalanceStatus)
                sampleRow(title: "Crop", value: viewModel.cropStatus)

                HStack {
                    Button("Auto Border") {
                        viewModel.autoSampleFilmBorder()
                    }
                    .disabled(!viewModel.hasDocument)

                    Button("Clear Crop") {
                        viewModel.clearCrop()
                    }
                    .disabled(!viewModel.hasDocument)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                adjustmentSlider(
                    title: "Exposure",
                    value: $viewModel.exposure,
                    range: -3...3,
                    format: "%.2f"
                )

                adjustmentSlider(
                    title: "Contrast",
                    value: $viewModel.contrast,
                    range: 0.25...2.5,
                    format: "%.2f"
                )
            }
            .disabled(!viewModel.hasDocument)

            VStack(alignment: .leading, spacing: 12) {
                Text("White Balance")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                GradientSlider(
                    title: "Temperature",
                    value: $viewModel.temperature,
                    range: -1...1,
                    gradient: LinearGradient(
                        colors: [.blue, .white, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    format: "%.2f"
                )

                GradientSlider(
                    title: "Tint",
                    value: $viewModel.tint,
                    range: -1...1,
                    gradient: LinearGradient(
                        colors: [.green, .white, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    format: "%.2f"
                )

                GradientSlider(
                    title: "Vibrance",
                    value: $viewModel.vibrance,
                    range: -1...1,
                    gradient: LinearGradient(
                        colors: [.gray, .cyan, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    format: "%.2f"
                )

                GradientSlider(
                    title: "Saturation",
                    value: $viewModel.saturation,
                    range: 0...2,
                    gradient: LinearGradient(
                        colors: [.gray, .red, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    format: "%.2f"
                )
            }
            .disabled(!viewModel.hasDocument)

            Toggle("Before", isOn: $viewModel.showsBeforeImage)
                .toggleStyle(.switch)
                .disabled(!viewModel.hasDocument)

            Picker("Export", selection: $viewModel.selectedExportFormat) {
                ForEach(ExportFormat.allCases) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!viewModel.hasDocument)

            HStack {
                Button("Reset") {
                    viewModel.resetAdjustments()
                }
                .disabled(!viewModel.hasDocument)

                Spacer()

                Button("Export") {
                    viewModel.exportImage()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.hasDocument)
            }

            Spacer()
        }
        .padding(20)
        .frame(minWidth: 260, idealWidth: 300, maxWidth: 340)
    }

    private func sampleRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .monospacedDigit()
        }
        .font(.caption)
    }

    private func adjustmentSlider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        format: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(value: value, in: range)
        }
    }
}
