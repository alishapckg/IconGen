import SwiftUI

struct ActionButtonsView: View {
  @EnvironmentObject private var generator: IconGenerator
  let hasImage: Bool
  let onSelectFile: () -> Void
  let onGenerate: () -> Void
  
  var body: some View {
    HStack(spacing: 14) {
      Button(action: {
        withAnimation(.easeInOut(duration: 0.2)) { onSelectFile() }
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
        withAnimation(.easeInOut(duration: 0.2)) { onGenerate() }
      }) {
        HStack(spacing: 8) {
          if generator.isGenerating {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .scaleEffect(0.85)
          } else {
            Image(systemName: "wand.and.stars.inverse")
              .font(.system(size: 15, weight: .medium))
          }
          Text(generator.isGenerating ? "Working..." : "Generate")
            .font(.system(size: 15, weight: .semibold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
          Group {
            if hasImage && !generator.isGenerating {
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
        .shadow(color: (hasImage && !generator.isGenerating) ? Color.purple.opacity(0.35) : Color.clear, radius: 12, x: 0, y: 6)
      }
      .buttonStyle(.plain)
      .disabled(!hasImage || generator.isGenerating)
      .animation(.spring(response: 0.4, dampingFraction: 0.7), value: hasImage)
      .animation(.easeInOut(duration: 0.2), value: generator.isGenerating)
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 24)
  }
}