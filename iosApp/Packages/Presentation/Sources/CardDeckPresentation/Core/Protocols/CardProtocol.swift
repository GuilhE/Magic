import SwiftUI

public protocol CardProtocol: Identifiable, Equatable {
    var id: UUID { get }
}
