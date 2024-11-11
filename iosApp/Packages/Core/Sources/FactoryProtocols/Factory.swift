@MainActor
public protocol FactoryProtocol {
    associatedtype T
    static var createName: String { get }
    static var mockName: String { get }
    static func register()
    static func create<T>() -> T
    static func mock<T>() -> T
}
