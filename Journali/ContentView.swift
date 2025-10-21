//
//  ContentView.swift
//  Journali
//
//  Created by رحاب فهد  on 27/04/1447 AH.
//

//
//  ContentView.swift
//  try
//
//  Created by رحاب فهد  on 28/04/1447 AH.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Image("splashBackground") // ← الخلفية اللي بتضيفينها
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("notebookIcon") // ← صورة الكتاب اللي بتضيفينها
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .shadow(radius: 10)

                Text("Journali")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 5)

                Text("Your thoughts, your story")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .opacity(isActive ? 0 : 1)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainView()
        }

    }
}


#Preview {
    SplashView()
}
