import Foundation

/// Representing directory.
public class Directory: FileRepresentable {
    /// Name of this directory.
    public let name: String
    /// Absolute path of this directory.
    public let path: String
    /// Parent directory of this directory if exists.
    public let parent: (any FileRepresentable)?
    /// File attributes of this directory.
    public let attributes: [FileAttributeKey: Any]?

    /// Return files contained in this directory.
    public var files: [any FileRepresentable] {
        getFiles()
    }

    /// Return directory placed on applied path.
    ///
    /// - Parameters:
    ///   - name: Name of this directory.
    ///   - path: Absolute path of this directory.
    ///   - parent: Parent directory of this item if exists.
    init(name: String, path: String, parent: (any FileRepresentable)?) {
        self.name = name
        self.path = path
        self.parent = parent
        self.attributes = try? FileManager.default.attributesOfItem(atPath: path)
    }

    /// Return files contained in this directory.
    public func getFiles() -> [any FileRepresentable] {
        typealias FileInformation = (name: String, path: String)

        guard let names = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return []
        }
        let fileInformations: [FileInformation] = names.map {
            (name: $0, path: self.path + "/" + $0)
        }
        let files: [any FileRepresentable] = fileInformations.compactMap { info -> (any FileRepresentable)? in
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: info.path, isDirectory: &isDirectory)
            guard exists else {
                return nil
            }
            return isDirectory.boolValue
                ? Directory(name: info.name, path: info.path, parent: self)
                : File(name: info.name, path: info.path, parent: self)
        }
        return files
    }

    /// Delete file and set needsReloadFiles to true.
    @discardableResult
    public func deleteFile(_ file: any FileRepresentable) -> Bool {
        guard files.contains(where: { $0.path == file.path }) else {
            return false
        }
        do {
            try FileManager.default.removeItem(atPath: file.path)
            return true
        } catch {
            return false
        }
    }
}

extension Directory {
    /// Return total size of all files contained in this directory with bytes.
    ///
    /// Each size of file is calculated using `totalFileAllocatedSize` or `fileAllocatedSize`.
    public var byteCount: Int64 {
        getByteCountRecursive(in: path)
    }

    /// Return total size of all files contained in this directory with bytes.
    ///
    /// Each size of file is calculated using `totalFileAllocatedSize` or `fileAllocatedSize`.
    private func getByteCountRecursive(in path: String) -> Int64 {
        let keys: [URLResourceKey] = [.isRegularFileKey, .fileAllocatedSizeKey, .totalFileAllocatedSizeKey]
        let url = URL(fileURLWithPath: path)

        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys, options: [], errorHandler: nil) else {
            return 0
        }
        var count: Int64 = 0
        for item in enumerator {
            guard let url = item as? URL else { continue }
            guard let resourceValues = try? url.resourceValues(forKeys: Set(keys)) else { continue }
            let isRegularFile = resourceValues.isRegularFile ?? false
            if isRegularFile {
                count += Int64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
            } else {
                count += getByteCountRecursive(in: url.absoluteString)
            }
        }
        return count
    }
}

extension Directory: CustomDebugStringConvertible {
    public var debugDescription: String {
        "<Directory: \(Unmanaged.passUnretained(self).toOpaque()); name = \(name); parent = \(parent?.name ?? "nil")>"
    }
}
