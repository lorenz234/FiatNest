import SwiftUI
import PromiseKit

struct DepositView: View {
    @Environment(\.dismiss) private var dismiss
    let platform: String
    let apy: Double
    let onDeposit: ((_ amount: String) -> Promise<Void>)?  // Updated to pass amount
    @State private var amount: String = ""
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Amount input section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Amount")
                        .font(.headline)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(.gray)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 24, weight: .medium))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    Text("Deposit from Savings")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // APY info
                VStack(alignment: .leading, spacing: 4) {
                    Text("You will earn")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(String(format: "%.2f", apy))%")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.blue)
                        Text("APY")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // Deposit button
                Button(action: {
                    guard let onDeposit = onDeposit else { return }
                    guard !amount.isEmpty, Double(amount) != nil else { return }
                    
                    isLoading = true
                    
                    firstly {
                        onDeposit(amount)
                    }.done {
                        isLoading = false
                        dismiss()
                    }.catch { err in
                        error = err
                        showingError = true
                        isLoading = false
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        Text(isLoading ? "Confirming..." : "Deposit Now")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading || amount.isEmpty || Double(amount) == nil)
                .opacity((amount.isEmpty || Double(amount) == nil) ? 0.6 : 1.0)
            }
            .padding()
            .navigationTitle("Deposit into \(platform)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Transaction Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(error?.localizedDescription ?? "Unknown error occurred")
            }
        }
    }
}

// Add this view before InvestmentCard
struct BlinkingDot: View {
    @State private var isBlinking = false
    
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 8, height: 8)
            .opacity(isBlinking ? 0.3 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isBlinking
            )
            .onAppear {
                isBlinking = true
            }
    }
}

struct InvestmentCard: View {
    let title: String
    let apy: Double
    let platform: String
    let balance: Double
    let onDeposit: ((_ amount: String) -> Promise<Void>)?
    @State private var showingDetails = false
    @State private var showingDeposit = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            VStack(alignment: .leading, spacing: 16) {
                // Balance and APY info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("Your Balance")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            if balance > 0 {
                                BlinkingDot()
                            }
                        }
                        Text("$\(String(format: "%.2f", balance))")
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
                Text("Earn yield by depositing into \(platform)")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                // Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        showingDeposit = true
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
        .sheet(isPresented: $showingDeposit) {
            DepositView(platform: platform, apy: apy, onDeposit: onDeposit)
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

// MARK: - Investment Manager with Enhanced Debugging
@MainActor
class InvestmentManager: ObservableObject {
    private var usdcDepositor: USDCDepositor?
    @Published var isRunningDiagnostics = false
    @Published var flowBalance: Double = 0.0
    @Published var initializationError: String?
    
    init() {
        // Initialize USDCDepositor safely
        do {
            self.usdcDepositor = try USDCDepositor()
            print("✅ USDCDepositor initialized successfully")
        } catch {
            print("❌ Failed to initialize USDCDepositor: \(error)")
            self.initializationError = error.localizedDescription
        }
        
        // Fetch initial balance
        Task {
            await fetchFlowBalance()
        }
    }
    
    func fetchFlowBalance() async {
        do {
            let balance = try await BlockscoutService.shared.fetchFlowUSDCBalance()
            self.flowBalance = balance
        } catch {
            print("Error fetching Flow balance: \(error)")
        }
    }
    
    // Deposit function that handles amount conversion
    func depositToIncrement(amount: String) -> Promise<Void> {
        return Promise { seal in
            print("💼 InvestmentManager: Starting deposit to Increment")
            print("💰 Amount requested: $\(amount)")
            
            // Check if depositor was initialized successfully
            guard let depositor = self.usdcDepositor else {
                print("❌ USDCDepositor not initialized properly")
                seal.reject(InvestmentError.initializationFailed)
                return
            }
            
            // Validate amount
            guard let amountDouble = Double(amount), amountDouble > 0 else {
                print("❌ Invalid amount: \(amount)")
                seal.reject(InvestmentError.invalidAmount)
                return
            }
            
            // Run diagnostics first if this is a fresh attempt
            firstly {
                depositor.runDiagnostics()
            }.then {
                // Convert amount to proper units if needed
                // For now, we'll use the fixed amount in the depositor
                print("🚀 Starting USDC deposit process...")
                return depositor.depositUSDC()
            }.done {
                print("✅ Successfully deposited to Increment Finance")
                // Refresh balance after successful deposit
                Task { @MainActor in
                    await self.fetchFlowBalance()
                }
                seal.fulfill(())
            }.catch { error in
                print("❌ Deposit failed with error: \(error)")
                seal.reject(error)
            }
        }
    }
    
    func runManualDiagnostics() -> Promise<Void> {
        guard let depositor = usdcDepositor else {
            return Promise(error: InvestmentError.initializationFailed)
        }
        
        isRunningDiagnostics = true
        
        return firstly {
            depositor.runDiagnostics()
        }.ensure {
            Task { @MainActor in
                self.isRunningDiagnostics = false
            }
        }
    }
    
    func depositToAave(amount: String) -> Promise<Void> {
        return Promise { seal in
            guard let amountDouble = Double(amount), amountDouble > 0 else {
                seal.reject(InvestmentError.invalidAmount)
                return
            }
            
            print("🏦 Depositing $\(amount) to Aave (simulated)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if Bool.random() {
                    seal.fulfill(())
                } else {
                    seal.reject(InvestmentError.transactionFailed)
                }
            }
        }
    }
}

enum InvestmentError: LocalizedError {
    case invalidAmount
    case transactionFailed
    case insufficientFunds
    case networkError
    case initializationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Please enter a valid amount"
        case .transactionFailed:
            return "Transaction failed. Please try again."
        case .insufficientFunds:
            return "Insufficient funds for this transaction"
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .initializationFailed:
            return "Failed to initialize wallet. Please check your private key configuration."
        }
    }
}

// Enhanced InvestView with diagnostics button
struct InvestView: View {
    @StateObject private var investmentManager = InvestmentManager()
    @State private var showingDiagnostics = false
    
    var investmentOptions: [(platform: String, apy: Double, balance: Double)] {
        [
            (platform: "More.Markets", apy: 10.36, balance: investmentManager.flowBalance),
            (platform: "Increment", apy: 4.25, balance: 0)
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Show initialization error if present
                if let error = investmentManager.initializationError {
                    VStack(spacing: 12) {
                        Text("⚠️ Wallet Configuration Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        
                        Text("Make sure ETHEREUM_PRIVATE_KEY is set in your environment variables")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                // Welcome section
                VStack(spacing: 12) {
                    Text("Earn Yield on Your Money")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Deposit and instantly start earning interest. Powered by DeFi protocols on Flow.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Investment options
                ForEach(investmentOptions, id: \.platform) { option in
                    InvestmentCard(
                        title: "Deposit into ",
                        apy: option.apy,
                        platform: option.platform,
                        balance: option.balance,
                        onDeposit: investmentManager.initializationError == nil ? { amount in
                            switch option.platform {
                            case "More.Markets":
                                return investmentManager.depositToIncrement(amount: amount)
                            case "Aave":
                                return investmentManager.depositToAave(amount: amount)
                            default:
                                return Promise(error: InvestmentError.transactionFailed)
                            }
                        } : nil
                    )
                }
            }
            .padding(.vertical)
        }
        .background(Color.gray.opacity(0.05))
        .navigationTitle("Invest")
        .onAppear {
            Task {
                await investmentManager.fetchFlowBalance()
            }
        }
    }
}

#Preview {
    InvestView()
}