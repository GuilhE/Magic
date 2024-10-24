import SwiftUI

public struct MagicCard: CardProtocol {
    public let id = UUID()
    let name: String
    let text: String
    let imageUrl: String
    let artist: String

    public init(name: String, text: String, imageUrl: String, artist: String) {
        self.name = name
        self.text = text
        self.imageUrl = imageUrl
        self.artist = artist
    }
}
