import Foundation

/// Informaion to preview contents of file.
public enum FilePreview {
    /// png image.
    case png(Data)
    /// jpeg, jpg image.
    case jpeg(Data)
    /// webp image.
    case webp(URL)
    /// ktx image.
    case ktx(URL)
    /// plist with dictionary representation.
    case plist([String: Any])
    /// text encoded by stringEncoding of settings.
    case text(String)
    /// can't preview.
    case unknown

    /// Settings to preview contents of file.
    public struct Settings {
        public let stringEncoding: String.Encoding
        public let maxStringPreviewLength: Int

        public init(stringEncoding: String.Encoding, maxStringPreviewLength: Int) {
            self.stringEncoding = stringEncoding
            self.maxStringPreviewLength = maxStringPreviewLength
        }
    }

    /// Create new FilePreview.
    ///
    /// - Parameters:
    ///   - file: File to preview.
    ///   - settings: Settings to preview contents of file.
    public init(file: File, settings: Settings) {
        guard let fileExtension = file.name.components(separatedBy: ".").last else {
            self = .unknown
            return
        }
        switch fileExtension.lowercased() {
        case "png":
            if let data = try? Data(contentsOf: URL(fileURLWithPath: file.path)) {
                self = .png(data)
                return
            }
        case "jpg", "jpeg":
            if let data = try? Data(contentsOf: URL(fileURLWithPath: file.path)) {
                self = .jpeg(data)
                return
            }
        case "webp":
            self = .webp(URL(fileURLWithPath: file.path).standardizedFileURL)
            return
        case "ktx":
            self = .ktx(URL(fileURLWithPath: file.path).standardizedFileURL)
            return
        case "plist":
            if let data = try? Data(contentsOf: URL(fileURLWithPath: file.path)) {
                let availableFormats: [PropertyListSerialization.PropertyListFormat] = [.xml, .binary]
                for format in availableFormats {
                    var format = format
                    if let plist = try? PropertyListSerialization.propertyList(from: data, format: &format) as? [String: Any] {
                        self = .plist(plist)
                        return
                    }
                }
            }
        default:
            if let data = try? Data(contentsOf: URL(fileURLWithPath: file.path)),
               let string = String(data: data, encoding: settings.stringEncoding) {
                if string.count > settings.maxStringPreviewLength {
                    self = .text(string.prefix(settings.maxStringPreviewLength) + "...")
                } else {
                    self = .text(string)
                }
                return
            }
        }
        self = .unknown
    }
}
