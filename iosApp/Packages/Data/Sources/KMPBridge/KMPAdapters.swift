import DomainModels
import ExportedKotlinPackages
import MagicDataManagers
import MagicDataModels

extension kotlin.Throwable: @retroactive ErrorException, @unchecked Sendable {}
extension Observation: @retroactive @unchecked Sendable {}
extension exceptions.RateLimitException: @retroactive DomainRateLimitException, @unchecked Sendable {}

public extension local.Card {
    var asDomainCard: DomainCard {
        CardImpl(self)
    }
}

public extension local.CardSet {
    var asDomainCardSet: DomainCardSet {
        CardSetImpl(self)
    }
}

public extension [local.Card] {
    var asDomainCards: [DomainCard] {
        map(\.asDomainCard)
    }
}

public extension [local.CardSet] {
    var asDomainCardSets: [DomainCardSet] {
        map(\.asDomainCardSet)
    }
}

private struct CardImpl: DomainCard, @unchecked Sendable {
    private let apiCard: local.Card

    init(_ apiCard: local.Card) {
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
    private let apiCardSet: local.CardSet

    init(_ apiCardSet: local.CardSet) {
        self.apiCardSet = apiCardSet
    }

    var code: String { apiCardSet.code }
    var name: String { apiCardSet.name }
    var releaseDate: String { apiCardSet.releaseDate }
}
