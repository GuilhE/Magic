import DomainModels

public protocol DomainCardsManagerProtocol {
    func getCardSet(setCode: String) async -> Result<DomainCardList, DomainException>
    func getCardSets(setCodes: [String]) async -> Result<Void, DomainException>
    func getCardSets() -> [DomainCardSet]
    func observeCardSets() async -> AsyncStream<[DomainCardSet]>
    func observeSetCount() async -> AsyncStream<Int>
    func observeCardCount() async -> AsyncStream<Int>
    func observeCardsFromSet(setCode: String) async -> AsyncStream<[DomainCard]>
    func removeCardSet(setCode: String)
}
