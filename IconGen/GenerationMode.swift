enum GenerationMode: String, CaseIterable, Identifiable {
  case single = "Single 1024x1024"
  case all = "All Sizes (15 files)"
  var id: String { self.rawValue }
}
