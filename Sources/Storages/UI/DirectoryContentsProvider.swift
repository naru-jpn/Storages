import Foundation

/// Store files contained in target directory and sort files with applied strategy.
actor DirectoryContentsProvider {
    /// Target directory.
    let directory: Directory
    /// Strategy to sort files.
    let sortingStrategy: SortingStrategy?

    /// References of files contained target directory.
    private var cachedFiles: [any FileRepresentable] = []
    /// Flag that provider should reload cached files or not.
    private var needsReloadFiles = true

    /// Create new provider.
    ///
    /// - Parameters:
    ///   - directory: Target directory.
    ///   - sortingStrategy: Strategy to sort files.
    init(directory: Directory, sortingStrategy: SortingStrategy?) {
        self.directory = directory
        self.sortingStrategy = sortingStrategy
    }

    /// Return files and reload cached files if needed.
    var files: [any FileRepresentable] {
        get async {
            if needsReloadFiles, var files = getCurrentFiles() {
                // Skip sort if strategy is nil.
                if sortingStrategy != nil {
                    files = files.sorted(by: sortFiles(hls:rhs:))
                }
                cachedFiles = files
                needsReloadFiles = false
            }
            return cachedFiles
        }
    }

    /// Set value of needsReloadFiles.
    func setNeedsReloadFiles(_ needsReloadFiles: Bool) async {
        self.needsReloadFiles = needsReloadFiles
    }

    /// Get all files and clild directories contains in target directory.
    private func getCurrentFiles() -> [any FileRepresentable]? {
        typealias FileInformation = (name: String, path: String)

        guard let names = try? FileManager.default.contentsOfDirectory(atPath: directory.path) else {
            return nil
        }
        let fileInformations: [FileInformation] = names.map {
            (name: $0, path: directory.path + "/" + $0)
        }
        let files: [any FileRepresentable] = fileInformations.compactMap { info -> (any FileRepresentable)? in
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: info.path, isDirectory: &isDirectory)
            guard exists else {
                return nil
            }
            return isDirectory.boolValue
                ? Directory(name: info.name, path: info.path, parent: directory)
                : File(name: info.name, path: info.path, parent: directory)
        }
        return files
    }

    /// Sorting procedure using applied strategy.
    private func sortFiles(hls: any FileRepresentable, rhs: any FileRepresentable) -> Bool {
        guard let sortingStrategy = sortingStrategy else { return true }

        if sortingStrategy.isDirectoryFirst && hls is Directory != rhs is Directory {
            return hls is Directory
        }
        switch sortingStrategy.categorySorting {
        case .alphabet:
            return hls.name < rhs.name
        case .fileSize:
            return hls.byteCount > rhs.byteCount
        }
    }
}
