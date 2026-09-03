import SwiftUI

struct StyledSegmentControl<T: Identifiable & Hashable>: View {
  let options: [T]
  @Binding var selection: T
  let label: (T) -> String
  @Namespace private var namespace
  
  var body: some View {
    HStack(spacing: 4) {
      ForEach(options) { option in
        Text(label(option))
          .font(.system(size: 13, weight: .semibold, design: .rounded))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background {
            if selection == option {
              LinearGradient(
                colors: [.blue, .purple],
                startPoint: .leading,
                endPoint: .trailing
              )
              .cornerRadius(8)
              .matchedGeometryEffect(id: "selection", in: namespace)
            }
          }
          .foregroundColor(selection == option ? .white : .primary)
          .contentShape(Rectangle())
          .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
              selection = option
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