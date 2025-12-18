import DomainModels
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

    init(_ apiCard: Card) {
        self.apiCard = apiCard
    }

    var id: String { apiCard.id }
    var setCode: String { apiCard.setCode }
    var name: String { apiCard.name }
    var text: String { apiCard.text }
    var imageUrl: String { apiCard.imageUrl }
    var artist: String { apiCard.artist }
}

private struct CardSetImpl: DomainCardSet, @unchecked Sendable {
    private let apiCardSet: CardSet

    init(_ apiCardSet: CardSet) {
        self.apiCardSet = apiCardSet
    }

    var code: String { apiCardSet.code }
    var name: String { apiCardSet.name }
    var releaseDate: String { apiCardSet.releaseDate }
}
