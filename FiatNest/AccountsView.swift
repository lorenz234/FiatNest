import SwiftUI

struct IBANDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "IBAN", value: "EU89 3704 0044 0532 0130 00")
                    DetailRow(title: "BIC", value: "MONEFR21")
                    DetailRow(title: "Name", value: "FiatNest")
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                Text("powered by Monerium")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Bank Details")
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

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
    }
}

struct RoundButton: View {
    let imageName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: imageName)
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    )
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct CryptoDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // QR Code
                if let path = Bundle.main.path(forResource: "eth-qr-code", ofType: "png"),
                   let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                } else {
                    Text("QR Code")
                        .frame(width: 200, height: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "Ethereum Address", value: "0x742d35Cc6634C0532925a3b844Bc454e4438f44e")
                        .font(.system(size: 13, design: .monospaced))
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                Text("Any deposits that are not stablecoins will be automatically converted using 1inch Fusion+")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Crypto Deposit")
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

struct AccountsView: View {
    @Binding var balance: Double
    @Binding var balanceUSD: Double
    @State private var showingAddMoneyOptions = false
    @State private var showingIBANDetails = false
    @State private var showingCryptoDetails = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("savings account")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 4)
            
            Text("€\(balance, specifier: "%.2f")")
                .font(.system(size: 48, weight: .medium))
                .padding(.bottom, 8)
            
            Text("$\(balanceUSD, specifier: "%.2f")")
                .font(.system(size: 48, weight: .medium))
                .padding(.bottom, 40)
            
            HStack(spacing: 25) {
                RoundButton(imageName: "plus.circle.fill", title: "Add Money") {
                    showingAddMoneyOptions = true
                }
                
                RoundButton(imageName: "arrow.left.arrow.right.circle.fill", title: "Move") {
                    // Move action
                }
                
                RoundButton(imageName: "list.bullet.circle.fill", title: "Details") {
                    // Details action
                }
                
                RoundButton(imageName: "ellipsis.circle.fill", title: "More") {
                    // More action
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .confirmationDialog("Add Money", isPresented: $showingAddMoneyOptions) {
            Button("IBAN") {
                showingIBANDetails = true
            }
            Button("Crypto") {
                showingCryptoDetails = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingIBANDetails) {
            IBANDetailsView()
        }
        .sheet(isPresented: $showingCryptoDetails) {
            CryptoDetailsView()
        }
    }
} 