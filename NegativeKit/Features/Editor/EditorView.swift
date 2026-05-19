//
//  EditorView.swift
//  NegativeKit
//
//  Created by Codex on 19/05/2026.
//

import SwiftUI

struct EditorView: View {
    @StateObject private var viewModel = EditorViewModel()

    var body: some View {
        NavigationSplitView {
            AdjustmentPanel(viewModel: viewModel)
        } detail: {
            ImagePreview(
                image: viewModel.previewImage,
                renderedExtent: viewModel.renderedExtent,
                selectedTool: viewModel.selectedTool,
                onClick: viewModel.handlePreviewClick(at:),
                onCrop: viewModel.setCrop(from:to:)
            )
        }
        .navigationTitle("NegativeKit")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    viewModel.openImage()
                } label: {
                    Label("Open", systemImage: "folder")
                }

                Button {
                    viewModel.exportImage()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(!viewModel.hasDocument)
            }
        }
        .alert("NegativeKit", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .frame(minWidth: 900, minHeight: 600)
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}

#Preview {
    EditorView()
}
