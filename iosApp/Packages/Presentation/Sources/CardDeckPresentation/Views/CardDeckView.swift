import SwiftUI

struct CardDeckView<CardView: CardViewProtocol>: View {
    @State private var activeCard: CardView.CardType? = nil
    @State private var touchedCard: CardView.CardType? = nil
    @State private var showBack = false
    @State private var addedToDeck = true
    @State private var removedFromDeck = false
    @State private var dragOffset: CGSize = .zero

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

    var body: some View {
        ZStack {
            ForEach(Array(fromBottomToTop() ? deck.reversed().enumerated() : deck.enumerated()), id: \.element.id) { index, card in
                CardView(card: card, showBack: showBack && index == 0, size: cardSize)
                    .modifier(CardViewModifier(
                        card: card,
                        isTouchedCard: card == touchedCard,
                        isActiveCard: card == activeCard,
                        index: index,
                        showBack: showBack,
                        added: addedToDeck,
                        removed: removedFromDeck,
                        dragOffset: dragOffset,
                        deckCount: deck.count
                    ))
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onChanged { value in
                                if !shuffle {
                                    if card == deck.first {
                                        activeCard = card
                                        dragOffset = CGSize(
                                            width: max(min(value.translation.width, cardSize.width), -cardSize.width),
                                            height: max(min(value.translation.height, cardSize.height), -cardSize.height)
                                        )
                                    }
                                }
                            }
                            .onEnded { value in
                                touchedCard = nil
                                if card == deck.first {
                                    handleDragEnded(value: value)
                                }
                            }
                    )
                    .onTapGesture {
                        if !shuffle {
                            if touchedCard == nil, fromBottomToTop() ? index == deck.count - 1 : index == 0 {
                                touchedCard = card
                            } else {
                                touchedCard = nil
                            }
                        }
                    }
            }
        }
        .onChange(of: add) { _, newValue in
            if newValue {
                animateAddToDeck()
            }
        }
        .onChange(of: remove) { _, newValue in
            if newValue {
                animateRemoveFromDeck()
            }
        }
        .onChange(of: shuffle) { _, newValue in
            if newValue {
                animateShuffleDeck()
            }
        }
        .onChange(of: delete) { _, newValue in
            if newValue {
                animateDeleteDeck()
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
