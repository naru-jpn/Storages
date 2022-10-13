import Foundation
import SwiftUI

/// View to diplay informations of target file.
public struct FileView: View {
    /// DateFormatter used to diaplsy information about date.
    private static let dateFormatter = DateFormatter()

    /// Model of view.
    @ObservedObject private var viewModel: FileViewModel

    /// Variable to control share sheet.
    @State private var isShareSheetPresented = false

    /// Create new FileView.
    ///
    /// - Parameters:
    ///   - file: Target file.
    ///   - previewSettings: Settings to preview contents of file.
    public init(file: File, previewSettings: FilePreview.Settings) {
        let viewModel = FileViewModel(file: file, previewSettings: previewSettings)
        self._viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let previewSize: CGFloat = min(geometry.size.width * 0.7, 300)
                VStack(alignment: .center, spacing: 16) {
                    // File Name
                    Text(viewModel.file.name)
                        .font(.system(.subheadline).bold())
                        .foregroundColor(.primary)
                    // Preview
                    FilePreviewView(filePreview: viewModel.filePreview)
                        .frame(width: previewSize, height: previewSize)
                    // Informations
                    VStack(alignment: .leading, spacing: 8) {
                        FileInformationView(title: "Size", value: viewModel.file.size)
                        if let creationDate = viewModel.file.creationDate {
                            FileInformationView(title: "Creation Date", value: FileDateFormatter.shared.format(date: creationDate))
                        }
                        if let modificationDate = viewModel.file.modificationDate {
                            FileInformationView(title: "Modification Date", value: FileDateFormatter.shared.format(date: modificationDate))
                        }
                    }
                    .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                    Spacer()
                }
                .padding(.init(top: 24, leading: 36, bottom: 0, trailing: 36))
                .frame(maxWidth: .infinity)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: {
                                isShareSheetPresented = true
                            },
                            label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        )
                    }
                }
                .sheet(isPresented: $isShareSheetPresented) {
                    ActivityViewController(activityItems: [URL(fileURLWithPath: viewModel.file.path)])
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.createFilePreviewIfNeeded()
            }
        }
    }
}

/// Model of FileView.
@MainActor
private final class FileViewModel: ObservableObject {
    let file: File
    let previewSettings: FilePreview.Settings
    private let filePreviewCreater = FilePreviewCreater()

    public init(file: File, previewSettings: FilePreview.Settings) {
        self.file = file
        self.previewSettings = previewSettings
    }

    @Published var filePreview: FilePreview?

    func createFilePreviewIfNeeded() async {
        guard filePreview == nil else {
            return
        }
        filePreview = await filePreviewCreater.createFilePreview(file, previewSettings: previewSettings)
    }
}

private struct FileInformationView: View {
    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(.subheadline))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(.caption).bold())
                .foregroundColor(.secondary)
        }
    }
}

private struct ActivityViewController: UIViewControllerRepresentable {
    private let activityItems: [Any]

    init(activityItems: [Any]) {
        self.activityItems = activityItems
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        .init(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

private class FileDateFormatter {
    static let shared = FileDateFormatter()

    private let formatter = DateFormatter()

    init() {
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy/M/d HH:mm:ss"
    }

    func format(date: Date) -> String {
        formatter.string(from: date)
    }
}

/// Create FilePreview to display on FilePreviewView.
private actor FilePreviewCreater {
    /// Create FilePreview.
    func createFilePreview(_ file: File, previewSettings: FilePreview.Settings) async -> FilePreview {
        FilePreview(file: file, settings: previewSettings)
    }
}
