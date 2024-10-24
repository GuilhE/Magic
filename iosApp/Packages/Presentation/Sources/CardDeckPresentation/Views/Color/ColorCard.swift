import SwiftUI

public struct ColorCard: CardProtocol {
    public let id = UUID()
    let color: Color
    let number: Int

    public init(color: Color, number: Int) {
        self.color = color
        self.number = number
    }
}
