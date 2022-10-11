import MetalKit
import SwiftUI

/// View to preview contents of target file.
public struct FilePreviewView: View {
    /// Informaion to preview contents of file.
    public var filePreview: FilePreview?

    public var body: some View {
        content(for: filePreview)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
            )
    }

    private func content(for preview: FilePreview?) -> some View {
        guard let preview else {
            return AnyView(
                Text("Preparing....")
                    .font(.system(.footnote))
            )
        }
        switch preview {
        case let .png(data):
            guard let image = UIImage(data: data) else {
                break
            }
            return AnyView(
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            )
        case let .jpeg(data):
            guard let image = UIImage(data: data) else {
                break
            }
            return AnyView(
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            )
        case let .webp(url):
            return AnyView(
                WebView(fileUrl: url)
            )
        case let .ktx(url):
            // Performance is not critical here so create objects related Metal Framework every time.
            guard let device = MTLCreateSystemDefaultDevice() else {
                break
            }
            guard let texture = try? MTKTextureLoader(device: device).newTexture(URL: url) else {
                break
            }
            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: CGFloat(texture.height))
            guard let ciimage = CIImage(mtlTexture: texture)?.transformed(by: transform) else {
                break
            }
            guard let uiimage = CIContext().createCGImage(ciimage, from: ciimage.extent).map(UIImage.init(cgImage:)) else {
                break
            }
            return AnyView(
                Image(uiImage: uiimage)
                    .resizable()
                    .scaledToFit()
            )
        case let .text(string):
            return AnyView(
                ScrollView(.vertical) {
                    Text(string)
                        .font(.system(.footnote))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        default:
            break
        }
        return AnyView(
            Image(systemName: "questionmark.folder")
        )
    }
}
