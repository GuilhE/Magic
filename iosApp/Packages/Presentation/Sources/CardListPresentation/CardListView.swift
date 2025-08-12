import SwiftUI

public struct CardListView: View {
    @StateObject private var viewModel: CardListViewModel
    @State private var showRateLimitAlert: Bool = false

    public init(viewModel: CardListViewModelProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel as! CardListViewModel)
    }

    public var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            VStack {
                setPicker
                actionButtons
                dataCounters

                ZStack {
                    if viewModel.isLoading {
                        ProgressView().transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 25)
                .animation(.easeInOut, value: viewModel.isLoading)

                Divider().padding(.horizontal, 10)

                ZStack {
                    if !viewModel.cards.isEmpty {
                        cardList.transition(.opacity)
                    } else {
                        emptyViews.transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: viewModel.cards)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert(isPresented: $showRateLimitAlert) {
                Alert(
                    title: Text("Ups!"),
                    message: Text("No more cards for today..."),
                    dismissButton: .default(Text("OK")) {}
                )
            }
        }
        .onChange(of: viewModel.rateExceeded) { oldValue, newValue in
            showRateLimitAlert = newValue
        }
    }

    private var setPicker: some View {
        Picker("Card Set", selection: $viewModel.currentSet) {
            if viewModel.currentSet.code.isEmpty {
                Text("Card Set").tag(nil as String?)
            }
            ForEach(viewModel.availableSets, id: \.self) { set in
                Text("\(set.name), \(set.releaseDate)").tag(set.id)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                Task {
                    await viewModel.getCardsFromCurrentSet()
                }
            }) {
                Text("Get cards")
            }
            .disabled(viewModel.isLoading || viewModel.currentSet.code.isEmpty)
            Button(action: { viewModel.deleteCardSet() }) {
                Text("Delete cards")
            }
            .disabled(viewModel.isLoading || viewModel.currentSet.code.isEmpty || viewModel.cards.isEmpty)
        }
        .padding(20)
    }

    private var dataCounters: some View {
        VStack {
            Text("Number of cards: \(viewModel.cardsTotalCount)")
            Text("Number of sets: \(viewModel.setCount)")
            Spacer().frame(height: 5)
        }
        .frame(maxWidth: .infinity, maxHeight: 60)
    }

    private var cardList: some View {
        let items = viewModel.cards
        return ScrollView {
            LazyVStack {
                ForEach(items) { card in
                    Text(card.name)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyViews: some View {
        ZStack {
            if viewModel.currentSet.code.isEmpty {
                Text("Select Card Set")
            } else {
                if viewModel.cards.isEmpty {
                    Text("No cards...")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
