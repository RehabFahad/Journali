

import SwiftUI

struct DeleteConfirmationView: View {
    @Binding var isPresented: Bool
    var onDelete: () -> Void

    var body: some View {
        if isPresented {
            ZStack {
                // 🖤 خلفية تغطية ناعمة
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .blur(radius: 1)

                // 🪟 نافذة تأكيد بزجاج حقيقي
                VStack(spacing: 20) {
                    Text("Delete Journal?")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    Text("Are you sure you want to delete this journal?")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 16) {
                        // زر Cancel بزجاج ناعم
                        Button("Cancel") {
                            withAnimation {
                                isPresented = false
                            }
                        }
                        .font(.headline)
                        .frame(width: 120, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.white)

                        // زر Delete بزجاج حقيقي
                        if #available(iOS 26.0, *) {
                            Button("Delete") {
                                withAnimation {
                                    isPresented = false
                                    onDelete()
                                }
                            }
                            .font(.headline)
                            .frame(width: 120, height: 44)
                            .buttonStyle(.glassProminent)
                            .tint(.red)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)
                .frame(maxWidth: 340)
                .transition(.scale)
            }
            .animation(.easeInOut(duration: 0.25), value: isPresented)
        }
    }
}

