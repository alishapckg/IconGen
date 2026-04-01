import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  
  // MARK: - Parameters
  
  @State private var droppedImage: NSImage?
  @State private var isGenerating = false
  @State private var statusMessage = "Drop a 1024x1024 image here"
  @State private var showMessage = true
  @State private var selectedMode: GenerationMode = .ios
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 20) {
      Text("App Icon Generator")
        .font(.largeTitle)
        .bold()
      
      Picker("Mode", selection: $selectedMode) {
        ForEach(GenerationMode.allCases) { mode in
          Text(mode.rawValue).tag(mode)
        }
      }
      .pickerStyle(.segmented)
      
      ZStack {
        Rectangle()
          .fill(Color(nsColor: .controlBackgroundColor))
          .frame(width: 300, height: 220)
          .cornerRadius(16)
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(style: StrokeStyle(lineWidth: 3, dash: [10]))
              .foregroundColor(.accentColor)
          )
        
        if let image = droppedImage {
          Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .cornerRadius(16)
            .shadow(radius: 10)
        } else {
          VStack {
            Image(systemName: "arrow.down.doc.fill")
              .font(.system(size: 40))
              .foregroundColor(.secondary)
            Text("Drag & Drop PNG")
              .padding(.top, 8)
          }
        }
      }
      .onDrop(of: [.image, .fileURL], isTargeted: nil) { providers in
        handleDrop(providers: providers)
      }
      
      HStack(spacing: 20) {
        Button(action: selectFile) {
          Text("Select File")
            .frame(width: 130)
        }
        
        Button(action: generateIcons) {
          Text(isGenerating ? "Generating..." : "Generate")
            .frame(width: 130)
        }
        .buttonStyle(.borderedProminent)
        .disabled(droppedImage == nil || isGenerating)
      }
      
      if showMessage {
        Text(statusMessage)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .frame(width: 350)
          .font(.callout)
      }
    }
    .padding(30)
  }
  
  // MARK: - Logic
  
  private func processAndSave(image: NSImage, to directory: URL, mode: GenerationMode) {
    let setUrl = directory.appendingPathComponent("AppIcon.appiconset")
    
    do {
      try FileManager.default.createDirectory(at: setUrl, withIntermediateDirectories: true)
      var jsonImages: [[String: String]] = []
      
      // --- iOS ---
      if mode == .ios || mode == .all {
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
        
        // Маппинг строго по вашему списку
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
      
      let jsonDict: [String: Any] = ["images": jsonImages, "info": ["version": 1, "author": "xcode"]]
      let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
      try jsonData.write(to: setUrl.appendingPathComponent("Contents.json"))
      
      DispatchQueue.main.async {
        self.isGenerating = false
        self.statusMessage = "✅ Done! Generated \(jsonImages.count) icon slots."
        NSWorkspace.shared.open(setUrl)
      }
    } catch {
      DispatchQueue.main.async {
        self.isGenerating = false
        self.statusMessage = "❌ Error: \(error.localizedDescription)"
      }
    }
  }
  
  // MARK: - Drag & Drop / File Select
  
  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard let provider = providers.first else { return false }
    
    // 1. First, check if we dropped a FILE (e.g., from Desktop or Finder)
    if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
      let _ = provider.loadDataRepresentation(for: UTType.fileURL) { data, error in
        DispatchQueue.main.async {
          if let data = data,
             let url = URL(dataRepresentation: data, relativeTo: nil),
             let image = NSImage(contentsOf: url) {
            self.droppedImage = image
            self.statusMessage = "Image loaded! Select a mode and click 'Generate'"
          }
        }
      }
      return true
    }
    
    // 2. If we dropped an IMAGE directly (e.g., from browser or photos)
    if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
      let _ = provider.loadDataRepresentation(for: UTType.image) { data, error in
        DispatchQueue.main.async {
          if let data = data, let image = NSImage(data: data) {
            self.droppedImage = image
            self.statusMessage = "Image loaded! Select a mode and click 'Generate'"
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
        self.droppedImage = image
        self.statusMessage = "Image loaded! Select a mode and click 'Generate'"
      }
    }
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
      
      DispatchQueue.global(qos: .userInitiated).async {
        self.processAndSave(image: originalImage, to: saveUrl, mode: self.selectedMode)
      }
    }
  }
  
  // MARK: - Resize
  
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
