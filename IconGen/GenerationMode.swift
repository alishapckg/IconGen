enum GenerationMode: String, CaseIterable, Identifiable {
  case ios
  case macos
  case watchos
  case all
  
  var id: String { self.rawValue }
  
  var rawValue: String {
    switch self {
    case .ios: return "iOS"
    case .macos: return "macOS"
    case .watchos: return "watchOS"
    case .all: return "All"
    }
  }
}

enum IOSIconStyle: String, CaseIterable, Identifiable {
  case allSizes
  case singleSize
  
  var id: String { self.rawValue }
}
