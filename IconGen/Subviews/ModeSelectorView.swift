import SwiftUI

struct ModeSelectorView: View {
  @Binding var selectedMode: GenerationMode
  @Binding var iosIconStyle: IOSIconStyle
  
  var body: some View {
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
  }
}