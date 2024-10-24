import SwiftUI

struct CircularBlueBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 20, height: 20)
            .padding(10)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
    }
}

extension Image {
    func circularBlueBorder() -> some View {
        resizable()
            .scaledToFit()
            .modifier(CircularBlueBorder())
    }
}
