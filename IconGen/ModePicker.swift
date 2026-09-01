import SwiftUI

struct ModePicker: View {
  @Binding var selectedMode: GenerationMode
  
  var body: some View {
    HStack(spacing: 10) {
      Text("Mode")
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .foregroundColor(.secondary)
      
      StyledSegmentControl(
        options: GenerationMode.allCases,
        selection: $selectedMode,
        label: { $0.rawValue }
      )
    }
  }
}
