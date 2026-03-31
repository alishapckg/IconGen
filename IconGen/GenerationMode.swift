enum GenerationMode: String, CaseIterable, Identifiable {
  case ios = "iOS (15 files)"
  case macos = "macOS (10 slots)"
  case all = "iOS + macOS"
  
  var id: String { self.rawValue }
}
