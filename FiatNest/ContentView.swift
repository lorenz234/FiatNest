//
//  ContentView.swift
//  FiatNest
//
//  Created by Lorenz Lehmann on 30.05.25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var savingsBalance = 231.56
    @State private var savingsBalance_USD = 5.01
    @State private var isAuthenticated = false
    
    init() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemGray6
        
        // Update tab bar colors
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .gray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.customDarkGreen)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.customDarkGreen)]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        if isAuthenticated {
            TabView(selection: $selectedTab) {
                // Accounts Tab
                AccountsView(balance: $savingsBalance, balanceUSD: $savingsBalance_USD)
                    .tabItem {
                        Image(systemName: "banknote")
                        Text("Accounts")
                    }
                    .tag(0)
                
                // Card Tab
                CardView(savingsBalance: $savingsBalance)
                    .edgesIgnoringSafeArea(.horizontal)
                    .tabItem {
                        Image(systemName: "creditcard")
                        Text("Card")
                    }
                    .tag(1)
                
                // Swap Tab
                SwapView()
                    .tabItem {
                        Image(systemName: "paperplane")
                        Text("Swap")
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
            .tint(.customDarkGreen)
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
