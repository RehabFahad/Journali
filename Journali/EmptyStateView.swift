
import SwiftUI

// نموذج اليومية
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let body: String
    let date: Date
    var bookmarked: Bool = false
}

// MainPage معدّلة
struct MainPage: View {
    @AppStorage("journalEntriesData") private var journalEntriesData: Data = Data()
    @State private var entries: [JournalEntry] = []
    @State private var showingComposer = false
    @State private var composeTitle: String = ""
    @State private var composeBody: String = ""
    @State private var sortNewestFirst: Bool = true
    @State private var searchText: String = ""
    @State private var selectedEntryID: UUID? = nil
    @State private var showDeleteAlert = false
    @State private var entryToDelete: JournalEntry? = nil






    // لون عنواين اليوميات المخفف
    private let journalTitlePurple = Color(red: 0.76, green: 0.68, blue: 0.90)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                // رأس الصفحة
                HStack {
                    Text("Journal")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 14) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                sortNewestFirst.toggle()
                                sortEntries()
                                saveEntries()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Button(action: {
                            composeTitle = ""
                            composeBody = ""
                            showingComposer = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal)

                // محتوى الصفحة / بطاقات اليوميات
                if entries.isEmpty {
                    Spacer()

                    Image("Book")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)

                    VStack(spacing: 8) {
                        Text("Begin Your Journal")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(journalTitlePurple)

                        Text("Craft your personal diary, tap the plus icon to begin")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    Spacer()
                } else {
                    List {
                        ForEach(filteredEntries()) { entry in
                            LargeJournalCard(
                                entry: entry,
                                titleColor: journalTitlePurple,
                                isSelected: entry.id == selectedEntryID,
                                onTap: {
                                    withAnimation(.spring()) {
                                        selectedEntryID = (selectedEntryID == entry.id) ? nil : entry.id
                                    }
                                },
                                onToggleBookmark: { toggleBookmark(entryID: entry.id) }
                            )
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        entryToDelete = entry
                                        showDeleteAlert = true
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }


                                .tint(.clear)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                }

                Spacer()

                // شريط البحث
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))

                    TextField("Search your entries...", text: $searchText)
                        .foregroundColor(.white)
                        .disableAutocorrection(true)

                    Spacer()

                    Image(systemName: "mic.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(Color.gray.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.horizontal)
            }
        }
        .onAppear {
            loadEntries()
            sortEntries()
        }
        .sheet(isPresented: $showingComposer) {
            NavigationView {
                VStack(spacing: 12) {
                    TextField("Title", text: $composeTitle)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    TextEditor(text: $composeBody)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(Color(white: 0.06))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Spacer()
                }
                .navigationTitle("New Entry")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingComposer = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            addEntry(title: composeTitle, body: composeBody)
                            showingComposer = false
                        }
                        .disabled(composeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && composeBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
       
    }
    

        DeleteConfirmationView(isPresented: $showDeleteAlert) {
            guard let entry = entryToDelete else { return }
            deleteEntry(entry)
            entryToDelete = nil
        }

    }

    // MARK: - Helpers
    private func deleteEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: index)
            saveEntries()
        }
    }


    private func addEntry(title: String, body: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? "Untitled" : trimmedTitle
        let entry = JournalEntry(id: UUID(), title: finalTitle, body: body, date: Date())
        entries.append(entry)
        sortEntries()
        saveEntries()
    }

    private func sortEntries() {
        if sortNewestFirst {
            entries.sort { $0.date > $1.date }
        } else {
            entries.sort { $0.date < $1.date }
        }
    }

    private func filteredEntries() -> [JournalEntry] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return entries
        }
        let q = searchText.lowercased()
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
            // بيانات تجريبية
            entries = [
                JournalEntry(id: UUID(), title: "My Birthday", body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada...", date: Date()),
                JournalEntry(id: UUID(), title: "Today's Journal", body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio. Quisque volutpat...", date: Date().addingTimeInterval(-3600*24)),
                JournalEntry(id: UUID(), title: "Great Day", body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse urna nibh viverra non...", date: Date().addingTimeInterval(-3600*48))
            ]
            saveEntries()
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for idx in offsets {
            if idx < entries.count {
                entries.remove(at: idx)
            }
        }
        saveEntries()
    }

    private func toggleBookmark(entryID: UUID) {
        if let i = entries.firstIndex(where: { $0.id == entryID }) {
            entries[i].bookmarked.toggle()
            saveEntries()
        }
    }
}

// بطاقة كبيرة جديدة بمظهر مشابه للصورة: عنوان، تاريخ تحت العنوان، ثم معاينة النص، وأيقونة الحفظ في الركن الأيمن العلوي
struct LargeJournalCard: View {
    let entry: JournalEntry
    let titleColor: Color
    let isSelected: Bool
    let onTap: () -> Void
    let onToggleBookmark: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 10) {
                    // العنوان الكبير
                    Text(entry.title)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(titleColor)
                        .lineLimit(1)

                    // التاريخ تحت العنوان بخط أصغر وبألوان خفيفة
                    Text(longDate(entry.date))
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))

                    // نص المعاينة
                    Text(entry.body)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 6)
                }
                .padding(.all, 22)
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
                .background(Color(red: 0.06, green: 0.06, blue: 0.07))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.35), radius: isSelected ? 8 : 4, x: 0, y: 2)

                // أيقونةBookmark صغيرة في الزاوية العلوية اليمنى
                Button(action: {
                    onToggleBookmark()
                }) {
                    Image(systemName: entry.bookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(entry.bookmarked ? titleColor : Color.white.opacity(0.85))
                        .padding(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func longDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt.string(from: date)
    }
}

#Preview {
    MainPage()
}
