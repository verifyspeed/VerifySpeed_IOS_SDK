import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    let error: String?
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content.alert(
            "Error",
            isPresented: .init(
                get: { error != nil },
                set: { if !$0 { onDismiss() } }
            ),
            actions: { Button("OK", role: .cancel) { } },
            message: { Text(error ?? "Verification failed") }
        )
    }
}

extension View {
    func errorAlert(error: String?, onDismiss: @escaping () -> Void) -> some View {
        modifier(ErrorAlertModifier(error: error, onDismiss: onDismiss))
    }
} 