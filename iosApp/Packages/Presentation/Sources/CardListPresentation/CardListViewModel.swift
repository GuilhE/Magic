import CardDomain
import CardUIModels
import Combine
import DomainProtocols
import SwiftUI

public protocol CardListViewModelProtocol {}

@MainActor
public class CardListViewModel: ObservableObject, CardListViewModelProtocol {
    // https://en.wikipedia.org/wiki/List_of_Magic:_The_Gathering_sets
    private let sets = ["4ED", "5ED", "TMP", "MIR"]
    private let manager: DomainCardsManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var currentSet: CardSetItem = .init(code: "", name: "", releaseDate: "")
    @Published private(set) var availableSets: [CardSetItem] = []
    @Published private(set) var setCount: Int = 0
    @Published private(set) var cardsTotalCount: Int = 0
    @Published private(set) var cards: [CardListItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var rateExceeded: Bool = false

    public init(manager: DomainCardsManagerProtocol) {
        self.manager = manager
        observeData()
    }

    private func observeData() {
        $availableSets
            .handleEvents(receiveSubscription: { _ in
                Task {
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask { await self.getAvailableSets() }
                        group.addTask { await self.observeSetCount() }
                        group.addTask { await self.observeCardsCount() }
                    }
                }
            })
            .sink { _ in }
            .store(in: &cancellables)

        $currentSet
            .filter { !$0.code.isEmpty }
            .map { $0.code }
            .sink { [weak self] code in
                Task { await self?.observeCards(setCode: code) }
            }
            .store(in: &cancellables)
    }

    private func handleError(_ error: DomainException) {
        if let exception = error as? DomainRateLimitException {
            print("> MagicDataLayer error occurred: \(String(describing: exception)) ")
            rateExceeded = true
        } else {
            print("> An error occurred: \(String(describing: error.error))")
        }
    }

    private func observeSetCount() async {
        do {
            let stream = try await manager.observeSetCount()
            for await count in stream {
                setCount = count
            }
        } catch {
            print("> Failed to observe set count with error: \(error)")
        }
    }

    private func observeCardsCount() async {
        do {
            let stream = try await manager.observeCardCount()
            for await count in stream {
                cardsTotalCount = count
            }
        } catch {
            print("> Failed to observe card count with error: \(error)")
        }
    }

    private func observeCards(setCode: String) async {
        do {
            let stream = try await manager.observeCardsFromSet(setCode: setCode)
            for await cardList in stream {
                cards = cardList.map { card in card.toCardListItem() }
            }
        } catch {
            print("> Failed to observe cards with error: \(error)")
        }
    }

    private func getAvailableSets() async {
        isLoading = true
        defer { isLoading = false }

        let result = await manager.getCardSets(setCodes: sets)

        switch result {
        case .success:
            print("> Sets retrieved!")
            availableSets = manager.getCardSets()
                .map { set in set.toCardSetItem() }
                .sorted { $0.releaseDate < $1.releaseDate }
        case let .failure(error): handleError(error)
        }
    }

    func getCardsFromCurrentSet() async {
        rateExceeded = false
        isLoading = true
        defer { isLoading = false }

        let result = await manager.getCardSet(setCode: currentSet.code)

        switch result {
        case .success: print("> Set retrieved!")
        case let .failure(error): handleError(error)
        }
    }

    func deleteCardSet() {
        manager.removeCardSet(setCode: currentSet.code)
    }
}

private extension DomainCard {
    func toCardListItem() -> CardListItem {
        return CardListItem(
            cardId: id,
            setCode: setCode,
            name: name,
            text: text,
            imageUrl: imageUrl,
            artist: artist
        )
    }
}
