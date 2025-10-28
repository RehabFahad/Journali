import SwiftUI

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let body: String
    let date: Date
    var bookmarked: Bool = false
}

struct MainPage: View {
    @FocusState private var titleFieldFocused: Bool
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }

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
    @State private var startApp = false
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

                // محتوى الصفحة
                if entries.isEmpty {
                    Spacer()

                    Image("emptyNotebookIcon")
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
                            .padding(.horizontal, 59)
                    }
                    .padding(.horizontal, 12)

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
                                       .listRowSeparator(.hidden) 
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
                                .tint(Color(hex: "FF3B30"))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    
                }
            }
            .padding(.top)

            // السيرش بار الزجاجي يطفو تحت
            .overlay(alignment: .bottom) {
                VStack {
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
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .padding(.horizontal)
                    .glassEffect(.clear)
                    .background(Color.black.opacity(0.001))
                }
                .padding(.bottom, 12) // ← هذا يرفع الشريط بدون ما يكبره
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
                        .font(.system(size: 30, weight: .semibold))
                        .padding(.leading, 9)
                        .foregroundColor(.white)
                        .tint(Color(hex: "A499FF")) // ← لون المؤشر بنفسجي فاتح
                        .focused($titleFieldFocused)


                    Text(formattedDate)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 9)

                    TextField("Type your Journal...", text: $composeBody)
                        .font(.system(size: 20, design: .rounded))
                        .padding(.horizontal)
                        .tint(Color(hex: "A499FF"))

                    Spacer()
                }
                .padding(.top, 25)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        titleFieldFocused = true
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            showingComposer = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                        .glassEffect(.clear)
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            addEntry(title: composeTitle, body: composeBody)
                            showingComposer = false
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                        .disabled(
                            composeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                            composeBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                    }
                }
            }
        }
        .alert("Delete Journal?", isPresented: $showDeleteAlert, presenting: entryToDelete) { entry in
            Button("Delete", role: .destructive) {
                deleteEntry(entry)
                entryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                entryToDelete = nil
            }
        } message: { entry in
            Text("Are you sure you want to delete this journal?")
        }
        .preferredColorScheme(.dark)

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
            entries = [
                JournalEntry(id: UUID(), title: "My Birthday", body: "Lorem ipsum dolor sit amet...", date: Date()),
                JournalEntry(id: UUID(), title: "Today's Journal", body: "Lorem ipsum dolor sit amet...", date: Date().addingTimeInterval(-3600*24)),
                JournalEntry(id: UUID(), title: "Great Day", body: "Lorem ipsum dolor sit amet...", date: Date().addingTimeInterval(-3600*48))
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

#Preview {
    MainPage()
}
