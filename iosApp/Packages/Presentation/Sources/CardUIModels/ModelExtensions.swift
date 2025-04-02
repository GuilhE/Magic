import DomainProtocols

public extension DomainCardSet {
    func toCardSetItem() -> CardSetItem {
        CardSetItem(
            code: code,
            name: name,
            releaseDate: releaseDate
        )
    }
}
