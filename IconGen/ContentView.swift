import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  
  // MARK: - Parameters
  
  @State private var droppedImage: NSImage?
  @State private var isGenerating = false
  @State private var statusMessage = "Drop a 1024x1024 image here"
  @State private var showMessage = true
  @State private var selectedMode: GenerationMode = .ios
  @State private var messageID = UUID()
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 6) {
        Text("App Icon Generator")
          .font(.system(size: 26, weight: .bold, design: .rounded))
          .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
        
        Text("Perfect sizes for Xcode in one click")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.secondary)
      }
      .padding(.top, 32)
      .padding(.bottom, 24)
      
      HStack(spacing: 0) {
        Picker("Mode", selection: $selectedMode) {
          ForEach(GenerationMode.allCases) { mode in
            Text(mode.rawValue).tag(mode)
          }
        }
        .pickerStyle(.segmented)
        .padding(4)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 28)
      
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
              .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
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
            } else {
              Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary)
            }
            
            Text(statusMessage.replacingOccurrences(of: "✅ ", with: "").replacingOccurrences(of: "❌ Error: ", with: ""))
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
            self.droppedImage = image
            self.statusMessage = "Image loaded! Select a mode and click 'Generate'"
            self.messageID = UUID()
          }
        }
      }
      return true
    }
    
    if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
      let _ = provider.loadDataRepresentation(for: UTType.image) { data, error in
        DispatchQueue.main.async {
          if let data = data, let image = NSImage(data: data) {
            self.droppedImage = image
            self.statusMessage = "Image loaded! Select a mode and click 'Generate'"
            self.messageID = UUID()
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
        self.messageID = UUID()
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
