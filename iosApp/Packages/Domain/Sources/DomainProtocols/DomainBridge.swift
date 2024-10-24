public protocol ErrorException {}
public protocol DomainRateLimitException: ErrorException {}

public struct UnexpectedResultError: Error {
    public init() {}
    var localizedDescription: String {
        return "Received an unexpected result type."
    }
}

public protocol DomainCardSet {
    var code: String { get }
    var name: String { get }
    var releaseDate: String { get }
}

public protocol DomainCard {
    var id: String { get }
    var setCode: String { get }
    var name: String { get }
    var text: String { get }
    var imageUrl: String { get }
    var artist: String { get }
}

public class DomainCardList {
    let cards: [any DomainCard]
    public init(cards: [any DomainCard]) {
        self.cards = cards
    }
}

public class DomainException: Error {
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
