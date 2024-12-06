import Swinject

@MainActor
public class DIContainer {
    public static let shared = DIContainer()
    private let container: Container = .init()

    public func register<T>(_ type: T.Type, name: String? = nil, instance: @escaping (Resolver) -> T) {
        container.register(type, name: name, factory: instance)
    }

    public func resolve<T>(_ type: T.Type, name: String? = nil) -> T? {
        return container.resolve(type, name: name)
    }
}
