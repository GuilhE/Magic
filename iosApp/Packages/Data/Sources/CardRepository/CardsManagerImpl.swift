import DomainModels
import DomainUseCases
import ExportedKotlinPackages
import KMPBridge
import MagicDataManagers
import MagicDataModels

public class CardsManagerImpl: DomainCardsManagerProtocol, @unchecked Sendable {
    private let kmpManager: CardsManager

    public init(manager: CardsManager) {
        kmpManager = manager
    }

    public func getCardSet(setCode: String) async -> Swift.Result<DomainCardList, DomainException> {
        let result = await kmpManager.getSet(setCode: setCode)
        if let successResult = result as? local.Result.Success, let cards = successResult.data as? [local.Card]? {
            return .success(DomainCardList(cards: cards!.asDomainCards))
        } else if let errorResult = result as? local.Result.Error {
            return .failure(DomainException(domainError: errorResult.exception as ErrorException))
        } else {
            return .failure(DomainException(error: UnexpectedResultError()))
        }
    }

    public func getCardSets(setCodes: [String]) async -> Swift.Result<Void, DomainException> {
        let result = await kmpManager.getSets(setCodes: setCodes)
        if (result as? local.Result.Success) != nil {
            return .success(())
        } else if let errorResult = result as? local.Result.Error {
            return .failure(DomainException(domainError: errorResult.exception as ErrorException))
        } else {
            return .failure(DomainException(error: UnexpectedResultError()))
        }
    }

    public func getCardSets() -> [DomainCardSet] {
        let apiCardSets = kmpManager.getSets() as [local.CardSet]
        return apiCardSets.asDomainCardSets
    }

    public func observeCardSets() async -> AsyncStream<[DomainCardSet]> {
        AsyncStream { continuation in
            let observation = kmpManager.observeSets { sets in
                continuation.yield(sets.asDomainCardSets)
            }
            continuation.onTermination = { _ in
                observation.cancel()
            }
        }
    }

    public func observeSetCount() async -> AsyncStream<Int> {
        AsyncStream { continuation in
            let observation = kmpManager.observeSetCount { count in
                continuation.yield(Int(count))
            }
            continuation.onTermination = { _ in
                observation.cancel()
            }
        }
    }

    public func observeCardCount() async -> AsyncStream<Int> {
        AsyncStream { continuation in
            let observation = kmpManager.observeCardCount { count in
                continuation.yield(Int(count))
            }
            continuation.onTermination = { _ in
                observation.cancel()
            }
        }
    }

    public func observeCardsFromSet(setCode: String) async -> AsyncStream<[DomainCard]> {
        AsyncStream { continuation in
            let observation = kmpManager.observeCardsFromSet(code: setCode) { cards in
                continuation.yield(cards.asDomainCards)
            }
            continuation.onTermination = { _ in
                observation.cancel()
            }
        }
    }

    public func removeCardSet(setCode: String) {
        kmpManager.removeSet(setCode: setCode)
    }
}
