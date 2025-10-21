//
//  MainView.swift
//  Journali
//
//  Created by رحاب فهد  on 27/04/1447 AH.
//

import SwiftUI

struct EmptyStateView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Image("splashBackground") // ← الخلفية اللي بتضيفينها
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()


            VStack(spacing: 20) {
                Image("emptyNotebookIcon") // ← صورة الدفتر المفتوح
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .shadow(radius: 10)

                Text("Begin Your Journal")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.purple)

                Text("Craft your personal diary,\ntap the plus icon to begin")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}
#Preview {
    EmptyStateView()
}
