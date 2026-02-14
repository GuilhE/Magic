public protocol ErrorException: Sendable {}
public protocol DomainRateLimitException: ErrorException {}

public protocol DomainCardSet: Sendable {
    var code: String { get }
    var name: String { get }
    var releaseDate: String { get }
}

public protocol DomainCard: Sendable {
    var id: String { get }
    var setCode: String { get }
    var name: String { get }
    var text: String { get }
    var imageUrl: String { get }
    var artist: String { get }
}

public final class DomainCardList: Sendable {
    let cards: [DomainCard]

    public init(cards: [DomainCard]) {
        self.cards = cards
    }
}

public final class DomainException: Error, Sendable {
    public let error: Error?
    public let domainError: ErrorException?

    public init(domainError: ErrorException?) {
        error = nil
        self.domainError = domainError
    }

    public init(error: Error?) {
        self.error = error
        domainError = nil
    }
}

public struct UnexpectedResultError: Error, Sendable {
    public init() {}
    var localizedDescription: String {
        "Received an unexpected result type."
    }
}
