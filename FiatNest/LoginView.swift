import SwiftUI

struct LoginView: View {
    var onLoginTapped: () -> Void
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var publicKey: String?
    private let walletService = WalletService()
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if let path = Bundle.main.path(forResource: "logo", ofType: "png"),
               let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
            } else {
                Text("FiatNest")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            if let publicKey = publicKey {
                Text("Wallet Created!")
                    .font(.headline)
                    .foregroundColor(.green)
                Text(publicKey)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            Button(action: onLoginTapped) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: createAccount) {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 50)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func createAccount() {
        do {
            let wallet = try walletService.createWallet()
            self.publicKey = wallet.publicKey
            alertTitle = "Success"
            alertMessage = "Wallet created successfully!"
            showingAlert = true
        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to create wallet: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    LoginView(onLoginTapped: {})
}