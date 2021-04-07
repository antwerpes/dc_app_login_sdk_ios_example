import SwiftUI

@main
struct AppLoginTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ExternalModel())
        }
    }
}
