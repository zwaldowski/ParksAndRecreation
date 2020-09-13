//
//  Step.swift
//  Stickiness
//
//  Created by Zachary Waldowski on 9/12/20.
//

import SwiftUI

struct Step<Hero, Header, Content, Footer>: View where Hero: View, Header: View, Content: View, Footer: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var barVisibility = BarVisibility()

    let hero: Hero
    let header: Header
    let content: Content
    let footer: Footer

    var verticalScrollIndicatorInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: barVisibility.bottomBarHeight, right: 0)
    }

    var footerVPadding: CGFloat {
        verticalSizeClass == .compact ? CGFloat(12) : CGFloat(24)
    }

    func footerBottomPadding(using proxy: GeometryProxy) -> CGFloat {
        min(64 - proxy.safeAreaInsets.bottom, 36)
    }

    var footerBackgroundEffect: UIVisualEffect? {
        barVisibility.hidesBottomBarBackground ? nil : UIBlurEffect(style: .systemChromeMaterial)
    }

    var body: some View {
        GeometryReader { (proxy) in
            ZStack {
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ScrollViewConfigurator(verticalScrollIndicatorInsets: verticalScrollIndicatorInsets)
                            .frame(width: 0, height: 0)

                        hero
                            .frame(minHeight: proxy.safeAreaInsets.top)
                            .padding(.top, -proxy.safeAreaInsets.top)

                        VStack(spacing: 12) {
                            header
                                .font(Font.largeTitle.bold())
                                .transformAnchorPreference(key: BarVisibilityPreferenceKey.self, value: .bounds) { (value, anchor) in
                                    value.hidesTopBarTitle = proxy[anchor].maxY > 0
                                }

                            content
                        }
                        .padding()
                        .multilineTextAlignment(.center)
                        .transformAnchorPreference(key: BarVisibilityPreferenceKey.self, value: .bounds) { (value, anchor) in
                            value.hidesTopBarBackground = proxy[anchor].minY >= 0
                            value.hidesBottomBarBackground = proxy[anchor].maxY <= proxy.size.height - barVisibility.bottomBarHeight
                        }

                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: barVisibility.bottomBarHeight)
                    }
                }

                HStack {
                    footer
                }
                .frame(maxHeight: 50)
                .padding(.horizontal)
                .padding(.vertical, footerVPadding)
                .padding(.bottom, footerBottomPadding(using: proxy))
                .transformAnchorPreference(key: BarVisibilityPreferenceKey.self, value: .bounds) { (value, anchor) in
                    value.bottomBarHeight = proxy[anchor].height
                }
                .frame(maxWidth: .infinity)
                .background(Blur(style: barVisibility.hidesBottomBarBackground ? nil : .systemChromeMaterial))
                .frame(maxHeight: proxy.size.height, alignment: .bottom)
            }
        }
        .onPreferenceChange(BarVisibilityPreferenceKey.self) { (value) in
            barVisibility = value
        }
        .updatesNavigationBar(backgroundHidden: barVisibility.hidesTopBarBackground, titleHidden: barVisibility.hidesTopBarTitle)
    }

}

// MARK: -

extension Step {

    init(@ViewBuilder content: () -> Content, @ViewBuilder hero: () -> Hero, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.hero = hero()
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

}

extension Step where Hero == EmptyView {

    init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.hero = EmptyView()
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

}

extension Step where Header == Text {

    init(_ titleKey: LocalizedStringKey, @ViewBuilder _ content: () -> Content, @ViewBuilder hero: () -> Hero, @ViewBuilder footer: () -> Footer) {
        self.hero = hero()
        self.header = Text(titleKey)
        self.content = content()
        self.footer = footer()
    }

    init<S>(_ title: S, @ViewBuilder _ content: () -> Content, @ViewBuilder hero: () -> Hero, @ViewBuilder footer: () -> Footer) where S: StringProtocol {
        self.hero = hero()
        self.header = Text(title)
        self.content = content()
        self.footer = footer()
    }

}

extension Step where Hero == EmptyView, Header == Text {

    init(_ titleKey: LocalizedStringKey, @ViewBuilder _ content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.hero = EmptyView()
        self.header = Text(titleKey)
        self.content = content()
        self.footer = footer()
    }

    init<S>(_ title: S, @ViewBuilder _ content: () -> Content, @ViewBuilder footer: () -> Footer) where S: StringProtocol {
        self.hero = EmptyView()
        self.header = Text(title)
        self.content = content()
        self.footer = footer()
    }

}

// MARK: -

private struct BarVisibility: Equatable {

    var hidesTopBarBackground = false
    var hidesTopBarTitle = false
    var hidesBottomBarBackground = false
    var bottomBarHeight = CGFloat(126)

    mutating func merge(_ other: BarVisibility) {
        hidesTopBarBackground = hidesTopBarBackground || other.hidesTopBarBackground
        hidesTopBarTitle = hidesTopBarTitle || other.hidesTopBarTitle
        hidesBottomBarBackground = hidesBottomBarBackground || other.hidesBottomBarBackground
        bottomBarHeight = other.bottomBarHeight
    }

}

private struct BarVisibilityPreferenceKey: PreferenceKey {

    static var defaultValue: BarVisibility { BarVisibility() }

    static func reduce(value: inout BarVisibility, nextValue: () -> BarVisibility) {
        value.merge(nextValue())
    }

}

// MARK: -

private struct ScrollViewConfigurator: UIViewRepresentable {

    let verticalScrollIndicatorInsets: UIEdgeInsets?

    class Implementation: UIView {

        var scrollViewVerticalIndicatorInsets: UIEdgeInsets?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            update()
        }

        func update() {
            guard window != nil, let scrollView = findNextResponder(of: UIScrollView.self) else { return }

            if let verticalScrollIndicatorInsets = scrollViewVerticalIndicatorInsets {
                scrollView.verticalScrollIndicatorInsets = verticalScrollIndicatorInsets
            }
        }

    }

    func makeUIView(context: Context) -> Implementation {
        let view = Implementation()
        view.scrollViewVerticalIndicatorInsets = verticalScrollIndicatorInsets
        return view
    }

    func updateUIView(_ view: Implementation, context: Context) {
        view.scrollViewVerticalIndicatorInsets = verticalScrollIndicatorInsets
        view.update()
    }

}
