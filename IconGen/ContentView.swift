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
            
            Text(statusMessage.replacingOccurrences(of: "✅ ", with: "")
              .replacingOccurrences(of: "❌ Error: ", with: "")
              .replacingOccurrences(of: "⚠️ ", with: ""))
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
  
  
  // MARK: - Image Loading
  
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
    let pixelSize = IconGenerator().pixelSize(of: image)
    if pixelSize.width != 1024 || pixelSize.height != 1024 {
      self.statusMessage = "⚠️ Image is \(Int(pixelSize.width))x\(Int(pixelSize.height)) — recommended 1024x1024, it will be resized"
    } else {
      self.statusMessage = "Image loaded! Select a mode and click 'Generate'"
    }
    self.messageID = UUID()
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
      
      let generator = IconGenerator()
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let slotCount = try generator.generate(
            image: originalImage,
            to: saveUrl,
            mode: self.selectedMode,
            iosStyle: self.iosIconStyle
          )
          DispatchQueue.main.async {
            self.isGenerating = false
            self.statusMessage = "✅ Done! Generated \(slotCount) icon slots."
            self.messageID = UUID()
            NSWorkspace.shared.open(saveUrl.appendingPathComponent("AppIcon.appiconset"))
          }
        } catch {
          DispatchQueue.main.async {
            self.isGenerating = false
            self.statusMessage = "❌ Error: \(error.localizedDescription)"
            self.messageID = UUID()
          }
        }
      }
    }
  }
}
