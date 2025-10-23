import SwiftUI

struct NewJournalOverlay: View {
    @Binding var showOverlay: Bool
    @FocusState private var isFocused: Bool
    @State private var journalText: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    if #available(iOS 26.0, *) {
                        Button(action: { showOverlay = false }) {
                            Image(systemName: "xmark").font(.system(size: 18, weight: .bold)).frame(width: 40, height: 40)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.white)
                    }
                }
            }
        }
    }
}

