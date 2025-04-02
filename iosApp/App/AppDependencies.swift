import MagicDataLayer

@MainActor
class AppDependencies {
    public func setupDependencies() {
        DependencyInjection().doInitKoin(enableNetworkLogs: false)
        CardsManagerFactory.register()
        CardListViewModelFactory.register()
        CardDeckViewModelFactory.register()
    }
}
