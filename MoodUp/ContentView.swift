//
//  ContentView.swift
//  Mood track
//
//  Created by Andrei  Boyarko on 06/04/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
            } else {
                HomeView()
            }
        }
    }
}
