import SwiftUI

private struct NavigationEnvironmentKey: EnvironmentKey {
    static let defaultValue: (Screen) -> Void = { _ in }
}

extension EnvironmentValues {
    var navigate: (Screen) -> Void {
        get { self[NavigationEnvironmentKey.self] }
        set { self[NavigationEnvironmentKey.self] = newValue }
    }
} 