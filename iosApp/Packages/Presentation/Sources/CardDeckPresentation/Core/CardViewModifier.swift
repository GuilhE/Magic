import SwiftUI

struct CardViewModifier<CardType>: ViewModifier where CardType: CardProtocol {
    let card: CardType
    let isTouchedCard: Bool
    let isActiveCard: Bool
    let index: Int
    let showBack: Bool
    let added: Bool
    let removed: Bool
    let dragOffset: CGSize
    let deckCount: Int

    func body(content: Content) -> some View {
        content
            .scaleEffect(isTouchedCard ? 1.20 : isActiveCard ? 1 : 0.95)
            .zIndex(isActiveCard ? Double(deckCount) : fromBottomToTop() ? Double(deckCount - (deckCount - index - 1)) : Double(deckCount - index))
            .animation(.easeInOut(duration: 0.3), value: isActiveCard || isTouchedCard)
            .animation(.easeIn(duration: 0.3).delay(Double(index) * 0.1), value: removed || added)
            .offset(
                x: added ? -UIScreen.main.bounds.width : isActiveCard ? dragOffset.width : showBack ? 0 : CGFloat(fromBottomToTop() ? deckCount - index - 1 : index) * 10,
                y: removed ? UIScreen.main.bounds.height : isActiveCard ? dragOffset.height : showBack ? 0 : CGFloat(fromBottomToTop() ? deckCount - index - 1 : index) * 10
            )
    }

    private func fromBottomToTop() -> Bool { !showBack && (removed || !added) }
}
