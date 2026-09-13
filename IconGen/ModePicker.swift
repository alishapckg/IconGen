import SwiftUI

struct ModePicker: View {
  @Binding var selectedMode: GenerationMode
  @Namespace private var pickerNamespace
  
  var body: some View {
    HStack(spacing: 10) {
      Text("Mode")
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .foregroundColor(.secondary)
      
      HStack(spacing: 4) {
        ForEach(GenerationMode.allCases) { mode in
          Text(mode.rawValue)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
              if selectedMode == mode {
                LinearGradient(
                  colors: [.blue, .purple],
                  startPoint: .leading,
                  endPoint: .trailing
                )
                .cornerRadius(8)
                .matchedGeometryEffect(id: "selection", in: pickerNamespace)
              }
            }
            .foregroundColor(selectedMode == mode ? .white : .primary)
            .contentShape(Rectangle())
            .onTapGesture {
              withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedMode = mode
              }
            }
        }
      }
      .padding(4)
      .background(Color(NSColor.controlBackgroundColor))
      .cornerRadius(10)
      .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
  }
}
