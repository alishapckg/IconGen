import SwiftUI

struct HeaderView: View {
  var body: some View {
    VStack(spacing: 6) {
      Text("App Icon Generator")
        .font(.system(size: 26, weight: .bold, design: .rounded))
        .foregroundColor(.primary)
      
      Text("Perfect sizes for Xcode in one click")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)
    }
  }
}