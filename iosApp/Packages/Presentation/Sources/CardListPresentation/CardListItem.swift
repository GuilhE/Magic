import SwiftUI

struct CardListItem: Identifiable, Equatable {
    public let id: UUID = .init()
    public let cardId: String
    public let setCode: String
    public let name: String
    public let text: String
    public let imageUrl: String
    public let artist: String

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
