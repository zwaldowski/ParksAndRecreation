//
//  ContentView.swift
//  Stickiness
//
//  Created by Zachary Waldowski on 9/1/20.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView {
            Step("Title") {
                Text("""
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse congue faucibus ligula, a ultricies justo lacinia nec. Pellentesque lacinia tempor ultricies. Duis scelerisque, ex et convallis condimentum, elit lectus gravida nunc, id efficitur elit neque vitae nibh. Etiam lobortis ipsum lorem, non aliquet tortor scelerisque porta. Vestibulum porta sodales risus, eu sodales sapien sodales nec. Phasellus dignissim ut mauris ac pharetra. Vestibulum massa eros, bibendum et lacus in, rhoncus rutrum ligula. Sed at risus sit amet turpis blandit mollis nec in tortor. Phasellus mattis tempus odio. Sed tincidunt ligula dui, vel dapibus sem feugiat eget. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Donec volutpat nisi ut est dignissim sodales. Integer maximus nisl diam. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.

                Phasellus elit dolor, gravida sed tristique nec, blandit at metus. Sed venenatis sapien sit amet turpis dignissim ultrices. Donec elementum ac quam et finibus. Vestibulum ullamcorper massa at lectus fringilla congue. Suspendisse sed magna justo. Maecenas in tellus quis velit cursus commodo non sit amet ipsum. Integer pellentesque dictum sapien at placerat.

                Sed posuere vulputate eros at finibus. Sed vestibulum ante ut leo bibendum, nec vulputate sem dictum. Aliquam magna neque, blandit quis scelerisque a, varius quis libero. In augue augue, faucibus ut faucibus sed, consectetur a metus. Praesent sit amet imperdiet velit. Donec euismod malesuada efficitur. Integer eget risus vulputate, blandit urna vel, vulputate enim. Mauris convallis lobortis lectus, sit amet semper turpis ultrices mollis. Morbi id enim ut erat efficitur egestas ac vel ligula.
                """)
            } hero: {
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 212)
            } footer: {
                Rectangle()
                    .fill(Color.green)
            }
            .navigationBarTitle("Title", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
