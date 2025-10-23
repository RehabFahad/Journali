
import SwiftUI
import Combine

class JournalViewModel: ObservableObject {
   
    
    @AppStorage("journalEntriesData") private var journalEntriesData: Data = Data()
    @Published var entries: [JournalEntry] = []
    @Published var sortNewestFirst: Bool = true
    @Published var searchText: String = ""

   

    // إضافة entry جديد
    func addEntry(title: String, body: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? "Untitled" : trimmedTitle
        let entry = JournalEntry(id: UUID(), title: finalTitle, body: body, date: Date())
        entries.append(entry)
        sortEntries()
        saveEntries()
    }

    // حذف entry
    func deleteEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: index)
            saveEntries()
        }
    }

    // تبديل bookmark
    func toggleBookmark(entryID: UUID) {
        if let index = entries.firstIndex(where: { $0.id == entryID }) {
            entries[index].bookmarked.toggle()
            saveEntries()
        }
    }

    // ترتيب الـ entries
    func sortEntries() {
        if sortNewestFirst {
            entries.sort { $0.date > $1.date }
        } else {
            entries.sort { $0.date < $1.date }
        }
    }

    // فلترة الـ entries بناءً على البحث
    func filteredEntries() -> [JournalEntry] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return entries
        }
        let query = searchText.lowercased()
        return entries.filter {
            $0.title.lowercased().contains(query) || $0.body.lowercased().contains(query)
        }
    }

    // حفظ الـ entries
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            journalEntriesData = encoded
        }
    }

    // تحميل الـ entries
    private func loadEntries() {
        if let decoded = try? JSONDecoder().decode([JournalEntry].self, from: journalEntriesData) {
            entries = decoded
        } else {
            // بيانات تجريبية
           
            saveEntries()
        }
    }
}
