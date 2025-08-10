import CardUIModels
import DomainUseCases
import SwiftUI

@MainActor
public protocol CardDeckViewModelProtocol: ObservableObject where CardType: CardProtocol {
    associatedtype CardType

    var availableSets: [CardSetItem] { get }
    var cards: [CardType] { get }
    var isLoading: Bool { get }
    var rateExceeded: Bool { get set }
    func getAvailableSets() async
    func changeSet(setCode: String)
    func getCardsFromCurrentSet() async
    func deleteCardsFromCurrentSet()
}
