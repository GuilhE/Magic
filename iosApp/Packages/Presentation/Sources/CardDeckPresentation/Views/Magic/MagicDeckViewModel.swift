import CardUIModels
import Combine
import DomainModels
import DomainUseCases
import SwiftUI

@MainActor
public class MagicDeckViewModel: ObservableObject, CardDeckViewModelProtocol {
    public typealias CardType = MagicCard

    // https://en.wikipedia.org/wiki/List_of_Magic:_The_Gathering_sets
    // private let sets = ["4ED", "5ED", "TMP", "MIR"] //For some reason these sets images return 308
    private let sets = ["TOR", "CHK", "NPH", "DTK"]
    private nonisolated(unsafe) let manager: DomainCardsManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var currentSet: CardSetItem = .init(code: "", name: "", releaseDate: "")
    @Published public private(set) var availableSets: [CardSetItem] = []
    @Published public private(set) var cards: [MagicCard] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public var rateExceeded: Bool = false

    public init(manager: DomainCardsManagerProtocol) {
        self.manager = manager
        observeData()
    }

    private func observeData() {
        $availableSets
            .handleEvents(receiveSubscription: { _ in
                Task { await self.getAvailableSets() }
            })
            .sink { _ in }
            .store(in: &cancellables)

        $currentSet
            .filter { !$0.code.isEmpty }
            .map(\.code)
            .sink { [weak self] code in
                print("> Current set is \(code)")
                Task { await self?.observeCards(setCode: code) }
            }
            .store(in: &cancellables)
    }

    private func observeCards(setCode: String) async {
        print("> Observing \(currentSet.name) cards")
        let stream = await manager.observeCardsFromSet(setCode: setCode)
        for await cardList in stream {
            cards = cardList.map { card in card.toMagicCard() }
        }
    }

    private func handleError(_ error: DomainException) {
        if error.domainError != nil {
            print("> MagicDataLayer error occurred: \(String(describing: error.domainError)) ")
            if error.domainError is DomainRateLimitException {
                rateExceeded = true
            }
        } else {
            print("> An error occurred: \(String(describing: error.error))")
        }
    }

    private func changeCurrentSet(_ setCode: String) {
        guard let value = manager.getCardSets().first(where: { $0.code == setCode })?.toCardSetItem() else {
            print("> Set \(currentSet.name) not found!")
            return
        }
        currentSet = value
    }

    public func getAvailableSets() async {
        isLoading = true
        defer { isLoading = false }

        let result = await manager.getCardSets(setCodes: sets)

        switch result {
        case .success:
            availableSets = manager.getCardSets()
                .map { set in set.toCardSetItem() }
                .sorted { $0.releaseDate < $1.releaseDate }
            print("> \(availableSets.count) sets retrieved!")
        case let .failure(error): handleError(error)
        }
    }

    public func changeSet(setCode: String) {
        if manager.getCardSets().first(where: { set in set.code == setCode }) != nil {
            changeCurrentSet(setCode)
        } else {
            Task {
                rateExceeded = false
                isLoading = true
                defer { isLoading = false }

                let result = await manager.getCardSet(setCode: setCode)

                switch result {
                case .success:
                    print("> Set \(setCode) retrieved!")
                    changeCurrentSet(setCode)
                case let .failure(error): handleError(error)
                }
            }
        }
    }

    public func getCardsFromCurrentSet() async {
        if currentSet.code.isEmpty {
            return
        }

        rateExceeded = false
        isLoading = true
        defer { isLoading = false }

        let result = await manager.getCardSet(setCode: currentSet.code)

        switch result {
        case .success: print("> Set \(currentSet.name) retrieved!")
        case let .failure(error): handleError(error)
        }
    }

    public func deleteCardsFromCurrentSet() {
        manager.removeCardSet(setCode: currentSet.code)
        print("> \(currentSet.name) deleted!")
    }
}

private extension DomainCard {
    func toMagicCard() -> MagicCard {
        MagicCard(
            name: name,
            text: text,
            imageUrl: imageUrl.toSecureURL() ?? imageUrl,
            artist: artist
        )
    }
}

private extension String {
    func toSecureURL() -> String? {
        guard var urlComponents = URLComponents(string: self) else {
            return nil
        }
        if urlComponents.scheme == "http" {
            urlComponents.scheme = "https"
        }
        return urlComponents.string
    }
}
