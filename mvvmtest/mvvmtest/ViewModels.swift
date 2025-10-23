//
//  Untitled.swift
//  mvvmtest
//
//  Created by رحاب فهد  on 01/05/1447 AH.
//

// 📁 ViewModels/JournalViewModel.swift
import Foundation
import SwiftUI

class JournalViewModel: ObservableObject {
    @AppStorage("journalEntriesData") private var journalEntriesData: Data = Data()
    
    @Published var entries: [JournalEntry] = []
    @Published var sortNewestFirst: Bool = true
    @Published var searchText: String = ""

    init() {
        loadEntries()
        sortEntries()
    }

    func addEntry(title: String, body: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? "Untitled" : trimmedTitle
        let entry = JournalEntry(id: UUID(), title: finalTitle, body: body, date: Date())
        entries.append(entry)
        sortEntries()
        saveEntries()
    }

    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    func toggleBookmark(entryID: UUID) {
        if let i = entries.firstIndex(where: { $0.id == entryID }) {
            entries[i].bookmarked.toggle()
            saveEntries()
        }
    }

    func sortEntries() {
        entries.sort {
            sortNewestFirst ? $0.date > $1.date : $0.date < $1.date
        }
    }

    func filteredEntries() -> [JournalEntry] {
        let q = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return entries }
        return entries.filter {
            $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q)
        }
    }

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            journalEntriesData = encoded
        }
    }

    private func loadEntries() {
        if let decoded = try? JSONDecoder().decode([JournalEntry].self, from: journalEntriesData) {
            entries = decoded
        } else {
            entries = [
                JournalEntry(id: UUID(), title: "My Birthday", body: "Lorem ipsum...", date: Date()),
                JournalEntry(id: UUID(), title: "Today's Journal", body: "Lorem ipsum...", date: Date().addingTimeInterval(-86400)),
                JournalEntry(id: UUID(), title: "Great Day", body: "Lorem ipsum...", date: Date().addingTimeInterval(-172800))
            ]
            saveEntries()
        }
    }
}
