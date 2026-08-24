import AppKit
import Combine

enum IOSIconStyle: String, CaseIterable, Identifiable {
  case allSizes
  case singleSize
  
  var id: String { self.rawValue }
}

@MainActor
final class IconGenerator: ObservableObject {
  @Published var isGenerating = false
  @Published var statusMessage = "Drop a 1024x1024 image here"
  
  func generate(image: NSImage, to directory: URL, mode: GenerationMode, iosStyle: IOSIconStyle) {
    guard !isGenerating else { return }
    isGenerating = true
    statusMessage = "Creating folder and resizing..."
    
    let setUrl = directory.appendingPathComponent("AppIcon.appiconset")
    Task {
      do {
        let slotCount = try await Task.detached(priority: .userInitiated) {
          try IconGenerator.writeIconSet(image: image, to: setUrl, mode: mode, iosStyle: iosStyle)
        }.value
        isGenerating = false
        statusMessage = "✅ Done! Generated \(slotCount) icon slots."
        NSWorkspace.shared.open(setUrl)
      } catch {
        isGenerating = false
        statusMessage = "❌ Error: \(error.localizedDescription)"
      }
    }
  }
  
  func notifyImageLoaded(_ image: NSImage) {
    let pixelSize = pixelSize(of: image)
    if pixelSize.width != 1024 || pixelSize.height != 1024 {
      statusMessage = "⚠️ Image is \(Int(pixelSize.width))x\(Int(pixelSize.height)) — recommended 1024x1024, it will be resized"
    } else {
      statusMessage = "Image loaded! Select a mode and click 'Generate'"
    }
  }
  
  nonisolated func pixelSize(of image: NSImage) -> NSSize {
    if let rep = image.representations.first(where: { $0 is NSBitmapImageRep }) as? NSBitmapImageRep {
      return NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
    }
    if let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
      return NSSize(width: cg.width, height: cg.height)
    }
    return NSSize(width: image.size.width, height: image.size.height)
  }
  
  private nonisolated static func writeIconSet(image: NSImage, to setUrl: URL, mode: GenerationMode, iosStyle: IOSIconStyle) throws -> Int {
    if FileManager.default.fileExists(atPath: setUrl.path) {
      let existing = try FileManager.default.contentsOfDirectory(at: setUrl, includingPropertiesForKeys: nil)
      for staleUrl in existing {
        try FileManager.default.removeItem(at: staleUrl)
      }
    }
    try FileManager.default.createDirectory(at: setUrl, withIntermediateDirectories: true)
    var jsonImages: [[String: Any]] = []
    
    // --- iOS ---
    if mode == .ios || mode == .all {
      if iosStyle == .singleSize {
        let singleSizeFiles: [(file: String, appearance: String?)] = [
          ("AppIcon.png", nil),
          ("AppIcon-Dark.png", "dark"),
          ("AppIcon-Tinted.png", "tinted")
        ]
        for (file, _) in singleSizeFiles {
          if let data = pngData(for: image, size: 1024) {
            try data.write(to: setUrl.appendingPathComponent(file))
          }
        }
        for (file, appearance) in singleSizeFiles {
          var entry: [String: Any] = [
            "filename": file,
            "idiom": "universal",
            "platform": "ios",
            "size": "1024x1024"
          ]
          if let appearance {
            entry["appearances"] = [["appearance": "luminosity", "value": appearance]]
          }
          jsonImages.append(entry)
        }
      } else {
        let iosSizes = [40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]
        for size in iosSizes {
          let fileName = "icon_\(size)x\(size).png"
          if let data = pngData(for: image, size: size) {
            try data.write(to: setUrl.appendingPathComponent(fileName))
          }
        }
        jsonImages.append(contentsOf: [
          ["filename": "icon_40x40.png",   "size": "20x20",     "scale": "2x", "idiom": "iphone"],
          ["filename": "icon_60x60.png",   "size": "20x20",     "scale": "3x", "idiom": "iphone"],
          ["filename": "icon_40x40.png",   "size": "20x20",     "scale": "2x", "idiom": "ipad"],
          ["filename": "icon_58x58.png",   "size": "29x29",     "scale": "2x", "idiom": "iphone"],
          ["filename": "icon_87x87.png",   "size": "29x29",     "scale": "3x", "idiom": "iphone"],
          ["filename": "icon_58x58.png",   "size": "29x29",     "scale": "2x", "idiom": "ipad"],
          ["filename": "icon_80x80.png",   "size": "40x40",     "scale": "2x", "idiom": "iphone"],
          ["filename": "icon_120x120.png", "size": "40x40",     "scale": "3x", "idiom": "iphone"],
          ["filename": "icon_80x80.png",   "size": "40x40",     "scale": "2x", "idiom": "ipad"],
          ["filename": "icon_120x120.png", "size": "60x60",     "scale": "2x", "idiom": "iphone"],
          ["filename": "icon_180x180.png", "size": "60x60",     "scale": "3x", "idiom": "iphone"],
          ["filename": "icon_76x76.png",   "size": "76x76",     "scale": "1x", "idiom": "ipad"],
          ["filename": "icon_152x152.png", "size": "76x76",     "scale": "2x", "idiom": "ipad"],
          ["filename": "icon_167x167.png", "size": "83.5x83.5", "scale": "2x", "idiom": "ipad"],
          ["filename": "icon_1024x1024.png","size": "1024x1024","scale": "1x", "idiom": "ios-marketing"]
        ])
      }
    }
    
    // --- macOS ---
    if mode == .macos || mode == .all {
      let macSizes = [16, 32, 64, 128, 256, 512, 1024]
      for size in macSizes {
        let fileName = "icon_\(size)x\(size).png"
        if let data = pngData(for: image, size: size) {
          try data.write(to: setUrl.appendingPathComponent(fileName))
        }
      }
      
      jsonImages.append(contentsOf: [
        ["filename": "icon_16x16.png",     "size": "16x16",     "scale": "1x", "idiom": "mac"], // 16x16 px (1x) 16 pt
        ["filename": "icon_32x32.png",     "size": "16x16",     "scale": "2x", "idiom": "mac"], // 32x32 px (2x) 16 pt
        ["filename": "icon_32x32.png",     "size": "32x32",     "scale": "1x", "idiom": "mac"], // 32x32 px (1x) 32 pt
        ["filename": "icon_64x64.png",     "size": "32x32",     "scale": "2x", "idiom": "mac"], // 64x64 px (2x) 32 pt
        ["filename": "icon_128x128.png",   "size": "128x128",   "scale": "1x", "idiom": "mac"], // 128x128 px (1x) 128 pt
        ["filename": "icon_256x256.png",   "size": "128x128",   "scale": "2x", "idiom": "mac"], // 256x256 px (2x) 128 pt
        ["filename": "icon_256x256.png",   "size": "256x256",   "scale": "1x", "idiom": "mac"], // 256x256 px (1x) 256 pt
        ["filename": "icon_512x512.png",   "size": "256x256",   "scale": "2x", "idiom": "mac"], // 512x512 px (2x) 256 pt
        ["filename": "icon_512x512.png",   "size": "512x512",   "scale": "1x", "idiom": "mac"], // 512x512 px (1x) 512 pt
        ["filename": "icon_1024x1024.png", "size": "512x512",   "scale": "2x", "idiom": "mac"]  // 1024x1024 px (2x) 512 pt
      ])
    }
    
    // --- watchOS ---
    if mode == .watchos || mode == .all {
      // 20 slots, Xcode 26 "All Sizes" schema (universal idiom, no roles/subtypes)
      let watchSlots: [(file: String, px: Int, size: String, scale: String?)] = [
        ("icon_44x44.png",   44,   "22x22",     "2x"),
        ("icon_48x48.png",   48,   "24x24",     "2x"),
        ("icon_55x55.png",   55,   "27.5x27.5", "2x"),
        ("icon_58x58.png",   58,   "29x29",     "2x"),
        ("icon_60x60.png",   60,   "30x30",     "2x"),
        ("icon_64x64.png",   64,   "32x32",     "2x"),
        ("icon_66x66.png",   66,   "33x33",     "2x"),
        ("icon_80x80.png",   80,   "40x40",     "2x"),
        ("icon_87x87.png",   87,   "43.5x43.5", "2x"),
        ("icon_88x88.png",   88,   "44x44",     "2x"),
        ("icon_92x92.png",   92,   "46x46",     "2x"),
        ("icon_100x100.png", 100,  "50x50",     "2x"),
        ("icon_102x102.png", 102,  "51x51",     "2x"),
        ("icon_108x108.png", 108,  "54x54",     "2x"),
        ("icon_172x172.png", 172,  "86x86",     "2x"),
        ("icon_196x196.png", 196,  "98x98",     "2x"),
        ("icon_216x216.png", 216,  "108x108",   "2x"),
        ("icon_234x234.png", 234,  "117x117",   "2x"),
        ("icon_258x258.png", 258,  "129x129",   "2x"),
        ("icon_1024x1024.png", 1024, "1024x1024", nil)
      ]
      
      for slot in watchSlots {
        if let data = pngData(for: image, size: slot.px) {
          try data.write(to: setUrl.appendingPathComponent(slot.file))
        }
        var entry: [String: Any] = [
          "filename": slot.file,
          "idiom": "universal",
          "platform": "watchos",
          "size": slot.size
        ]
        if let scale = slot.scale {
          entry["scale"] = scale
        }
        jsonImages.append(entry)
      }
    }
    
    let jsonDict: [String: Any] = ["images": jsonImages, "info": ["version": 1, "author": "xcode"]]
    let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
    try jsonData.write(to: setUrl.appendingPathComponent("Contents.json"))
    
    return jsonImages.count
  }
  
  private nonisolated static func pngData(for image: NSImage, size: Int) -> Data? {
    guard let rep = NSBitmapImageRep(
      bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
      colorSpaceName: .deviceRGB, bytesPerRow: 4 * size, bitsPerPixel: 32
    ) else { return nil }
    
    rep.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
               from: NSRect(origin: .zero, size: image.size),
               operation: .copy, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()
    
    return rep.representation(using: .png, properties: [:])
  }
}