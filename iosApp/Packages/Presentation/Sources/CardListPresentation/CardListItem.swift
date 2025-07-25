import SwiftUI

struct CardListItem: Identifiable, Equatable {
    let id: UUID = .init()
    let cardId: String
    let setCode: String
    let name: String
    let text: String
    let imageUrl: String
    let artist: String

    init(
        cardId: String,
        setCode: String,
        name: String,
        text: String,
        imageUrl: String,
        artist: String
    ) {
        self.cardId = cardId
        self.setCode = setCode
        self.name = name
        self.text = text
        self.imageUrl = imageUrl
        self.artist = artist
    }
}
