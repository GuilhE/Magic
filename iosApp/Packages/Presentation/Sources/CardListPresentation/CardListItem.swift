import SwiftUI

struct CardListItem: Identifiable, Equatable {
    let id: UUID = .init()
    let cardId: String
    let setCode: String
    let name: String
    let text: String
    let imageUrl: String
    let artist: String
}
