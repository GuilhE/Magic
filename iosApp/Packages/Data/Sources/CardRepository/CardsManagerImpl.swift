import DomainModels
import DomainUseCases
import KMPBridge
import MagicDataManagers
import MagicDataModels
import ExportedKotlinPackages

//Until we can use flattenPackage in swiftExport gradle configuration we need this helper class
//https://youtrack.jetbrains.com/issue/KT-81270/K-N-Build-fails-when-exposing-suspend-functions

typealias CardsManager = ExportedKotlinPackages.com.magic.data.managers.CardsManager
typealias Card = ExportedKotlinPackages.com.magic.data.models.local.Card
typealias CardSet = ExportedKotlinPackages.com.magic.data.models.local.CardSet
typealias Result = ExportedKotlinPackages.com.magic.data.models.local.Result

@MainActor
public class CardsManagerImpl: DomainCardsManagerProtocol, @unchecked Sendable {
    private nonisolated(unsafe) let kmpManager: CardsManager

    public init(manager: ExportedKotlinPackages.com.magic.data.managers.CardsManager) {
        kmpManager = manager
    }

    public func getCardSet(setCode: String) async -> Swift.Result<DomainCardList, DomainException> {
        let result = await kmpManager.getSet(setCode: setCode)
        if let successResult = result as? Result.Success, let cards = successResult.data as? [Card]? {
            return .success(DomainCardList(cards: cards!.asDomainCards))
        } else if let errorResult = result as? Result.Error {
            return .failure(DomainException(domainError: errorResult.exception as ErrorException))
        } else {
            return .failure(DomainException(error: UnexpectedResultError()))
        }
    }

    public func getCardSets(setCodes: [String]) async -> Swift.Result<Void, DomainException> {
        let result = await kmpManager.getSets(setCodes: setCodes)
        if result is Result.Success {
            return .success(())
        } else if let errorResult = result as? Result.Error {
            return .failure(DomainException(domainError: errorResult.exception as ErrorException))
        } else {
            return .failure(DomainException(error: UnexpectedResultError()))
        }
    }

    public func getCardSets() -> [DomainCardSet] {
        let apiCardSets = kmpManager.getSets() as [CardSet]
        return apiCardSets.asDomainCardSets
    }

    public func observeCardSets() async throws -> AsyncStream<[DomainCardSet]> {
        return AsyncStream { continuation in
            Task { @MainActor in
                let sets = kmpManager.observeSets.value
                if let cardSets = sets as? [CardSet]? {
                    continuation.yield(cardSets!.asDomainCardSets)
                }
                continuation.finish()
            }
        }
    }

    public func observeSetCount() async throws -> AsyncStream<Int> {
        return AsyncStream { continuation in
            Task { @MainActor in
                let count = kmpManager.observeSetCount.value
                if let setCount = count as? Int? {
                    continuation.yield(setCount!)
                }
                continuation.finish()
            }
        }
    }

    public func observeCardCount() async throws -> AsyncStream<Int> {
        return AsyncStream { continuation in
            Task { @MainActor in
                let count = kmpManager.observeCardCount.value
                if let cardCount = count as? Int? {
                    continuation.yield(cardCount!)
                }
                continuation.finish()
            }
        }
    }

    public func observeCardsFromSet(setCode: String) async throws -> AsyncStream<[DomainCard]> {
        return AsyncStream { continuation in
            Task { @MainActor in
                let setCards = kmpManager.observeCardsFromSet(code: setCode).value
                if let apiCards = setCards as? [Card]? {
                    continuation.yield(apiCards!.asDomainCards)
                }
                continuation.finish()
            }
        }
    }

    public func removeCardSet(setCode: String) {
        kmpManager.removeSet(setCode: setCode)
    }
}
