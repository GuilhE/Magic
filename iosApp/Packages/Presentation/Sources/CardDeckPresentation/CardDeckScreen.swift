import CardUIModels
import SwiftUI

public protocol CardDeckScreenProtocol: View {
    associatedtype CardView: CardViewProtocol
    associatedtype CardViewModel: CardDeckViewModelProtocol
}

public struct CardDeckScreen<CardView: CardViewProtocol, CardViewModel: CardDeckViewModelProtocol>: CardDeckScreenProtocol where CardView.CardType == CardViewModel.CardType {
    @StateObject private var viewModel: CardViewModel

    @State private var currentSet = ""
    @State private var changedSet = false
    @State private var availableSets: [CardSetItem] = []
    @State private var fullDeck: [CardViewModel.CardType] = []
    @State private var handDeck: [CardViewModel.CardType] = []
    @State private var showRateLimitAlert = false
    @State private var runAddAnimation = false
    @State private var runRemoveAnimation = false
    @State private var runShuffleAnimation = false
    @State private var runDeleteAnimation = false
    @State private var showEmpty = true
    @State private var btnShuffleRotation: Double = 0

    public init(viewModel: CardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            VStack {
                SetPickers
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .onChange(of:   viewModel.availableSets) { oldValue, newValue in
                        availableSets = newValue
                    }
                CardDeck
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: viewModel.cards) { oldValue, newValue in
                        if !newValue.isEmpty, !runAddAnimation {
                            fullDeck = newValue
                            refreshCards()
                        }
                    }
                    .onChange(of: viewModel.rateExceeded) { oldValue, newValue in
                        showRateLimitAlert = newValue
                    }
            }
            .alert(isPresented: $showRateLimitAlert) {
                Alert(
                    title: Text("Ups!"),
                    message: Text("No more cards for today..."),
                    dismissButton: .default(Text("OK")) {
                        viewModel.rateExceeded = false
                    }
                )
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ActionsToolbar
                }
            }
        }
    }

    private var SetPickers: some View {
        HStack(spacing: 20) {
            ForEach(availableSets, id: \.code) { set in
                Button(action: {
                    if currentSet != set.code {
                        currentSet = set.code
                        changedSet = true
                        runRemoveAnimation = true
                    }
                }) {
                    Image(set.toImage())
                        .circularBlueBorder()
                        .accessibilityHidden(true)
                }
                .scaleEffect(currentSet == set.code ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: currentSet == set.code)
                .accessibilityLabel("\(set.toLabel()) \(currentSet == set.code ? ", current deck" : "")")
                .accessibilityHint("\(currentSet == set.code ? "" : "Touch to change deck")")
            }
            if availableSets.isEmpty {
                if viewModel.isLoading {
                    ProgressView().accessibilityLabel("Loading available decks")
                } else {
                    Button(action: {
                        if !viewModel.isLoading {
                            Task {
                                await viewModel.getAvailableSets()
                            }
                        }
                    }) {
                        Image(systemName: "arrow.down.circle.dotted")
                            .scaleEffect(2.0)
                            .tint(.green)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Get avaiable decks")
                    .accessibilityHint("Touch to download available decks")
                }
            }
        }
    }

    private var CardDeck: some View {
        ZStack {
            if showEmpty {
                Image("card_back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 340)
                    .grayscale(1)
                    .opacity(0.1)
                    .animation(.easeInOut(duration: 0.15), value: showEmpty)
                    .accessibilityLabel("Empty deck, no cards to show")
            }
            CardDeckView<CardView>(
                cardSize: CGSize(width: 250, height: 350),
                deck: $handDeck,
                add: $runAddAnimation,
                remove: $runRemoveAnimation,
                shuffle: $runShuffleAnimation,
                delete: $runDeleteAnimation,
                onAdded: {
                    runRemoveAnimation = false
                    runAddAnimation = false
                },
                onRemoved: {
                    if changedSet {
                        changedSet = false
                        viewModel.changeSet(setCode: currentSet)
                    } else {
                        if fullDeck.isEmpty {
                            Task {
                                await viewModel.getCardsFromCurrentSet()
                            }
                        } else {
                            refreshCards()
                        }
                    }
                },
                onShuffled: {
                    runShuffleAnimation = false
                },
                onDeleted: {
                    viewModel.deleteCardsFromCurrentSet()
                    withAnimation {
                        showEmpty = true
                    }
                    runDeleteAnimation = false
                    currentSet = ""
                }
            )
            .accessibilityHidden(showEmpty)
        }
    }

    private func refreshCards() {
        handDeck = Array(fullDeck.shuffled().prefix(5))
        runAddAnimation = true
        withAnimation {
            showEmpty = false
        }
    }

    private var ActionsToolbar: some View {
        HStack {
            Button(action: {
                if !fullDeck.isEmpty {
                    runDeleteAnimation = true
                }
            }) {
                Image(systemName: "trash.circle")
                    .accessibilityHidden(true)
            }
            .disabled(!enabledDeleteButton())
            .accessibilityLabel("Delete current set")
            .accessibilityHint("Touch to delete \(label(set: currentSet)) set")

            Button(action: {
                if !runShuffleAnimation {
                    runShuffleAnimation = true
                    btnShuffleRotation += 360
                }
            }) {
                Image(systemName: "shuffle.circle")
                    .rotationEffect(Angle(degrees: btnShuffleRotation))
                    .animation(.easeInOut(duration: 1), value: runShuffleAnimation)
                    .accessibilityHidden(true)
            }
            .disabled(!enabledShuffleButton())
            .accessibilityLabel("Shuffle current deck")
            .accessibilityHint("Touch to shuffle \(label(set: currentSet)) deck")

            Button(action: {
                if !viewModel.isLoading, !runAddAnimation {
                    runRemoveAnimation = true
                }
            }) {
                Image(systemName: "arrow.down.circle.dotted")
                    .scaleEffect(viewModel.isLoading ? 1.2 : 1.0)
                    .animation(viewModel.isLoading ? .easeInOut(duration: 1).repeatForever(autoreverses: true) : .default, value: viewModel.isLoading)
                    .tint(viewModel.isLoading ? .green : .blue)
                    .accessibilityHidden(true)
            }
            .disabled(!enabledGetButton())
            .accessibilityLabel("Get more set cards")
            .accessibilityHint("Touch to get more \(label(set: currentSet)) set cards")
        }
    }

    private func enabledDeleteButton() -> Bool { !viewModel.isLoading && !showEmpty && !runDeleteAnimation && !runAddAnimation && !runRemoveAnimation && !runShuffleAnimation }
    private func enabledShuffleButton() -> Bool { !viewModel.isLoading && !showEmpty && !runDeleteAnimation && !runAddAnimation && !runRemoveAnimation }
    private func enabledGetButton() -> Bool { viewModel.isLoading || (!runDeleteAnimation && !runShuffleAnimation && !runAddAnimation && !runRemoveAnimation && !currentSet.isEmpty) }
}

private extension CardSetItem {
    func toImage() -> String {
        switch code {
        case "4ED":
            "edition_4_symbol"
        case "5ED":
            "edition_5_symbol"
        case "MIR":
            "edition_mirage_symbol"
        case "TMP":
            "edition_tempest_symbol"
        case "TOR":
            "edition_torment_symbol"
        case "CHK":
            "edition_champions_of_kanigawa_symbol"
        case "NPH":
            "edition_new_phyrexia_symbol"
        case "DTK":
            "edition_dragon_of_tarkir_symbol"
        default:
            "default"
        }
    }

    func toLabel() -> String {
        label(set: code)
    }
}

private func label(set: String) -> String {
    switch set {
    case "4ED":
        "4th edition"
    case "5ED":
        "5th edition"
    case "MIR":
        "Mirage"
    case "TMP":
        "Tempest"
    case "TOR":
        "Torment"
    case "CHK":
        "Champions of Kanigawa"
    case "NPH":
        "New Phyrexia"
    case "DTK":
        "Dragon of Tarkir"
    default:
        ""
    }
}
