import DomainProtocols
import MagicDataLayer

extension KotlinThrowable: @retroactive ErrorException {}
extension RateLimitException: @retroactive DomainRateLimitException {}
extension Card: @retroactive DomainCard {}
extension CardSet: @retroactive DomainCardSet {}
