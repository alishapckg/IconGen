import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
  @EnvironmentObject private var generator: IconGenerator
  @Binding var droppedImage: NSImage?
  let onLoad: (NSImage) -> Void
  
  var body: some View {
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
                generator.statusMessage = "Drop a 1024x1024 image here"
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
  }
  
  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard let provider = providers.first else { return false }
    
    if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
      let _ = provider.loadDataRepresentation(for: UTType.fileURL) { data, error in
        DispatchQueue.main.async {
          if let data = data,
             let url = URL(dataRepresentation: data, relativeTo: nil),
             let image = NSImage(contentsOf: url) {
            onLoad(image)
          }
        }
      }
      return true
    }
    
    if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
      let _ = provider.loadDataRepresentation(for: UTType.image) { data, error in
        DispatchQueue.main.async {
          if let data = data, let image = NSImage(data: data) {
            onLoad(image)
          }
        }
      }
      return true
    }
    
    return false
  }
}