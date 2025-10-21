//
//  Untitled.swift
//  Journali
//
//  Created by رحاب فهد  on 29/04/1447 AH.
//
import SwiftUI

struct MainView: View {
    @State private var showAddEntry = false
    @State private var entries: [String] = [] // مؤقتاً نستخدم نصوص بدل نموذج

    var body: some View {
        NavigationView {
            ZStack {
                Image("splashBackground")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 5)
                    .overlay(Color.black.opacity(0.3))
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        Text("Journal")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 5)

                        Spacer()

                        Button(action: {
                            showAddEntry = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal)

                    if entries.isEmpty {
                        EmptyStateView()
                            .padding(.top, 40)
                    } else {
                        List(entries, id: \.self) { entry in
                            Text(entry)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                    }
                }
                .sheet(isPresented: $showAddEntry) {
                    // لاحقاً نربطها بـ JournalEditorView
                    Text("Editor View Placeholder")
                        .font(.title)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

