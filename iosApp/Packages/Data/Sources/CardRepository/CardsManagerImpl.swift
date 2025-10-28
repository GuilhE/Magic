import DomainModels
import DomainUseCases
import ExportedKotlinPackages
import KMPBridge
import MagicDataManagers
import MagicDataModels

// Until we can use flattenPackage in swiftExport gradle configuration we need this helper class
// https://youtrack.jetbrains.com/issue/KT-81270/K-N-Build-fails-when-exposing-suspend-functions
typealias CardsManager = ExportedKotlinPackages.com.magic.data.managers.CardsManager
typealias Card = ExportedKotlinPackages.com.magic.data.models.local.Card
typealias CardSet = ExportedKotlinPackages.com.magic.data.models.local.CardSet
typealias Success = ExportedKotlinPackages.com.magic.data.models.local.Result.Success
typealias Error = ExportedKotlinPackages.com.magic.data.models.local.Result.Error

public class CardsManagerImpl: DomainCardsManagerProtocol, @unchecked Sendable {
    private let kmpManager: CardsManager

    public init(manager: ExportedKotlinPackages.com.magic.data.managers.CardsManager) {
        kmpManager = manager
    }

    public func getCardSet(setCode: String) async -> Swift.Result<DomainCardList, DomainException> {
        let result = await kmpManager.getSet(setCode: setCode)
        if let successResult = result as? Success, let cards = successResult.data as? [Card]? {
            return .success(DomainCardList(cards: cards!.asDomainCards))
        } else if let errorResult = result as? Error {
            return .failure(DomainException(domainError: errorResult.exception as ErrorException))
        } else {
            return .failure(DomainException(error: UnexpectedResultError()))
        }
    }

    public func getCardSets(setCodes: [String]) async -> Swift.Result<Void, DomainException> {
        let result = await kmpManager.getSets(setCodes: setCodes)
        if (result as? Success) != nil {
            return .success(())
        } else if let errorResult = result as? Error {
            return .failure(DomainException(domainError: errorResult.exception as ErrorException))
        } else {
            return .failure(DomainException(error: UnexpectedResultError()))
        }
    }

    public func getCardSets() -> [DomainCardSet] {
        let apiCardSets = kmpManager.getSets() as [CardSet]
        return apiCardSets.asDomainCardSets
    }

    public func observeCardSets() async -> AsyncStream<[DomainCardSet]> {
        return AsyncStream { continuation in
            let observation = kmpManager.observeSets { sets in
                continuation.yield(sets.asDomainCardSets)
            }
            continuation.onTermination = { _ in
                observation.cancel()
            }
        }
    }

    public func observeSetCount() async -> AsyncStream<Int> {
        return AsyncStream { continuation in
            let observation = kmpManager.observeSetCount { count in
                continuation.yield(Int(count))
            }
            continuation.onTermination = { _ in
                observation.cancel()
            }
        }
    }

    public func observeCardCount() async -> AsyncStream<Int> {
        return AsyncStream { continuation in
            let observation = kmpManager.observeCardCount { count in
                continuation.yield(Int(count))
            }
            continuation.onTermination = { _ in
                observation.cancel()
            }
        }
    }

    public func observeCardsFromSet(setCode: String) async -> AsyncStream<[DomainCard]> {
        return AsyncStream { continuation in
            let observation = kmpManager.observeCardFromSet(code: setCode) { cards in
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
