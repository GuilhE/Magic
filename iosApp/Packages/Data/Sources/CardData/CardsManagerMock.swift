import CardDomain
import DomainProtocols
import MagicDataLayer

public class CardsManagerMock: DomainCardsManagerProtocol {
    private var mockCardSets: [CardSet: [Card]] = [:]
    private var setCountContinuation: AsyncStream<Int>.Continuation?
    private var cardCountContinuation: AsyncStream<Int>.Continuation?
    private var cardsContinuations: [String: AsyncStream<[DomainCard]>.Continuation] = [:]

    public init() {
        mockCardSets[CardSet(code: "AAA", name: "Set AAA", releaseDate: "2024-01-01")] = createCards("AAA")
        mockCardSets[CardSet(code: "BBB", name: "Set BBB", releaseDate: "2024-02-01")] = createCards("BBB")
        mockCardSets[CardSet(code: "CCC", name: "Set CCC", releaseDate: "2024-03-01")] = createCards("CCC")
    }

    public func getCardSet(setCode: String) async -> Swift.Result<DomainCardList, DomainException> {
        if var cards = mockCardSets.first(where: { $0.key.code == setCode })?.value {
            if cards.isEmpty {
                let set = mockCardSets.first(where: { $0.key.code == setCode })!.key
                cards = createCards(setCode)
                mockCardSets[set] = cards
            }
            await emitCardsUpdate(for: setCode, cards: cards)
            await emitCountsUpdate(delay: 0)
            return .success(DomainCardList(cards: cards as [DomainCard]))
        } else {
            return .failure(DomainException(error: NSError(domain: "Set not found", code: 404, userInfo: nil)))
        }
    }

    public func getCardSets(setCodes _: [String]) async -> Swift.Result<Void, DomainException> {
        .success(())
    }

    public func getCardSets() -> [DomainCardSet] {
        mockCardSets.map(\.key) as! [DomainCardSet]
    }

    public func observeCardSets() async throws -> AsyncStream<[DomainCardSet]> {
        AsyncStream { continuation in
            continuation.yield(mockCardSets.keys.map { set in set } as [DomainCardSet])
        }
    }

    public func observeSetCount() async throws -> AsyncStream<Int> {
        AsyncStream { continuation in
            setCountContinuation = continuation
            continuation.yield(mockCardSets.count)
        }
    }

    public func observeCardCount() async throws -> AsyncStream<Int> {
        AsyncStream { continuation in
            cardCountContinuation = continuation
            continuation.yield(mockCardSets.flatMap(\.value).count)
        }
    }

    public func observeCardsFromSet(setCode: String) async throws -> AsyncStream<[DomainCard]> {
        AsyncStream { continuation in
            cardsContinuations[setCode] = continuation
            if let cards = mockCardSets.first(where: { $0.key.code == setCode })?.value {
                continuation.yield(cards as [DomainCard])
            } else {
                continuation.yield([])
            }
        }
    }

    public func removeCardSet(setCode: String) {
        if let set = mockCardSets.first(where: { $0.key.code == setCode }) {
            mockCardSets[set.key] = []
            Task {
                await emitCardsUpdate(for: setCode, cards: [])
            }
        } else {
            return
        }
        Task {
            await emitCountsUpdate(delay: 0)
        }
    }

    private func createCards(_ setCode: String) -> [Card] {
        var cards: [Card] = []
        for _ in 1 ... 30 {
            let card = Card(
                id: UUID().uuidString,
                setCode: setCode,
                name: generateRandomName(length: 8),
                text: "",
                imageUrl: "",
                artist: ""
            )
            cards.append(card)
        }
        return cards
    }

    private func generateRandomName(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }

    private func emitCountsUpdate(delay: UInt64 = 500_000_000) async {
        try? await Task.sleep(nanoseconds: delay)
        setCountContinuation?.yield(mockCardSets.count)
        cardCountContinuation?.yield(mockCardSets.flatMap(\.value).count)

        for (setCode, continuation) in cardsContinuations {
            if let cards = mockCardSets.first(where: { $0.key.code == setCode })?.value {
                continuation.yield(cards as [DomainCard])
            } else {
                continuation.yield([])
            }
        }
    }

    private func emitCardsUpdate(delay: UInt64 = 500_000_000, for setCode: String, cards: [DomainCard]) async {
        try? await Task.sleep(nanoseconds: delay)
        if let continuation = cardsContinuations[setCode] {
            continuation.yield(cards as [DomainCard])
        }
    }
}
