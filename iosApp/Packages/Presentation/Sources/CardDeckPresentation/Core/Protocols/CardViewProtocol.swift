import SwiftUI

public protocol CardViewProtocol: View where CardType: CardProtocol {
    associatedtype CardType
    var card: CardType { get }
    var showBack: Bool { get }
    var size: CGSize { get }

    init(card: CardType, showBack: Bool, size: CGSize)
}
