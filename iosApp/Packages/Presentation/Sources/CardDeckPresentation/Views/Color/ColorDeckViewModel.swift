import CardUIModels
import Combine
import SwiftUI

public class ColorDeckViewModel: ObservableObject, CardDeckViewModelProtocol {
    public typealias CardType = ColorCard

    private var cancellables = Set<AnyCancellable>()

    @Published public private(set) var availableSets: [CardSetItem] = []
    @Published public private(set) var cards: [ColorCard] = []
    @Published public private(set) var isLoading: Bool = true
    @Published public var rateExceeded: Bool = false

    public init() {
        $availableSets
            .handleEvents(receiveSubscription: { _ in
                Task { await self.getAvailableSets() }
            })
            .sink { _ in }
            .store(in: &cancellables)
    }

    public func getAvailableSets() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        availableSets = [
            CardSetItem(code: "AAA", name: "AAA", releaseDate: ""),
            CardSetItem(code: "BBB", name: "BBB", releaseDate: ""),
        ]
        isLoading = false
    }

    public func changeSet(setCode _: String) {
        Task { await getCardsFromCurrentSet() }
    }

    public func getCardsFromCurrentSet() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        cards = [
            ColorCard(color: .red, number: 1),
            ColorCard(color: .orange, number: 2),
            ColorCard(color: .yellow, number: 3),
            ColorCard(color: .green, number: 4),
            ColorCard(color: .blue, number: 5),
        ]
        isLoading = false
    }

    public func deleteCardsFromCurrentSet() {
        cards.removeAll()
    }
}
