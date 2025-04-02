import CardData
import CardDeckPresentation
import CardDomain
import CardListPresentation
import DI
import FactoryProtocols
import MagicDataLayer

class CardsManagerFactory: FactoryProtocol {
    typealias T = DomainCardsManagerProtocol

    public private(set) static var createName: String = "CardsManager"
    public private(set) static var mockName: String = "CardsManagerMock"

    static func register() {
        DIContainer.shared.register(DomainCardsManagerProtocol.self, name: createName) { _ in CardsManager() }
        DIContainer.shared.register(DomainCardsManagerProtocol.self, name: mockName) { _ in CardsManagerMock() }
    }

    public static func create<CardsManager>() -> CardsManager {
        DIContainer.shared.resolve(DomainCardsManagerProtocol.self, name: createName) as! CardsManager
    }

    public static func mock<CardsManagerMock>() -> CardsManagerMock {
        DIContainer.shared.resolve(DomainCardsManagerProtocol.self, name: mockName) as! CardsManagerMock
    }
}

class CardListViewModelFactory: FactoryProtocol {
    typealias T = CardListViewModelProtocol

    public private(set) static var createName: String = "CardListViewModel"
    public private(set) static var mockName: String = "CardListViewModelMock"

    static func register() {
        DIContainer.shared.register(CardListViewModelProtocol.self, name: createName) { _ in CardListViewModel(manager: CardsManagerFactory.create()) }
        DIContainer.shared.register(CardListViewModelProtocol.self, name: mockName) { _ in CardListViewModel(manager: CardsManagerFactory.mock()) }
    }

    public static func create<CardListViewModel>() -> CardListViewModel {
        DIContainer.shared.resolve(CardListViewModelProtocol.self, name: createName) as! CardListViewModel
    }

    public static func mock<CardListViewModelMock>() -> CardListViewModelMock {
        DIContainer.shared.resolve(CardListViewModelProtocol.self, name: mockName) as! CardListViewModelMock
    }
}

class CardDeckViewModelFactory: FactoryProtocol {
    typealias T = CardDeckViewModelProtocol
    public private(set) static var createName: String = "CardDeckViewModel"
    public private(set) static var mockName: String = "CardDeckViewModelMock"

    static func register() {
        DIContainer.shared.register((any CardDeckViewModelProtocol).self, name: createName) { _ in MagicDeckViewModel(manager: CardsManagerFactory.create()) }
        DIContainer.shared.register((any CardDeckViewModelProtocol).self, name: mockName) { _ in ColorDeckViewModel() }
    }

    public static func create<MagicDeckViewModel>() -> MagicDeckViewModel {
        DIContainer.shared.resolve((any CardDeckViewModelProtocol).self, name: createName) as! MagicDeckViewModel
    }

    public static func mock<ColorDeckViewModel>() -> ColorDeckViewModel {
        DIContainer.shared.resolve((any CardDeckViewModelProtocol).self, name: mockName) as! ColorDeckViewModel
    }
}
