import DomainModels
import DomainUseCases
import KMPBridge
import MagicDataManagers
import MagicDataModels

public class CardsManagerImpl: DomainCardsManagerProtocol {
    private let kmpManager: CardsManager

    public init(manager: CardsManager) {
        kmpManager = manager
    }

    public func getCardSet(setCode: String) async -> Swift.Result<DomainCardList, DomainException> {
        do {
            let result = try await kmpManager.getSet(setCode: setCode)
            if let successResult = result as? Result<NSArray>, let cards = successResult.data as? [Card] {
                return .success(DomainCardList(cards: cards.asDomainCards))
            } else if let errorResult = result as? ResultError {
                return .failure(DomainException(domainError: errorResult.exception as ErrorException))
            } else {
                return .failure(DomainException(error: UnexpectedResultError()))
            }
        } catch {
            return .failure(DomainException(error: error))
        }
    }

    public func getCardSets(setCodes: [String]) async -> Swift.Result<Void, DomainException> {
        do {
            let result = try await asyncFunction(for: kmpManager.getSets(setCodes: setCodes))
            if result is ResultSuccess<KotlinUnit> {
                return .success(())
            } else if let errorResult = result as? ResultError {
                return .failure(DomainException(domainError: errorResult.exception as ErrorException))
            } else {
                return .failure(DomainException(error: UnexpectedResultError()))
            }
        } catch {
            return .failure(DomainException(error: error))
        }
    }

    public func getCardSets() -> [DomainCardSet] {
        let apiCardSets = kmpManager.getSets() as [CardSet]
        return apiCardSets.asDomainCardSets
    }

    public func observeCardSets() async throws -> AsyncStream<[DomainCardSet]> {
        AsyncStream { continuation in
            Task {
                let stream = asyncSequence(for: kmpManager.observeSetsFlow)
                for try await sets in stream {
                    let apiCardSets = sets as [CardSet]
                    continuation.yield(apiCardSets.asDomainCardSets)
                }
                continuation.finish()
            }
        }
    }

    public func observeSetCount() async throws -> AsyncStream<Int> {
        AsyncStream { continuation in
            Task {
                let stream = asyncSequence(for: kmpManager.observeSetCountFlow)
                for try await count in stream {
                    continuation.yield(count.intValue)
                }
                continuation.finish()
            }
        }
    }

    public func observeCardCount() async throws -> AsyncStream<Int> {
        AsyncStream { continuation in
            Task {
                let stream = asyncSequence(for: kmpManager.observeCardCountFlow)
                for try await count in stream {
                    continuation.yield(count.intValue)
                }
                continuation.finish()
            }
        }
    }

    public func observeCardsFromSet(setCode: String) async throws -> AsyncStream<[DomainCard]> {
        AsyncStream { continuation in
            Task {
                let stream = asyncSequence(for: kmpManager.observeCardsFromSet(code: setCode))
                for try await cards in stream {
                    let apiCards = cards as [Card]
                    continuation.yield(apiCards.asDomainCards)
                }
                continuation.finish()
            }
        }
    }

    public func removeCardSet(setCode: String) {
        kmpManager.removeSet(setCode: setCode)
    }
}
