import MagicDataLayer

@MainActor
class AppDependencies {
    func setupDependencies() {
        DependencyInjection().doInitKoin(enableNetworkLogs: false)
        CardsManagerFactory.register()
        CardListViewModelFactory.register()
        CardDeckViewModelFactory.register()
    }
}
