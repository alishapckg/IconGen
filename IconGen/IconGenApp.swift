import SwiftUI

@main
struct IconGenApp: App {
  @StateObject private var generator = IconGenerator()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(generator)
    }
  }
}
