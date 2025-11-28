import SwiftUI
import SwiftData

struct FoldersView: View {
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
            VStack(spacing: 0) {
                CustomTopBar(
                    title: "Collections",
                    rightIcon: "gear-six",
                    onRightTap: { showSettings = true }
                )
                
                SearchBar(text: $searchText, placeholder: "Search...")
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                
                List {
                    ForEach(filteredFolders) { folder in
                        Button {
                            selectedFolder = folder
                        } label: {
                            FolderRow(
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
            .background(Color.warmGray50.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedFolder) { folder in
                FolderDetailView(folder: folder, showPlusButton: showPlusButton)
                    .onAppear { showPlusButton.wrappedValue = false }
                    .onDisappear { showPlusButton.wrappedValue = true }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .overlay {
                if folders.isEmpty {
                    EmptyStateView(
                        icon: "folder",
                        title: "No Folders",
                        description: "Create a folder to organize your recordings",
                        actionTitle: nil,
                        action: nil
                    )
                }
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
}

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allRecordings: [Recording]
    
    @StateObject private var viewModel = RecordingListViewModel()
    
    let folder: Folder
    var showPlusButton: Binding<Bool>
    
    @State private var searchText = ""
    
    private var recordings: [Recording] {
        allRecordings.filter { $0.folder?.id == folder.id }
    }
    
    private var filteredRecordings: [Recording] {
        if searchText.isEmpty {
            return recordings
        } else {
            return recordings.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.fullText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomTopBar(
                    title: folder.name,
                    leftIcon: "caret-left",
                    onLeftTap: { dismiss() }
                )
                
                SearchBar(text: $searchText, placeholder: "Search...")
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                
                List {
                    ForEach(filteredRecordings) { recording in
                        NavigationLink(value: recording) {
                            RecordingRow(
                                recording: recording,
                                player: viewModel.player,
                                onCopy: { viewModel.copyRecording(recording) },
                                onEdit: { viewModel.editRecording(recording) },
                                onDelete: { viewModel.deleteRecording(recording) }
                            )
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(filteredRecordings[index])
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.warmGray50)
            }
            .background(Color.warmGray50.ignoresSafeArea())
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .navigationDestination(for: Recording.self) { recording in
                RecordingDetailsView(recording: recording)
                    .onAppear { showPlusButton.wrappedValue = false }
            }
            .overlay {
                if recordings.isEmpty {
                    EmptyStateView(
                        icon: "mic.slash",
                        title: "No Recordings",
                        description: "This folder is empty",
                        actionTitle: nil,
                        action: nil
                    )
                }
            }
            
            if viewModel.showCopyToast {
                VStack {
                    CopyToast()
                    Spacer()
                }
                .padding(.top, 10)
            }
            
            if viewModel.editingRecording != nil {
                EditRecordingOverlay(
                    isPresented: Binding(
                        get: { viewModel.editingRecording != nil },
                        set: { if !$0 { viewModel.cancelEdit() } }
                    ),
                    newTitle: $viewModel.newRecordingTitle,
                    onSave: viewModel.saveEdit
                )
            }
        }
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
    }
}

#Preview {
    FoldersView()
        .modelContainer(for: [Recording.self, RecordingSegment.self, Folder.self], inMemory: true)
}
