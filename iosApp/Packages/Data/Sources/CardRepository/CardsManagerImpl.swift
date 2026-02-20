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
        do {
            let result = try await kmpManager.getSet(setCode: setCode)
            if let successResult = result as? local.Result.Success, let cards = successResult.data as? [local.Card]? {
                return .success(DomainCardList(cards: cards!.asDomainCards))
            } else if let errorResult = result as? local.Result.Error {
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
            let result = try await kmpManager.getSets(setCodes: setCodes)
            if (result as? local.Result.Success) != nil {
                return .success(())
            } else if let errorResult = result as? local.Result.Error {
                return .failure(DomainException(domainError: errorResult.exception as ErrorException))
            } else {
                return .failure(DomainException(error: UnexpectedResultError()))
            }
        } catch {
            return .failure(DomainException(error: error))
        }
    }

    public func getCardSets() -> [DomainCardSet] {
        let apiCardSets = kmpManager.getSets() as [local.CardSet]
        return apiCardSets.asDomainCardSets
    }

    public func observeCardSets() async -> AsyncStream<[DomainCardSet]> {
        AsyncStream { continuation in
            Task {
                for try await sets in kmpManager.observeSets() {
                    continuation.yield(sets.asDomainCardSets)
                }
                continuation.finish()
            }
        }
    }

    public func observeSetCount() async -> AsyncStream<Int> {
        AsyncStream { continuation in
            Task {
                for try await count in kmpManager.observeSetCount() {
                    continuation.yield(Int(count))
                }
                continuation.finish()
            }
        }
    }

    public func observeCardCount() async -> AsyncStream<Int> {
        AsyncStream { continuation in
            Task {
                for try await count in kmpManager.observeCardCount() {
                    continuation.yield(Int(count))
                }
                continuation.finish()
            }
        }
    }

    public func observeCardsFromSet(setCode: String) async -> AsyncStream<[DomainCard]> {
        AsyncStream { continuation in
            Task {
                for try await cards in kmpManager.observeCardsFromSet(code: setCode) {
                    continuation.yield(cards.asDomainCards)
                }
                continuation.finish()
            }
        }
    }

    public func removeCardSet(setCode: String) {
        kmpManager.removeSet(setCode: setCode)
    }
}
