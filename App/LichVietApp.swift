import SwiftUI

@main
struct LichVietApp: App {
    init() {
        Typeface.register()
    }

    var body: some Scene {
        WindowGroup {
            TodayView()
        }
    }
}
