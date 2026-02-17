import SwiftUI

@main
struct FocusCareApp: App {
    @StateObject private var cameraManager = CameraManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cameraManager)
                .frame(minWidth: 960, minHeight: 620)
        }
    }
}
