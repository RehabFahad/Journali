//
//  Untitled.swift
//  Journali
//
//  Created by رحاب فهد  on 30/04/1447 AH.
//

import SwiftUI

struct JournalEntryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Great Day")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color(hex: "D4C8FF"))

                Text("02/09/2024")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))

                Text("""
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh viverra non semper suscipit posuere.
                """)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding()
        }
        .navigationTitle("Entry")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AppBackground").ignoresSafeArea())
    }
}
