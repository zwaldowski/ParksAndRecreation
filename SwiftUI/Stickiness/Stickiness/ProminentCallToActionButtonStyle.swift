//
//  ContentView.swift
//  ButtonStyles
//
//  Created by Zachary Waldowski on 7/19/20.
//

import SwiftUI

/// Tinted background, light text, center-aligned.
struct ProminentCallToActionButtonStyle: ButtonStyle {

    struct Background: View {

        let isPressed: Bool

        var body: some View {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.accentColor)
                .opacity(isPressed ? 0.5 : 1)
        }

    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.body.bold())
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            //.progressViewStyle(CircularProgressViewStyle(tint: .white))
            .padding(.horizontal)
            .padding(.vertical, 6)
            .frame(maxWidth: 360, minHeight: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(Background(isPressed: configuration.isPressed))
    }

}
