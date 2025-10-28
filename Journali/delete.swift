

import SwiftUI

struct DeleteConfirmationView: View {
    @Binding var isPresented: Bool
    var onDelete: () -> Void

    var body: some View {
        ZStack {
          //  Group {
                if isPresented {
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(.clear)
                        .frame(width: 400, height: 200)
                        .glassEffect
                        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)

                    


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
                            Button("Cancel") {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                            .font(.headline)
                            .frame(width: 130, height: 46)
                            .background(Color.gray.opacity(1))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .foregroundColor(.white)
                         //   .glassEffect(.clear)


                            Button("Delete") {
                                withAnimation {
                                    isPresented = false
                                    onDelete()
                                }
                            }
                            .font(.headline)
                            .frame(width: 130, height: 46)
                            .background(Color.red.opacity(1))
                            .clipShape(RoundedRectangle(cornerRadius: 25)).foregroundColor(.white)
                           // .glassEffect(.clear)

                        }
                    }
                    .padding()
                    .frame(width: 300, height: 184) // ← نفس أبعاد اللقطة من تصميمك
                //    glassEffect(.systemUltraThinMaterial)

                    .cornerRadius(20) // ← زوايا ناعمة بدون بيضاوية
                    .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)
                    .transition(.scale)
                    .zIndex(1)
}
            }
        }

       // .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
//}
#Preview {
    MainPage()
}
