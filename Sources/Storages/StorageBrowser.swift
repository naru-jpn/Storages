import Foundation
import SwiftUI

/// Browser to browse files in your app container.
public struct StorageBrowser: View {
    /// Root directory to browse files.
    public enum Source {
        /// Home directory got with NSHomeDirectory().
        case home
        /// Cuatom path of root directory.
        ///
        /// - Parameters:
        ///   - path: Path for root directory. (This path doesn't have prefix like `file:///`)
        ///   - name: Name used as navigation title.
        case custom(path: String, name: String)
    }

    /// Settings of browser.
    public struct Settings {
        /// Default settings.
        public static let `default` = Settings(
            sortingStrategy: .init(isDirectoryFirst: true, categorySorting: .fileSize),
            previewSettings: .init(stringEncoding: .utf8, maxStringPreviewLength: 1000)
        )

        /// Strategy to sort files and directories.
        public let sortingStrategy: SortingStrategy?
        /// Settings used to previewing files.
        public let previewSettings: FilePreview.Settings

        public init(sortingStrategy: SortingStrategy?, previewSettings: FilePreview.Settings) {
            self.sortingStrategy = sortingStrategy
            self.previewSettings = previewSettings
        }
    }

    /// Root directory.
    private let root: Directory
    /// Settings of browser.
    private let settings: Settings
    /// Flag to check root directory exists or not.
    private var existsRootDirectory = true

    /// Create new StrageBrowser.
    ///
    /// - Parameters:
    ///   - source: Source representing root directory.
    ///   - settings: Settings of browser.
    public init(
        source: Source,
        settings: Settings = .default
    ) {
        switch source {
        case .home:
            root = HomeDirectory()
        case let .custom(path, name):
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            if !exists || !isDirectory.boolValue {
                self.existsRootDirectory = false
            }
            root = Directory(name: name, path: path, parent: nil)
        }
        self.settings = settings
    }

    public var body: some View {
        NavigationView {
            if existsRootDirectory {
                DirectoryView(
                    directory: root,
                    sortingStrategy: settings.sortingStrategy,
                    previewSettings: settings.previewSettings
                )
            } else {
                RootDirectoryErrorView(path: root.path)
            }
        }
    }
}
