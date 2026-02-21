import MagicDataLayer

@MainActor
class AppDependencies {
    func setupDependencies() {
        DependencyInjection.shared.start(enableNetworkLogs: false)
        CardsManagerFactory.register()
        CardListViewModelFactory.register()
        CardDeckViewModelFactory.register()
    }
}
