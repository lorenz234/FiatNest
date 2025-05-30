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
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemGray6
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        if isAuthenticated {
            TabView(selection: $selectedTab) {
                // Accounts Tab
                AccountsView(balance: balance)
                    .tabItem {
                        Image(systemName: "banknote")
                        Text("Accounts")
                    }
                    .tag(0)
                
                // Card Tab
                CardView()
                    .edgesIgnoringSafeArea(.horizontal)
                    .tabItem {
                        Image(systemName: "creditcard")
                        Text("Card")
                    }
                    .tag(1)
                
                // Send Tab
                SendView()
                    .tabItem {
                        Image(systemName: "paperplane")
                        Text("Send")
                    }
                    .tag(2)
                
                // Invest Tab
                InvestView()
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
