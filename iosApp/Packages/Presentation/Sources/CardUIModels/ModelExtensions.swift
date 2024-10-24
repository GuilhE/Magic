import DomainProtocols

public extension DomainCardSet {
    func toCardSetItem() -> CardSetItem {
        return CardSetItem(
            code: code,
            name: name,
            releaseDate: releaseDate
        )
    }
}
