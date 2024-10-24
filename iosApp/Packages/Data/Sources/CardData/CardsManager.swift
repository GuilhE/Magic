import CardDomain
import DataExtensions
import DomainProtocols
import KMPNativeCoroutinesAsync
import MagicDataLayer

extension CardsManager: @retroactive DomainCardsManagerProtocol {
    public func getCardSet(setCode: String) async -> Swift.Result<DomainCardList, DomainException> {
        do {
            let result = try await asyncFunction(for: getSet(setCode: setCode))
            if let successResult = result as? ResultSuccess<NSArray>, let cards = successResult.data as? [any DomainCard] {
                return .success(DomainCardList(cards: cards))
            } else if let errorResult = result as? ResultError {
                return .failure(DomainException(domainError: errorResult.exception))
            } else {
                return .failure(DomainException(error: UnexpectedResultError()))
            }
        } catch {
            return .failure(DomainException(error: error))
        }
    }

    public func getCardSets(setCodes: [String]) async -> Swift.Result<Void, DomainException> {
        do {
            let result = try await asyncFunction(for: getSets(setCodes: setCodes))
            if result is ResultSuccess<KotlinUnit> {
                return .success(())
            } else if let errorResult = result as? ResultError {
                return .failure(DomainException(domainError: errorResult.exception))
            } else {
                return .failure(DomainException(error: UnexpectedResultError()))
            }
        } catch {
            return .failure(DomainException(error: error))
        }
    }

    public func getCardSets() -> [any DomainCardSet] {
        return getSets()
    }

    public func observeCardSets() async throws -> AsyncStream<[any DomainCardSet]> {
        return AsyncStream { continuation in
            Task {
                let stream = asyncSequence(for: observeSetsFlow)
                for try await sets in stream {
                    continuation.yield(sets)
                }
                continuation.finish()
            }
        }
    }

    public func observeSetCount() async throws -> AsyncStream<Int> {
        return AsyncStream { continuation in
            Task {
                let stream = asyncSequence(for: observeSetCountFlow)
                for try await count in stream {
                    continuation.yield(count.intValue)
                }
                continuation.finish()
            }
        }
    }

    public func observeCardCount() async throws -> AsyncStream<Int> {
        return AsyncStream { continuation in
            Task {
                let stream = asyncSequence(for: observeCardCountFlow)
                for try await count in stream {
                    continuation.yield(count.intValue)
                }
                continuation.finish()
            }
        }
    }

    public func observeCardsFromSet(setCode: String) async throws -> AsyncStream<[any DomainCard]> {
        return AsyncStream { continuation in
            Task {
                let stream = asyncSequence(for: observeCardsFromSet(code: setCode))
                for try await cards in stream {
                    continuation.yield(cards)
                }
                continuation.finish()
            }
        }
    }

    public func removeCardSet(setCode: String) {
        removeSet(setCode: setCode)
    }
}
