import Kingfisher
import SwiftUI

public struct MagicCardView: CardViewProtocol {
    @State private var showError: Bool = false
    public let card: MagicCard
    public let showBack: Bool
    public let size: CGSize

    public init(card: MagicCard, showBack: Bool, size: CGSize) {
        self.card = card
        self.showBack = showBack
        self.size = size
    }

    public var body: some View {
        ZStack {
            if showBack {
                Image("card_back")
                    .resizable()
                    .scaledToFit()
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: 0, y: 1, z: 0))
                    .animation(.easeInOut(duration: 0.5), value: showBack)
                    .accessibilityHidden(true)
            } else {
                if showError {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black)
                            .background(Color.white)
                        Color.gray.opacity(0.2)
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                } else {
                    KFImage(URL(string: card.imageUrl))
                        .resizable()
                        .placeholder {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black)
                                    .background(Color.white)
                                ProgressView()
                            }
                            .frame(width: size.width, height: size.height)
                        }
                        .onFailure { _ in showError = true }
                        .onSuccess { _ in showError = false }
                        .scaledToFit()
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .rotation3DEffect(Angle(degrees: showBack ? 180 : 0), axis: (x: 0, y: 1, z: 0))        
        .accessibilityLabel("\(card.name) card")
    }
}
