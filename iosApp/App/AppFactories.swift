import CardDeckPresentation
import CardListPresentation
import CardRepository
import DI
import DomainUseCases
import FactoryProtocols
import Foundation
import MagicDataManagers

class CardsManagerFactory: FactoryProtocol {
    typealias T = DomainCardsManagerProtocol

    private(set) static var createName: String = "CardsManager"
    private(set) static var mockName: String = "CardsManagerMock"

    static func register() {
        DIContainer.shared.register(DomainCardsManagerProtocol.self, name: createName) { _ in
            CardsManagerImpl(manager: KmpInstancesProvider.shared.cardsManager())
        }
        DIContainer.shared.register(DomainCardsManagerProtocol.self, name: mockName) { _ in CardsManagerMock() }
    }

    static func create<CardsManager>() -> CardsManager {
        DIContainer.shared.resolve(DomainCardsManagerProtocol.self, name: createName) as! CardsManager
    }

    static func mock<CardsManagerMock>() -> CardsManagerMock {
        DIContainer.shared.resolve(DomainCardsManagerProtocol.self, name: mockName) as! CardsManagerMock
    }
}

class CardListViewModelFactory: FactoryProtocol {
    typealias T = CardListViewModelProtocol

    private(set) static var createName: String = "CardListViewModel"
    private(set) static var mockName: String = "CardListViewModelMock"

    static func register() {
        DIContainer.shared.register(CardListViewModelProtocol.self, name: createName) { _ in CardListViewModel(manager: CardsManagerFactory.create()) }
        DIContainer.shared.register(CardListViewModelProtocol.self, name: mockName) { _ in CardListViewModel(manager: CardsManagerFactory.mock()) }
    }

    static func create<CardListViewModel>() -> CardListViewModel {
        DIContainer.shared.resolve(CardListViewModelProtocol.self, name: createName) as! CardListViewModel
    }

    static func mock<CardListViewModelMock>() -> CardListViewModelMock {
        DIContainer.shared.resolve(CardListViewModelProtocol.self, name: mockName) as! CardListViewModelMock
    }
}

class CardDeckViewModelFactory: FactoryProtocol {
    typealias T = CardDeckViewModelProtocol
    private(set) static var createName: String = "CardDeckViewModel"
    private(set) static var mockName: String = "CardDeckViewModelMock"

    static func register() {
        DIContainer.shared.register((any CardDeckViewModelProtocol).self, name: createName) { _ in MagicDeckViewModel(manager: CardsManagerFactory.create()) }
        DIContainer.shared.register((any CardDeckViewModelProtocol).self, name: mockName) { _ in ColorDeckViewModel() }
    }

    static func create<MagicDeckViewModel>() -> MagicDeckViewModel {
        DIContainer.shared.resolve((any CardDeckViewModelProtocol).self, name: createName) as! MagicDeckViewModel
    }

    static func mock<ColorDeckViewModel>() -> ColorDeckViewModel {
        DIContainer.shared.resolve((any CardDeckViewModelProtocol).self, name: mockName) as! ColorDeckViewModel
    }
}
