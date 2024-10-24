import CardDeckPresentation
import CardListPresentation
import SwiftUI

@main
struct MagicApp: App {
    init() {
        AppDependencies().setupDependencies()
    }

    var body: some Scene {
        WindowGroup {
            // CardListView(viewModel: CardListViewModelFactory.mock())
            // CardListView(viewModel: CardListViewModelFactory.create())
            // CardDeckScreen<ColorCardView, ColorDeckViewModel>(viewModel: CardDeckViewModelFactory.mock())
            CardDeckScreen<MagicCardView, MagicDeckViewModel>(viewModel: CardDeckViewModelFactory.create())
        }
    }
}
