import SwiftUI

struct InvestmentCard: View {
    let title: String
    let apy: Double
    let platform: String
    let balance: Double
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            VStack(alignment: .leading, spacing: 16) {
                // Balance and APY info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Balance")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("€\(String(format: "%.2f", balance))")
                            .font(.system(size: 20, weight: .bold))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("APY")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("\(String(format: "%.2f", apy))%")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                
                // Platform info
                Text("Earn yield on USDC using \(platform)")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                // Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        // Start earning action
                    }) {
                        Text("Start Earning")
                            .font(.system(size: 16, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Withdraw action
                    }) {
                        Text("Withdraw")
                            .font(.system(size: 16, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            .onTapGesture {
                showingDetails = true
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .sheet(isPresented: $showingDetails) {
            InvestmentDetailsView(platform: platform, apy: apy)
        }
    }
}

struct InvestmentDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    let platform: String
    let apy: Double
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // APY Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Annual Percentage Yield")
                            .font(.headline)
                        Text("\(String(format: "%.2f", apy))%")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Platform Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About \(platform)")
                            .font(.headline)
                        Text("Earn yield on your USDC through institutional lending and other DeFi opportunities. Your assets are protected through overcollateralization and insurance.")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Stats Section
                    VStack(spacing: 16) {
                        StatRow(title: "Total Value Locked", value: "$50M+")
                        StatRow(title: "Users", value: "10,000+")
                        StatRow(title: "Insurance Coverage", value: "Up to $10M")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("\(platform) Investment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct InvestView: View {
    let investmentOptions = [
        (platform: "Increment", apy: 4.25, balance: 1250.50),
        (platform: "Aave", apy: 3.85, balance: 750.25)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(investmentOptions, id: \.platform) { option in
                    InvestmentCard(
                        title: "Earn yield on USDC",
                        apy: option.apy,
                        platform: option.platform,
                        balance: option.balance
                    )
                }
            }
            .padding(.vertical)
        }
        .background(Color.gray.opacity(0.05))
        .navigationTitle("Invest")
    }
}

#Preview {
    InvestView()
} 