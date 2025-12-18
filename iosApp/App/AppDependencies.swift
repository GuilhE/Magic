import MagicDI

@MainActor
class AppDependencies {
    func setupDependencies() {
        DependencyInjection.shared.initKoin(enableNetworkLogs: false)
        CardsManagerFactory.register()
        CardListViewModelFactory.register()
        CardDeckViewModelFactory.register()
    }
}
