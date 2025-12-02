import SwiftUI
import SwiftData

struct CollectionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.showPlusButton) private var showPlusButton
    @Query private var folders: [Folder]
    @Query private var recordings: [Recording]
    
    @State private var showCreateFolder = false
    @State private var newFolderName = ""
    @State private var searchText = ""
    @State private var selectedFolder: Folder?
    @State private var showSettings = false
    
    private var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return folders
        } else {
            return folders.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient at absolute top of screen (when empty)
                if folders.isEmpty {
                    VStack(spacing: 0) {
                        Image("radial-gradient")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .rotationEffect(.degrees(180))
                            .clipped()
                        
                        Spacer()
                    }
                    .ignoresSafeArea(edges: .top)
                }
                
                VStack(spacing: 0) {
                    CustomTopBar(
                        title: "Collections",
                        rightIcon: "folder-plus",
                        onRightTap: { showCreateFolder = true }
                    )
                    
                    if !folders.isEmpty {
                        SearchBar(text: $searchText, placeholder: "Search collections...")
                            .padding(.horizontal, 20)
                    }
                    
                    if folders.isEmpty {
                        CollectionsEmptyState(showCreateFolder: $showCreateFolder)
                    } else {
                        List {
                            ForEach(filteredFolders) { folder in
                                Button {
                                    selectedFolder = folder
                                } label: {
                                    CollectionsRow(
                                        folder: folder,
                                        recordingCount: recordingCount(for: folder)
                                    )
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.warmGray50)
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            }
                            .onDelete(perform: deleteFolders)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.warmGray50)
                    }
                }
            }
            .background(Color.warmGray50.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedFolder) { folder in
                CollectionDetailView(folder: folder, showPlusButton: showPlusButton)
                    .onAppear { showPlusButton.wrappedValue = false }
                    .onDisappear { showPlusButton.wrappedValue = true }
            }
            .sheet(isPresented: $showCreateFolder) {
                CreateFolderSheet(
                    isPresented: $showCreateFolder,
                    folderName: $newFolderName,
                    onCreate: createFolder
                )
            }
        }
    }
    
    private func recordingCount(for folder: Folder) -> Int {
        recordings.filter { $0.folder?.id == folder.id }.count
    }
    
    private func deleteFolders(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredFolders[index])
            }
        }
    }
    
    private func createFolder() {
        guard !newFolderName.isEmpty else { return }
        
        let folder = Folder(name: newFolderName)
        modelContext.insert(folder)
        newFolderName = ""
        showCreateFolder = false
    }
}

#Preview {
    CollectionsView()
        .modelContainer(for: [Recording.self, RecordingSegment.self, Folder.self], inMemory: true)
}
