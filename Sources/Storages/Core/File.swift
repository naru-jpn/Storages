import Foundation

/// Representing a file containing contents of data.
public class File: FileRepresentable {
    /// Name of this file.
    public let name: String
    /// Absolute path of this file.
    public let path: String
    /// Parent directory of this file if exists.
    public let parent: (any FileRepresentable)?
    /// File attributes of this file.
    public let attributes: [FileAttributeKey: Any]?

    /// Return file placed on applied path.
    ///
    /// - Parameters:
    ///   - name: Name of this file.
    ///   - path: Absolute path of this file.
    ///   - parent: Parent directory of this item if exists.
    init(name: String, path: String, parent: (any FileRepresentable)?) {
        self.name = name
        self.path = path
        self.parent = parent
        self.attributes = try? FileManager.default.attributesOfItem(atPath: path)
    }
}

extension File {
    /// Size with bytes of this file.
    public var byteCount: Int64 {
        (attributes?[.size] as? Int64) ?? 0
    }
}
