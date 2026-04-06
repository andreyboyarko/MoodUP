import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool

    @State private var scale: CGFloat = 0.88
    @State private var glowOpacity: Double = 0.6
    @State private var gradientOffset: CGFloat = 420
    @State private var offsetY: CGFloat = 0

    private let neonColor = Color(red: 163/255, green: 255/255, blue: 18/255)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image("arrow2")
                .resizable()
                .scaledToFit()
                .frame(width: 440, height: 440)
                .scaleEffect(scale)
                .offset(y: offsetY)
                .shadow(color: neonColor.opacity(glowOpacity), radius: 28)

                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: neonColor.opacity(0.2), location: 0.2),
                            .init(color: .white.opacity(0.95), location: 0.5),
                            .init(color: neonColor.opacity(0.9), location: 0.7),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(width: 220, height: 520)
                    .blur(radius: 8)
                    .offset(y: gradientOffset)
                    .mask {
                        Image("arrow2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 440, height: 440)
                    }
                }
        }
        .onAppear {

            // 1. Плавное появление
            withAnimation(.easeOut(duration: 1.2)) {
                scale = 1.0
                glowOpacity = 1.0
            }

            // 2. Свет проходит вверх
            withAnimation(.easeOut(duration: 1.6)) {
                gradientOffset = -420
            }

            // 3. Вылет вверх (после завершения света)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeIn(duration: 0.35)) {
                    offsetY = -800
                    scale = 1.1
                }
            }

            // 4. Переход
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showSplash = false
            }
        }
    }
}
