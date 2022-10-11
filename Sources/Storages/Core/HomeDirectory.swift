import Foundation

/// Home directory with path from NSHomeDirectory().
public final class HomeDirectory: Directory {
    public init() {
        super.init(name: "Home", path: NSHomeDirectory(), parent: nil)
    }
}
