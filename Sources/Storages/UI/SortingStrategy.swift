import Foundation

/// Strategy to sort files contained target directory.
public struct SortingStrategy {
    /// Sorting rule of each category.
    public enum CategorySorting {
        case alphabet, fileSize
    }

    /// Prioritize directory or not.
    public let isDirectoryFirst: Bool
    /// Sorting rule of each category.
    public let categorySorting: CategorySorting

    /// Create new SortingStrategy.
    ///
    /// - Parameters:
    ///   - isDirectoryFirst: Prioritize directory or not.
    ///   - categorySorting: Sorting rule of each category.
    public init(isDirectoryFirst: Bool, categorySorting: CategorySorting) {
        self.isDirectoryFirst = isDirectoryFirst
        self.categorySorting = categorySorting
    }
}
