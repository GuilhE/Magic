import SwiftUI

public struct CardSetItem: Identifiable, Equatable, Hashable {
    public let id: UUID = .init()
    public let code: String
    public let name: String
    public let releaseDate: String

    public init(
        code: String,
        name: String,
        releaseDate: String
    ) {
        self.code = code
        self.name = name
        self.releaseDate = releaseDate
    }
}
