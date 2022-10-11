import SwiftUI

/// List to display files and child directories contains in target directory.
struct DirectoryView: View {
    /// Model of view.
    @StateObject private var viewModel: DirectoryViewModel

    init(directory: Directory, sortingStrategy: SortingStrategy?, previewSettings: FilePreview.Settings) {
        let viewModel = DirectoryViewModel(directory: directory, sortingStrategy: sortingStrategy, previewSettings: previewSettings)
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(0..<viewModel.files.count, id: \.self) { index in
                let file = viewModel.files[index]
                row(for: file, at: index)
            }
            .onDelete { indexSet in
                Task {
                    await onDelete(indexSet: indexSet)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.reloadFilesIfNeeded()
            }
        }
        .sheet(
            item: $viewModel.presentedFile,
            onDismiss: {
                viewModel.handleDismissSheet()
            },
            content: { file in
                FileView(file: file, previewSettings: viewModel.previewSettings)
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.directory.name)
    }

    func row(for file: any FileRepresentable, at index: Int) -> some View {
        if let directory = file as? Directory {
            let distination = DirectoryView(
                directory: directory,
                sortingStrategy: viewModel.sortingStrategy,
                previewSettings: viewModel.previewSettings
            )
            return AnyView(
                NavigationLink(destination: distination) {
                    HStack {
                        Text(directory.name)
                            .font(.system(.subheadline))
                        Spacer(minLength: 4)
                        Text(file.size)
                            .font(.system(.caption).bold())
                            .foregroundColor(.gray)
                    }
                }
            )
        } else if let file = file as? File {
            return AnyView(
                HStack {
                    Text(file.name)
                        .font(.system(.subheadline))
                    Spacer()
                    Text(file.size)
                        .font(.system(.caption).bold())
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.handleFileTapped(file)
                }
            )
        } else {
            fatalError()
        }
    }

    private func onDelete(indexSet: IndexSet) async {
        let files = indexSet.map { viewModel.files[$0] }
        for file in files {
            await viewModel.deleteFile(file)
        }
    }
}

/// Model of DirectoryView.
@MainActor
private final class DirectoryViewModel: ObservableObject {
    /// Target directory.
    @Published var directory: Directory
    /// Files to display on list.
    @Published var files: [any FileRepresentable] = []
    /// Files to preview.
    @Published var presentedFile: File?

    /// Strategy to sort files contained target directory.
    let sortingStrategy: SortingStrategy?
    /// Settings used to previewing files.
    public let previewSettings: FilePreview.Settings
    /// Cache and sort files to display on list.
    private let contentsProvider: DirectoryContentsProvider

    init(directory: Directory, sortingStrategy: SortingStrategy?, previewSettings: FilePreview.Settings) {
        self.directory = directory
        self.sortingStrategy = sortingStrategy
        self.previewSettings = previewSettings
        self.contentsProvider = DirectoryContentsProvider(directory: directory, sortingStrategy: sortingStrategy)
    }

    /// Reload files using provider if needed.
    func reloadFilesIfNeeded() async {
        files = await contentsProvider.files
    }

    /// Delete file and update list.
    func deleteFile(_ file: any FileRepresentable) async {
        directory.deleteFile(file)
        if let index = files.firstIndex(where: { $0.path == file.path }) {
            files.remove(at: index)
        }
        await contentsProvider.setNeedsReloadFiles(true)
    }

    /// Handle tap on row to preview selected file.
    func handleFileTapped(_ file: File) {
        presentedFile = file
    }

    /// Handle dismissed preview view.
    func handleDismissSheet() {
        presentedFile = nil
    }
}
