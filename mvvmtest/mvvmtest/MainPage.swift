import SwiftUI

struct MainPage: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingComposer = false
    @State private var composeTitle: String = ""
    @State private var composeBody: String = ""
    @State private var selectedEntryID: UUID? = nil
    @State private var showDeleteAlert = false
    @State private var entryToDelete: JournalEntry? = nil

    private let journalTitlePurple = Color(red: 0.76, green: 0.68, blue: 0.90)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Text("Journal")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 14) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                viewModel.sortNewestFirst.toggle()
                                viewModel.sortEntries()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .foregroundColor(.white)
                        }

                        Button(action: {
                            composeTitle = ""
                            composeBody = ""
                            showingComposer = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal)

                if viewModel.entries.isEmpty {
                    Spacer()
                    Image("Book").resizable().aspectRatio(contentMode: .fit).frame(width: 180, height: 180)
                    VStack(spacing: 8) {
                        Text("Begin Your Journal").foregroundColor(journalTitlePurple)
                        Text("Craft your personal diary, tap the plus icon to begin").foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredEntries()) { entry in
                            LargeJournalCard(
                                entry: entry,
                                titleColor: journalTitlePurple,
                                isSelected: entry.id == selectedEntryID,
                                onTap: {
                                    withAnimation(.spring()) {
                                        selectedEntryID = (selectedEntryID == entry.id) ? nil : entry.id
                                    }
                                },
                                onToggleBookmark: { viewModel.toggleBookmark(entryID: entry.id) }
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
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                Spacer()

                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.7))
                    TextField("Search your entries...", text: $viewModel.searchText)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "mic.fill").foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(Color.gray.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingComposer) {
            NavigationView {
                VStack(spacing: 12) {
                    TextField("Title", text: $composeTitle).textFieldStyle(.roundedBorder).padding(.horizontal)
                    TextEditor(text: $composeBody).frame(minHeight: 200).padding(8).background(Color(white: 0.06)).cornerRadius(8).padding(.horizontal)
                    Spacer()
                }
                .navigationTitle("New Entry")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingComposer = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewModel.addEntry(title: composeTitle, body: composeBody)
                            showingComposer = false
                        }
                        .disabled(composeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && composeBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .overlay {
            DeleteConfirmationView(isPresented: $showDeleteAlert) {
                guard let entry = entryToDelete else { return }
                viewModel.deleteEntry(entry)
                entryToDelete = nil
            }
        }
    }
}

#Preview {
    MainPage()
}
