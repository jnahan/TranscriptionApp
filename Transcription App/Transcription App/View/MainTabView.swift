import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Recordings", systemImage: "waveform")
                }
            
            FoldersView()
                .tabItem {
                    Label("Folders", systemImage: "folder")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Recording.self, RecordingSegment.self, Folder.self], inMemory: true)
}
