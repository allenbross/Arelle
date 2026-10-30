import SwiftUI

struct AtmosphereBackground: View {
    var body: some View {
        ZStack {
            Brand.atmosphere
                .ignoresSafeArea()

            GeometryReader { geo in
                Circle()
                    .fill(Brand.spruce.opacity(0.08))
                    .frame(width: geo.size.width * 0.75)
                    .blur(radius: 40)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.05)

                Circle()
                    .fill(Brand.amber.opacity(0.07))
                    .frame(width: geo.size.width * 0.55)
                    .blur(radius: 50)
                    .offset(x: geo.size.width * 0.45, y: geo.size.height * 0.55)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}
