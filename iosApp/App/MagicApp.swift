import CardDeckPresentation
import CardListPresentation
import netfox
import SwiftUI

@main
struct MagicApp: App {
    init() {
        #if DEBUG
            NFX.sharedInstance().start()
        #endif
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

#Preview {
    // CardListView(viewModel: CardListViewModelFactory.mock())
    // CardListView(viewModel: CardListViewModelFactory.create())
    // CardDeckScreen<ColorCardView, ColorDeckViewModel>(viewModel: CardDeckViewModelFactory.mock())
    CardDeckScreen<MagicCardView, MagicDeckViewModel>(viewModel: CardDeckViewModelFactory.create())
}
