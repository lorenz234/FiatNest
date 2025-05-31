import SwiftUI

struct SwapView: View {
    @State private var fromAmount = ""
    @State private var fromCurrency = "EUR"
    @State private var toCurrency = "USD"
    @State private var isLoading = false
    
    let currencies = ["EUR", "USD"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // From Currency Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("From")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("0.00", text: $fromAmount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 24, weight: .medium))
                        
                        Picker("From Currency", selection: $fromCurrency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Swap Button
                Button(action: {
                    let temp = fromCurrency
                    fromCurrency = toCurrency
                    toCurrency = temp
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(12)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // To Currency Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("To")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        // Show calculated amount based on fromAmount
                        Text(calculateToAmount())
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Picker("To Currency", selection: $toCurrency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Exchange Rate Info
                Text("1 \(fromCurrency) = \(getExchangeRate()) \(toCurrency)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Swap Button
                Button(action: {
                    performSwap()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        Text(isLoading ? "Converting..." : "Convert Now")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(fromAmount.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(fromAmount.isEmpty || isLoading)
            }
            .padding()
            .navigationTitle("Swap")
        }
    }
    
    private func calculateToAmount() -> String {
        guard let amount = Double(fromAmount) else { return "0.00" }
        let rate = getExchangeRate()
        return String(format: "%.2f", amount * rate)
    }
    
    private func getExchangeRate() -> Double {
        // Hardcoded exchange rates for demo
        if fromCurrency == "EUR" && toCurrency == "USD" {
            return 1.09
        } else if fromCurrency == "USD" && toCurrency == "EUR" {
            return 0.92
        }
        return 1.0
    }
    
    private func performSwap() {
        guard !fromAmount.isEmpty else { return }
        
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            fromAmount = ""
        }
    }
}

#Preview {
    SwapView()
} 