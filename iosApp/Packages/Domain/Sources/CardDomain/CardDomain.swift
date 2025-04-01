import DomainProtocols

@MainActor
public protocol DomainCardsManagerProtocol {
    func getCardSet(setCode: String) async -> Result<DomainCardList, DomainException>
    func getCardSets(setCodes: [String]) async -> Result<Void, DomainException>
    func getCardSets() -> [DomainCardSet]
    func observeCardSets() async throws -> AsyncStream<[DomainCardSet]>
    func observeSetCount() async throws -> AsyncStream<Int>
    func observeCardCount() async throws -> AsyncStream<Int>
    func observeCardsFromSet(setCode: String) async throws -> AsyncStream<[DomainCard]>
    func removeCardSet(setCode: String)
}
