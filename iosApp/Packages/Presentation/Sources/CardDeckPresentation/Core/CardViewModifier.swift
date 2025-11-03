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

    private var screenWidth: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 0
    }

    private var screenHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.height ?? 0
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isTouchedCard ? 1.20 : isActiveCard ? 1 : 0.95)
            .zIndex(isActiveCard ? Double(deckCount) : fromBottomToTop() ? Double(deckCount - (deckCount - index - 1)) : Double(deckCount - index))
            .animation(.easeInOut(duration: 0.3), value: isActiveCard || isTouchedCard)
            .animation(.easeIn(duration: 0.3).delay(Double(index) * 0.1), value: removed || added)
            .offset(
                x: added ? -screenWidth : isActiveCard ? dragOffset.width : showBack ? 0 : CGFloat(fromBottomToTop() ? deckCount - index - 1 : index) * 10,
                y: removed ? screenHeight : isActiveCard ? dragOffset.height : showBack ? 0 : CGFloat(fromBottomToTop() ? deckCount - index - 1 : index) * 10
            )
    }

    private func fromBottomToTop() -> Bool { !showBack && (removed || !added) }
}
