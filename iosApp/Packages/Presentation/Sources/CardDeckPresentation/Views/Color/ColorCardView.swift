import SwiftUI

public struct ColorCardView: CardViewProtocol {
    public let card: ColorCard
    public let showBack: Bool
    public let size: CGSize

    public init(card: ColorCard, showBack: Bool, size: CGSize) {
        self.card = card
        self.showBack = showBack
        self.size = size
    }

    public var body: some View {
        ZStack {
            if showBack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .animation(.easeInOut(duration: 0.5), value: showBack)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(card.color)
                    .overlay(
                        Text("\(card.number)")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .rotation3DEffect(Angle(degrees: showBack ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .shadow(radius: 5)
    }
}
