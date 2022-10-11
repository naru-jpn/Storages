import SwiftUI

/// View to display when root directory does not found.
struct RootDirectoryErrorView: View {
    private let path: String

    init(path: String) {
        self.path = path
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 12) {
                Text("Failed to open root directory ;(")
                    .font(.system(.title3).bold())
                    .foregroundColor(.primary)
                Text(path)
                    .font(.system(.body))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Error")
    }
}
