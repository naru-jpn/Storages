import Foundation

/// Protocol prepresenting a file.
public protocol FileRepresentable: AnyObject, Identifiable, Equatable {
    /// Name of this item.
    var name: String { get }
    /// Absolute path of this item.
    var path: String { get }
    /// Parent directory of this item if exists.
    var parent: (any FileRepresentable)? { get }
    /// Attributes directory of this item.
    var attributes: [FileAttributeKey: Any]? { get }
    /// Size with bytes of this item.
    var byteCount: Int64 { get }
}

extension FileRepresentable {
    /// File is identified by absolute path.
    public var id: String { path }
}

extension FileRepresentable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.path == rhs.path
    }
}

extension FileRepresentable {
    /// Return string representing size of this item formatted by ByteCountFormatter.
    public var size: String {
        ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file)
    }

    /// Return created date of this item.
    public var creationDate: Date? {
        attributes?[.creationDate] as? Date
    }

    /// Return latest modified date of this item.
    public var modificationDate: Date? {
        attributes?[.modificationDate] as? Date
    }
}
