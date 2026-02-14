import MagicDataLayer

@MainActor
class AppDependencies {
    func setupDependencies() {
        DependencyInjection().doInit(enableNetworkLogs: true)
        CardsManagerFactory.register()
        CardListViewModelFactory.register()
        CardDeckViewModelFactory.register()
    }
}
