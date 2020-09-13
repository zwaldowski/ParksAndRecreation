//
//  Blur.swift
//  Stickiness
//
//  Created by Zachary Waldowski on 9/8/20.
//

import SwiftUI

struct Blur: View {

    var style: UIBlurEffect.Style? = .systemMaterial

    private struct Implementation: UIViewRepresentable {

        let style: UIBlurEffect.Style?

        var effect: UIVisualEffect? {
            style.map(UIBlurEffect.init)
        }

        func makeUIView(context: Context) -> UIVisualEffectView {
            UIVisualEffectView(effect: effect)
        }

        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
            uiView.effect = effect
        }

    }

    var body: some View {
        Implementation(style: style)
            .edgesIgnoringSafeArea(.all)
            .allowsHitTesting(false)
    }

}

struct Blur_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ UIBlurEffect.Style.systemUltraThinMaterial, .systemThinMaterial, .systemMaterial, .systemThickMaterial, .systemChromeMaterial ], id: \.self) {
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .top, endPoint: .bottom)
                .overlay(
                    Blur(style: $0)
                        .padding()
                )
        }
        .previewLayout(.fixed(width: 300, height: 200))
    }
}
