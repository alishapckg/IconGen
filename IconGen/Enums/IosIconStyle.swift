enum IOSIconStyle: String, CaseIterable, Identifiable {
  case allSizes
  case singleSize
  
  var id: String { self.rawValue }
}
