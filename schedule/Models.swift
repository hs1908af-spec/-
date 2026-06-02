import Foundation

struct Plan: Codable, Equatable {
    let id: UUID
    let dateKey: String
    var memo: String
    var isDone: Bool
    let createdAt: Date
}

struct Holiday: Codable, Equatable {
    let date: String
    let name: String
}
