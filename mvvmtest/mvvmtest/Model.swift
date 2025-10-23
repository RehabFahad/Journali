import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let body: String
    let date: Date
    var bookmarked: Bool = false
}
