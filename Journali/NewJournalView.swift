//
//  رثصتخعق.swift
//  Journali
//
//  Created by رحاب فهد  on 30/04/1447 AH.
//
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
                        Button(action: {
                            showOverlay = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.white)
                    } else {
                        // Fallback on earlier versions
                    }

                    Spacer()

                    if #available(iOS 26.0, *) {
                        Button(action: {
                            // تنفيذ حفظ المذكرة
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Color(red: 0.7, green: 0.6, blue: 0.9))
                    } else {
                        // Fallback on earlier versions
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    Text("02/09/2024")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                ZStack(alignment: .topLeading) {
                    if journalText.isEmpty {
                        Text("Type your Journal...")
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }

                    TextEditor(text: $journalText)
                        .font(.body)
                        .foregroundColor(.white)
                        .focused($isFocused)
                        .padding(8)
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal)

                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isFocused = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
