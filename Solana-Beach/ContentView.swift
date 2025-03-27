//
//  ContentView.swift
//  Solana-Beach
//
//  Created by Tobias Pechatschek on 19.03.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ValidatorsView()
                .tabItem {
                    Label("Validators", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
