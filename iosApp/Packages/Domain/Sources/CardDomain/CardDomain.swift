import DomainProtocols

@MainActor
public protocol DomainCardsManagerProtocol {
    func getCardSet(setCode: String) async -> Result<DomainCardList, DomainException>
    func getCardSets(setCodes: [String]) async -> Result<Void, DomainException>
    func getCardSets() -> [any DomainCardSet]
    func observeCardSets() async throws -> AsyncStream<[any DomainCardSet]>
    func observeSetCount() async throws -> AsyncStream<Int>
    func observeCardCount() async throws -> AsyncStream<Int>
    func observeCardsFromSet(setCode: String) async throws -> AsyncStream<[any DomainCard]>
    func removeCardSet(setCode: String)
}
