//
//  ContentView.swift
//  FiatNest
//
//  Created by Lorenz Lehmann on 30.05.25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var balance = 1234.56
    @State private var isAuthenticated = false
    
    init() {
        UITabBar.appearance().backgroundColor = .systemGray6
    }
    
    var body: some View {
        if isAuthenticated {
            TabView(selection: $selectedTab) {
                // Accounts Tab
                VStack {
                    Spacer()
                    Text("€\(balance, specifier: "%.2f")")
                        .font(.system(size: 48, weight: .medium))
                        .padding(.bottom, 40)
                    Spacer()
                }
                .tabItem {
                    Image(systemName: "banknote")
                    Text("Accounts")
                }
                .tag(0)
                
                // Card Tab
                VStack {
                    Text("Card")
                }
                .tabItem {
                    Image(systemName: "creditcard")
                    Text("Card")
                }
                .tag(1)
                
                // Send Tab
                VStack {
                    Text("Send")
                }
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("Send")
                }
                .tag(2)
                
                // Invest Tab
                VStack {
                    Text("Invest")
                }
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Invest")
                }
                .tag(3)
            }
            .tint(.blue)
        } else {
            LoginView(onLoginTapped: {
                isAuthenticated = true
            })
        }
    }
}

#Preview {
    ContentView()
}
