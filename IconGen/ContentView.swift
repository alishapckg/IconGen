import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  
  // MARK: - Parameters
  
  @State private var droppedImage: NSImage?
  @State private var isGenerating = false
  @State private var statusMessage = "Drop a 1024x1024 image here"
  @State private var showMessage = true
  @State private var selectedMode: GenerationMode = .ios
  @State private var iosIconStyle: IOSIconStyle = .allSizes
  @State private var messageID = UUID()
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 6) {
        Text("App Icon Generator")
          .font(.system(size: 26, weight: .bold, design: .rounded))
          .foregroundColor(.primary)
        
        Text("Perfect sizes for Xcode in one click")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.secondary)
      }
      .padding(.top, 32)
      .padding(.bottom, 24)
      
      HStack(spacing: 0) {
        ModePicker(selectedMode: $selectedMode)
      }
      .padding(.horizontal, 32)
      .padding(.bottom, selectedMode == .ios ? 14 : 28)
      
      if selectedMode == .ios {
        HStack(spacing: 10) {
          Text("Method")
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.secondary)
          
          StyledSegmentControl(
            options: [IOSIconStyle.allSizes, IOSIconStyle.singleSize],
            selection: $iosIconStyle,
            label: { $0 == .allSizes ? "All Sizes" : "Single Size" }
          )
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 14)
      }
      
      ZStack {
        RoundedRectangle(cornerRadius: 24)
          .fill(Color(NSColor.controlBackgroundColor))
          .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
          .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
          .overlay(
            RoundedRectangle(cornerRadius: 24)
              .strokeBorder(
                droppedImage != nil
                ? Color.green.opacity(0.3)
                : Color.blue.opacity(0.15),
                style: StrokeStyle(lineWidth: 2, dash: [12])
              )
          )
          .frame(width: 320, height: 220)
        
        if let image = droppedImage {
          Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .cornerRadius(26)
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
            .transition(.asymmetric(
              insertion: .scale(scale: 0.5).combined(with: .opacity),
              removal: .scale(scale: 0.8).combined(with: .opacity)
            ))
            .overlay(alignment: .topTrailing) {
              Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                  droppedImage = nil
                  statusMessage = "Drop a 1024x1024 image here"
                  messageID = UUID()
                }
              }) {
                Image(systemName: "xmark.circle.fill")
                  .font(.system(size: 28, weight: .medium))
                  .symbolRenderingMode(.palette)
                  .foregroundStyle(.white, .red.opacity(0.85))
                  .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
              }
              .buttonStyle(.plain)
              .offset(x: 14, y: -14)
              .transition(.identity)
            }
        } else {
          VStack(spacing: 14) {
            Image(systemName: "arrow.down.doc.fill")
              .font(.system(size: 44, weight: .light))
              .foregroundStyle(
                .linearGradient(
                  colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
            
            Text("Drag & Drop PNG")
              .font(.system(size: 15, weight: .semibold, design: .rounded))
              .foregroundColor(.secondary.opacity(0.8))
          }
          .transition(.opacity)
        }
      }
      .frame(height: 220)
      .padding(.horizontal, 32)
      .onDrop(of: [.image, .fileURL], isTargeted: nil) { providers in
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
          handleDrop(providers: providers)
        }
      }
      .padding(.bottom, 28)
      
      HStack(spacing: 14) {
        Button(action: {
          withAnimation(.easeInOut(duration: 0.2)) { selectFile() }
        }) {
          HStack(spacing: 8) {
            Image(systemName: "folder")
              .font(.system(size: 15, weight: .medium))
            Text("Select File")
              .font(.system(size: 15, weight: .semibold, design: .rounded))
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(Color(NSColor.controlBackgroundColor))
          .cornerRadius(14)
          .overlay(
            RoundedRectangle(cornerRadius: 14)
              .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
          )
          .foregroundColor(.primary)
          .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        
        Button(action: {
          withAnimation(.easeInOut(duration: 0.2)) { generateIcons() }
        }) {
          HStack(spacing: 8) {
            if isGenerating {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.85)
            } else {
              Image(systemName: "wand.and.stars.inverse")
                .font(.system(size: 15, weight: .medium))
            }
            Text(isGenerating ? "Working..." : "Generate")
              .font(.system(size: 15, weight: .semibold, design: .rounded))
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(
            Group {
              if droppedImage != nil && !isGenerating {
                LinearGradient(
                  colors: [Color.blue, Color.purple],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              } else {
                LinearGradient(
                  colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.5)],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              }
            }
          )
          .cornerRadius(14)
          .foregroundColor(.white)
          .shadow(color: (droppedImage != nil && !isGenerating) ? Color.purple.opacity(0.35) : Color.clear, radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(droppedImage == nil || isGenerating)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: droppedImage)
        .animation(.easeInOut(duration: 0.2), value: isGenerating)
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 24)
      
      ZStack {
        if showMessage {
          HStack(spacing: 10) {
            if statusMessage.contains("✅") {
              Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.green)
            } else if statusMessage.contains("❌") {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
            } else if statusMessage.contains("⚠️") {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.orange)
            } else {
              Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary)
            }
            
            Text(statusMessage.replacingOccurrences(of: "✅ ", with: "").replacingOccurrences(of: "❌ Error: ", with: "").replacingOccurrences(of: "⚠️ ", with: ""))
              .font(.system(size: 13, weight: .medium, design: .rounded))
              .foregroundColor(.secondary)
              .lineLimit(nil)
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .fixedSize(horizontal: true, vertical: true)
          .background(Color(NSColor.controlBackgroundColor))
          .cornerRadius(14)
          .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
          .padding(.horizontal, 32)
          .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
            removal: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95))
          ))
          .id(messageID)
        }
      }
      .padding(.bottom, 24)
    }
    .frame(width: 400)
    .background(Color(NSColor.windowBackgroundColor))
  }
  
  
  // MARK: - Logic
  
  private func processAndSave(image: NSImage, to directory: URL, mode: GenerationMode) {
    let setUrl = directory.appendingPathComponent("AppIcon.appiconset")
    
    do {
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
        if iosIconStyle == .singleSize {
          let singleSizeFiles: [(file: String, appearance: String?)] = [
            ("AppIcon.png", nil),
            ("AppIcon-Dark.png", "dark"),
            ("AppIcon-Tinted.png", "tinted")
          ]
          for (file, _) in singleSizeFiles {
            if let data = getPNGData(for: image, size: 1024) {
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
            if let data = getPNGData(for: image, size: size) {
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
        // 7 files for 10 slots
        let macSizes = [16, 32, 64, 128, 256, 512, 1024]
        for size in macSizes {
          let fileName = "icon_\(size)x\(size).png"
          if let data = getPNGData(for: image, size: size) {
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
          if let data = getPNGData(for: image, size: slot.px) {
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
      
      DispatchQueue.main.async {
        self.isGenerating = false
        self.statusMessage = "✅ Done! Generated \(jsonImages.count) icon slots."
        self.messageID = UUID()
        
        NSWorkspace.shared.open(setUrl)
      }
    } catch {
      DispatchQueue.main.async {
        self.isGenerating = false
        self.statusMessage = "❌ Error: \(error.localizedDescription)"
        self.messageID = UUID()
      }
    }
  }
  
  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard let provider = providers.first else { return false }
    
    if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
      let _ = provider.loadDataRepresentation(for: UTType.fileURL) { data, error in
        DispatchQueue.main.async {
          if let data = data,
             let url = URL(dataRepresentation: data, relativeTo: nil),
             let image = NSImage(contentsOf: url) {
            self.loadImage(image)
          }
        }
      }
      return true
    }
    
    if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
      let _ = provider.loadDataRepresentation(for: UTType.image) { data, error in
        DispatchQueue.main.async {
          if let data = data, let image = NSImage(data: data) {
            self.loadImage(image)
          }
        }
      }
      return true
    }
    
    return false
  }
  
  private func selectFile() {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.image]
    panel.allowsMultipleSelection = false
    if panel.runModal() == .OK, let url = panel.url {
      if let image = NSImage(contentsOf: url) {
        self.loadImage(image)
      }
    }
  }
  
  private func loadImage(_ image: NSImage) {
    self.droppedImage = image
    let pixelSize = imagePixelSize(image)
    if pixelSize.width != 1024 || pixelSize.height != 1024 {
      self.statusMessage = "⚠️ Image is \(Int(pixelSize.width))x\(Int(pixelSize.height)) — recommended 1024x1024, it will be resized"
    } else {
      self.statusMessage = "Image loaded! Select a mode and click 'Generate'"
    }
    self.messageID = UUID()
  }
  
  private func imagePixelSize(_ image: NSImage) -> NSSize {
    if let rep = image.representations.first(where: { $0 is NSBitmapImageRep }) as? NSBitmapImageRep {
      return NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
    }
    if let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
      return NSSize(width: cg.width, height: cg.height)
    }
    return NSSize(width: image.size.width, height: image.size.height)
  }
  
  private func generateIcons() {
    guard let originalImage = droppedImage else { return }
    
    let panel = NSOpenPanel()
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.canChooseFiles = false
    panel.prompt = "Save Here"
    
    if panel.runModal() == .OK, let saveUrl = panel.url {
      isGenerating = true
      statusMessage = "Creating folder and resizing..."
      messageID = UUID()
      
      DispatchQueue.global(qos: .userInitiated).async {
        self.processAndSave(image: originalImage, to: saveUrl, mode: self.selectedMode)
      }
    }
  }
  
  private func getPNGData(for image: NSImage, size: Int) -> Data? {
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
