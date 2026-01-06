import SwiftUI

struct CardDeckView<CardView: CardViewProtocol>: View {
    @State private var activeCard: CardView.CardType? = nil
    @State private var touchedCard: CardView.CardType? = nil
    @State private var showBack = false
    @State private var addedToDeck = true
    @State private var removedFromDeck = false
    @State private var dragOffset: CGSize = .zero
    @State private var dragging: Bool = false
    @State private var zoomScale: CGFloat = 1.0
    @State private var zooming: Bool = false

    let cardSize: CGSize
    @Binding var deck: [CardView.CardType]
    @Binding var add: Bool
    @Binding var remove: Bool
    @Binding var shuffle: Bool
    @Binding var delete: Bool
    let onAdded: () -> Void
    let onRemoved: () -> Void
    let onShuffled: () -> Void
    let onDeleted: () -> Void

    private var enumeratedCards: [(offset: Int, element: CardView.CardType)] {
        let cards = fromBottomToTop() ? deck.reversed() : deck
        return Array(cards.enumerated())
    }

    var body: some View {
        ZStack {
            ForEach(enumeratedCards, id: \.element.id) { index, card in
                cardView(for: card, at: index)
            }
        }
        .onChange(of: add) { _, newValue in if newValue { animateAddToDeck() } }
        .onChange(of: remove) { _, newValue in if newValue { animateRemoveFromDeck() } }
        .onChange(of: shuffle) { _, newValue in if newValue { animateShuffleDeck() } }
        .onChange(of: delete) { _, newValue in if newValue { animateDeleteDeck() } }
    }

    @ViewBuilder
    private func cardView(for card: CardView.CardType, at index: Int) -> some View {
        let baseCard = CardView(card: card, showBack: showBack && index == 0, size: cardSize)
        let scaledCard = baseCard.scaleEffect(cardScale(for: card))
        let animatedCard = scaledCard.animation(.spring(response: 0.3, dampingFraction: 0.7), value: zoomScale)
        let modifiedCard = animatedCard.modifier(cardModifier(for: card, at: index))

        modifiedCard
            .gesture(dragGesture(for: card))
            .gesture(magnificationGesture(for: card))
            .onTapGesture { handleTap(for: card, at: index) }
    }

    private func cardScale(for card: CardView.CardType) -> CGFloat {
        card == touchedCard ? zoomScale : 1.0
    }

    private func cardModifier(for card: CardView.CardType, at index: Int) -> CardViewModifier<CardView.CardType> {
        CardViewModifier(
            card: card,
            isTouchedCard: card == touchedCard,
            isActiveCard: card == activeCard,
            index: index,
            showBack: showBack,
            added: addedToDeck,
            removed: removedFromDeck,
            dragOffset: dragOffset,
            deckCount: deck.count
        )
    }

    private func dragGesture(for card: CardView.CardType) -> some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in handleDragChanged(value: value, card: card) }
            .onEnded { value in handleDragEndedGesture(value: value, card: card) }
    }

    private func magnificationGesture(for card: CardView.CardType) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in handleMagnificationChanged(value: value, card: card) }
            .onEnded { _ in handleMagnificationEnded() }
    }

    private func handleDragChanged(value: DragGesture.Value, card: CardView.CardType) {
        guard !shuffle, !zooming else { return }
        guard card == deck.first else { return }

        activeCard = card
        let clampedWidth = max(min(value.translation.width, cardSize.width), -cardSize.width)
        let clampedHeight = max(min(value.translation.height, cardSize.height), -cardSize.height)
        dragOffset = CGSize(width: clampedWidth, height: clampedHeight)
    }

    private func handleDragEndedGesture(value: DragGesture.Value, card: CardView.CardType) {
        touchedCard = nil
        if card == deck.first {
            handleDragEnded(value: value)
        }
    }

    private func handleMagnificationChanged(value: CGFloat, card: CardView.CardType) {
        guard !shuffle, !dragging, card == touchedCard else { return }

        zooming = true
        zoomScale = min(max(value, 1.2), 3.0)
    }

    private func handleMagnificationEnded() {
        zooming = false
        guard !dragging else { return }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            zoomScale = 1.2
        }
    }

    private func handleTap(for card: CardView.CardType, at index: Int) {
        guard !shuffle else { return }

        let isTopCard = fromBottomToTop() ? index == deck.count - 1 : index == 0
        if touchedCard == nil, isTopCard {
            touchedCard = card
            zoomScale = 1.2
        } else {
            withAnimation {
                touchedCard = nil
                zoomScale = 1.0
            }
        }
    }

    private func handleDragEnded(value: DragGesture.Value) {
        let thresholdX = cardSize.width * 2 / 3
        let thresholdY = cardSize.height * 1 / 2
        let xMoved = abs(value.translation.width)
        let yMoved = abs(value.translation.height)
        let moveToBack = xMoved > thresholdX || yMoved > thresholdY

        withAnimation {
            if moveToBack {
                let topCardIndex = deck.indices.last
                let topCardPosition = deck.count > 1 ? CGSize(
                    width: CGFloat(topCardIndex ?? 0) * 10,
                    height: CGFloat(topCardIndex ?? 0) * 10
                ) : .zero

                let overlapOffset = CGSize(
                    width: max(0, (cardSize.width / 2) - (value.translation.width - topCardPosition.width)),
                    height: max(0, (cardSize.height / 2) - (value.translation.height - topCardPosition.height))
                )

                dragOffset = CGSize(
                    width: value.translation.width + overlapOffset.width,
                    height: value.translation.height + overlapOffset.height
                )

                moveCardToBack()
            } else {
                moveCardToFront()
            }
        }
        activeCard = nil
    }

    private func moveCardToFront() {
        guard !deck.isEmpty else { return }
        let card = deck.removeFirst()
        deck.insert(card, at: 0)
    }

    private func moveCardToBack() {
        guard !deck.isEmpty else { return }
        let card = deck.removeFirst()
        deck.append(card)
    }

    private func animateAddToDeck() {
        addedToDeck = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.13 * Double(deck.count)) {
            onAdded()
        }
    }

    private func animateRemoveFromDeck() {
        addedToDeck = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.13 * Double(deck.count)) {
            onRemoved()
        }
    }

    private func animateShuffleDeck() {
        withAnimation {
            showBack = true
            touchedCard = nil
            activeCard = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                deck.shuffle()
                withAnimation {
                    showBack = false
                    onShuffled()
                }
            }
        }
    }

    private func animateDeleteDeck() {
        removedFromDeck = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.13 * Double(deck.count)) {
            addedToDeck = true // to reset addedToDeck animation for fromBottomToTop()
            removedFromDeck = false
            onDeleted()
        }
    }

    private func fromBottomToTop() -> Bool { !showBack && (removedFromDeck || !addedToDeck) }
}
