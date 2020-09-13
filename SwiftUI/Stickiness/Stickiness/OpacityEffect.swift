//
//  OpacityEffect.swift
//  ButtonStyles
//
//  Created by Zachary Waldowski on 7/19/20.
//

import SwiftUI

private struct OpacityEffect: ViewModifier {

    let opacity: Double

    func body(content: Content) -> some View {
        content.opacity(opacity)
    }

}

private struct DisabledOpacity: EnvironmentalModifier {

    func resolve(in environment: EnvironmentValues) -> some ViewModifier {
        OpacityEffect(opacity: environment.isEnabled ? 1 : (environment.colorScheme == .dark ? 0.45 : 0.35))
    }

}

extension View {

    func disabledOpacity() -> some View {
        modifier(DisabledOpacity())
    }

}


private struct PressedOpacity: EnvironmentalModifier {

    let isActive: Bool

    func resolve(in environment: EnvironmentValues) -> some ViewModifier {
        OpacityEffect(opacity: isActive ? (environment.colorScheme == .dark ? 0.4 : 0.2) : 1)
    }

}

extension View {

    func pressedOpacity(_ active: Bool = true) -> some View {
        modifier(PressedOpacity(isActive: active))
    }

}
