import DomainProtocols
import MagicDataLayer

extension KotlinThrowable: @retroactive ErrorException, @unchecked Sendable {}
extension RateLimitException: @retroactive DomainRateLimitException, @unchecked Sendable {}

public extension Card {
    var asDomainCard: DomainCard {
        CardImpl(self)
    }
}

public extension CardSet {
    var asDomainCardSet: DomainCardSet {
        CardSetImpl(self)
    }
}

public extension [Card] {
    var asDomainCards: [DomainCard] {
        map(\.asDomainCard)
    }
}

public extension [CardSet] {
    var asDomainCardSets: [DomainCardSet] {
        map(\.asDomainCardSet)
    }
}

private struct CardImpl: DomainCard, @unchecked Sendable {
    private let apiCard: Card

    public init(_ apiCard: Card) {
        self.apiCard = apiCard
    }

    public var id: String { apiCard.id }
    public var setCode: String { apiCard.setCode }
    public var name: String { apiCard.name }
    public var text: String { apiCard.text }
    public var imageUrl: String { apiCard.imageUrl }
    public var artist: String { apiCard.artist }
}

private struct CardSetImpl: DomainCardSet, @unchecked Sendable {
    private let apiCardSet: CardSet

    public init(_ apiCardSet: CardSet) {
        self.apiCardSet = apiCardSet
    }

    public var code: String { apiCardSet.code }
    public var name: String { apiCardSet.name }
    public var releaseDate: String { apiCardSet.releaseDate }
}
