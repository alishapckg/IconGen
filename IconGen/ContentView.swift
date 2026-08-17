import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  
  // MARK: - Parameters
  
  @EnvironmentObject private var generator: IconGenerator
  @State private var droppedImage: NSImage?
  @State private var selectedMode: GenerationMode = .ios
  @State private var iosIconStyle: IOSIconStyle = .allSizes
  @State private var messageID = UUID()
  
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 0) {
      HeaderView()
        .padding(.top, 32)
        .padding(.bottom, 24)
      
      ModeSelectorView(
        selectedMode: $selectedMode,
        iosIconStyle: $iosIconStyle
      )
      
      DropZoneView(
        droppedImage: $droppedImage,
        onLoad: loadImage
      )
      
      ActionButtonsView(
        hasImage: droppedImage != nil,
        onSelectFile: selectFile,
        onGenerate: generateIcons
      )
      
      StatusBarView(messageID: $messageID)
    }
    .frame(width: 400)
    .background(Color(NSColor.windowBackgroundColor))
    .onChange(of: generator.statusMessage) {
      messageID = UUID()
    }
  }
  
  
  // MARK: - Actions
  
  private func selectFile() {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.image]
    panel.allowsMultipleSelection = false
    if panel.runModal() == .OK, let url = panel.url {
      if let image = NSImage(contentsOf: url) {
        loadImage(image)
      }
    }
  }
  
  private func loadImage(_ image: NSImage) {
    self.droppedImage = image
    generator.notifyImageLoaded(image)
  }
  
  private func generateIcons() {
    guard let originalImage = droppedImage else { return }
    
    let panel = NSOpenPanel()
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.canChooseFiles = false
    panel.prompt = "Save Here"
    
    if panel.runModal() == .OK, let saveUrl = panel.url {
      generator.generate(image: originalImage, to: saveUrl, mode: selectedMode, iosStyle: iosIconStyle)
    }
  }
}
