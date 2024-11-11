import DomainProtocols
import MagicDataLayer

extension KotlinThrowable: @retroactive ErrorException, @unchecked Sendable {}
extension RateLimitException: @retroactive DomainRateLimitException, @unchecked Sendable {}
extension Card: @retroactive DomainCard, @unchecked Sendable {}
extension CardSet: @retroactive DomainCardSet, @unchecked Sendable {}
