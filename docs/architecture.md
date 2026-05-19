# NegativeKit Architecture

NegativeKit is a native macOS SwiftUI application using Apple imaging frameworks.

## Stack

- Swift
- SwiftUI
- Core Image
- Image I/O
- Core Graphics
- UniformTypeIdentifiers
- AppKit where needed
- Swift Package Manager

Optional later:

- Metal
- Accelerate/vImage
- LibRaw
- Sparkle

## High-level structure

```txt
NegativeKit/
  NegativeKitApp.swift

  Features/
    Editor/
      EditorView.swift
      EditorViewModel.swift
      ImagePreview.swift
      AdjustmentPanel.swift

  ImagePipeline/
    ImageDocument.swift
    ImageLoader.swift
    NegativeConverter.swift
    FilmBaseSampler.swift
    ImageExporter.swift
    PreviewRenderer.swift

  Design/
    AppTheme.swift
    AppButtonStyle.swift

  Utilities/
    FilePicker.swift
    Logger.swift
```

## App entry point

```swift
@main
struct NegativeKitApp: App {
    var body: some Scene {
        WindowGroup {
            EditorView()
        }
    }
}
```

## Core pipeline

```txt
Input image
→ decode
→ normalize to working color space
→ sample film base
→ subtract/neutralize film base
→ invert negative
→ apply color balance
→ apply tone controls
→ render preview
→ export full-resolution image
```

## Internal image model

```txt
ImageDocument
- original file URL
- source CIImage
- adjustment settings
- optional film base sample
- metadata
```

## Adjustment model

```txt
NegativeAdjustments
- exposure
- contrast
- black point
- white point
- temperature
- tint
- saturation
- film base color
- inversion mode
```

## Preview vs export

The app should keep the original full-resolution image untouched.

Preview rendering should use a downscaled image for speed.

Export rendering should apply the same pipeline to the full-resolution source.

## Dependency approach

Start with Apple frameworks only.

Add dependencies only when they clearly solve a real problem.

## Future extension points

- LibRaw loader
- batch processor
- preset system
- film profiles
- CLI converter
- Sparkle updater
- Homebrew Cask release

```

```
