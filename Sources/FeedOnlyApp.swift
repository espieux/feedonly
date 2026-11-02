import SwiftUI

@main
struct FeedOnlyApp: App {
    var body: some Scene {
        WindowGroup {
            InstagramView()
                .background(Color(uiColor: .systemBackground))
        }
    }
}
