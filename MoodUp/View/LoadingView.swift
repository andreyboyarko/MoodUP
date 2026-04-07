//
//  LoadingView.swift
//  MoodUp
//
//  Created by Andrei  Boyarko on 06/04/2026.
//

import SwiftUI

struct LoadingView: View {
    @State private var start = false
    
    private let neonColor = AppColors.accentNeon

    var body: some View {
        ZStack {
            Text("Loading...")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(neonColor.opacity(0.25))

            Text("Loading...")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 240, height: 60)
                .background(neonColor)
                .mask {
                    Circle()
                        .frame(width: 46, height: 46)
                        .offset(x: start ? -80 : 80)
                }

            Circle()
                .stroke(neonColor, lineWidth: 4)
                .frame(width: 46, height: 46)
                .shadow(color: neonColor.opacity(0.8), radius: 8)
                .offset(x: start ? -80 : 80)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                start = true
            }
        }
    }
}
