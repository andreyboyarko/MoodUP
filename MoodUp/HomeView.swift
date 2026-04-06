//
//  HomeView.swift
//  MoodUp
//
//  Created by Andrei  Boyarko on 06/04/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("MoodUp")
                .foregroundColor(Color(red: 163/255, green: 255/255, blue: 18/255))
                .font(.system(size: 32, weight: .bold))
        }
    }
}
