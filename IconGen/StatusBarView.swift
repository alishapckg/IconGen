import SwiftUI

struct StatusBarView: View {
  @EnvironmentObject private var generator: IconGenerator
  @Binding var messageID: UUID
  
  var body: some View {
    ZStack {
      HStack(spacing: 10) {
        if generator.statusMessage.contains("✅") {
          Image(systemName: "checkmark.seal.fill")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.green)
        } else if generator.statusMessage.contains("❌") {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.red)
        } else if generator.statusMessage.contains("⚠️") {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.orange)
        } else {
          Image(systemName: "info.circle")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.secondary)
        }
        
        Text(generator.statusMessage
          .replacingOccurrences(of: "✅ ", with: "")
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
    .padding(.bottom, 24)
  }
}